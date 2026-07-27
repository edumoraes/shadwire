# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"
require "json"
require "stringio"

# Failure modes that are dangerous specifically because they look like success.
# An agent trusts exit codes and structured output; a command that reports a gem
# as installed when it is not, or overwrites an edit without saying so, sends it
# confidently down the wrong path.
class AgentSafetyTest < Minitest::Test
  FIXTURE_APP = File.expand_path("fixtures/app", __dir__)
  FILE_REGISTRY = "file://#{File.expand_path("fixtures/registry", __dir__)}"

  def silent_ui(out: StringIO.new, err: StringIO.new)
    Shadwire::UI.new(out:, err:, yes: true)
  end

  def ok_runner = ->(_cmd, chdir:) { true }
  def failing_runner = ->(_cmd, chdir:) { false }

  def app
    Dir.mktmpdir do |tmp|
      root = File.join(tmp, "app")
      FileUtils.cp_r(FIXTURE_APP, root)
      yield root
    end
  end

  def initialized(root, runner: ok_runner)
    Shadwire::Commands::Init.new(
      root:, registry: FILE_REGISTRY, yes: true, ui: silent_ui, runner:
    ).call
  end

  # --- bundle add failure --------------------------------------------------

  def test_init_raises_when_bundle_add_fails
    app do |root|
      File.write(File.join(root, "Gemfile"), %(source "https://rubygems.org"\ngem "rails"\n))

      error = assert_raises(Shadwire::Error) { initialized(root, runner: failing_runner) }
      assert_match(/Failed to install/, error.message)
      assert_match(/bundle add/, error.message, "the message must say how to recover")
    end
  end

  def test_init_reports_failed_gems_rather_than_claiming_they_were_applied
    app do |root|
      File.write(File.join(root, "Gemfile"), %(source "https://rubygems.org"\ngem "rails"\n))
      out = StringIO.new

      assert_raises(Shadwire::Error) do
        Shadwire::Commands::Init.new(
          root:, registry: FILE_REGISTRY, yes: true, ui: silent_ui(out:), runner: failing_runner
        ).call
      end

      assert_match(/FAILED\s+view_component/, out.string)
      refute_match(/^\s+gem\s+view_component/, out.string, "a failed gem must not be listed as applied")
    end
  end

  # The with-gems fixture exists purely to reach add's dependency path; no other
  # fixture item declares gems.
  def test_add_raises_when_bundle_add_fails
    app do |root|
      initialized(root)
      out = StringIO.new

      error = assert_raises(Shadwire::Error) do
        Shadwire::Commands::Add.new(
          root:, names: ["with-gems"], registry: FILE_REGISTRY, yes: true,
          ui: silent_ui(out:), runner: failing_runner
        ).call
      end

      assert_match(/fixture_gem/, error.message)
      assert_match(/FAILED\s+fixture_gem/, out.string)
    end
  end

  def test_add_json_reports_failed_gems
    app do |root|
      initialized(root)
      out = StringIO.new

      assert_raises(Shadwire::Error) do
        Shadwire::Commands::Add.new(
          root:, names: ["with-gems"], registry: FILE_REGISTRY, yes: true, json: true,
          ui: silent_ui(out:), runner: failing_runner
        ).call
      end

      assert_equal ["fixture_gem"], JSON.parse(out.string).dig("gems", "failed")
    end
  end

  def test_a_successful_bundle_add_still_reports_applied
    app do |root|
      File.write(File.join(root, "Gemfile"), %(source "https://rubygems.org"\ngem "rails"\n))
      result = initialized(root, runner: ok_runner)

      assert_includes result[:gems][:applied], "view_component"
      assert_empty result[:gems][:failed]
    end
  end

  # --- structured output ---------------------------------------------------

  def test_init_supports_json
    app do |root|
      out = StringIO.new
      Shadwire::Commands::Init.new(
        root:, registry: FILE_REGISTRY, yes: true, json: true, ui: silent_ui(out:), runner: ok_runner
      ).call

      payload = JSON.parse(out.string)
      refute_empty payload.fetch("created")
      assert_equal [], payload.dig("gems", "failed")
    end
  end

  def test_add_supports_json
    app do |root|
      initialized(root)
      out = StringIO.new
      Shadwire::Commands::Add.new(
        root:, names: ["button"], registry: FILE_REGISTRY, yes: true, json: true,
        ui: silent_ui(out:), runner: ok_runner
      ).call

      payload = JSON.parse(out.string)
      assert_equal ["button"], payload.fetch("added")
      assert_includes payload.fetch("written"), "app/components/ui/button_component.rb"
    end
  end

  # --- update must disclose what it destroyed ------------------------------

  def test_update_json_reports_the_edits_it_overwrote
    app do |root|
      initialized(root)
      Shadwire::Commands::Add.new(
        root:, names: ["button"], registry: FILE_REGISTRY, yes: true, ui: silent_ui, runner: ok_runner
      ).call

      target = File.join(root, "app/components/ui/button_component.rb")
      File.write(target, "#{File.read(target)}\n# a local customization\n")

      out = StringIO.new
      Shadwire::Commands::Update.new(
        root:, names: ["button"], registry: FILE_REGISTRY, yes: true, json: true,
        ui: silent_ui(out:), runner: ok_runner
      ).call

      payload = JSON.parse(out.string)
      assert_includes payload.fetch("overwritten"), "app/components/ui/button_component.rb",
                      "JSON must disclose overwritten edits, as the human output does"
      assert_includes payload.fetch("diffs").keys, "app/components/ui/button_component.rb"
    end
  end

  # --- errors as sentences, not backtraces ---------------------------------

  def test_a_malformed_config_raises_a_shadwire_error_naming_the_file
    app do |root|
      File.write(File.join(root, "shadwire.json"), "{ not json")

      error = assert_raises(Shadwire::ConfigError) { Shadwire::Config.load(root) }
      assert_match(/shadwire\.json/, error.message)
      assert_match(/not valid JSON/, error.message)
    end
  end

  def test_a_registry_serving_non_json_raises_a_shadwire_error
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "index.json"), "<html>404</html>")
      client = Shadwire::RegistryClient.new("file://#{dir}")

      error = assert_raises(Shadwire::RegistryError) { client.index }
      assert_match(/not valid JSON/, error.message)
    end
  end

  def test_an_unreachable_host_raises_a_shadwire_error
    client = Shadwire::RegistryClient.new("https://no-such-host-shadwire.invalid/r")

    error = assert_raises(Shadwire::RegistryError) { client.index }
    assert_match(/Could not reach the registry/, error.message)
  end
end
