# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"
require "json"
require "stringio"

# `status` is what the agent skill injects as its project context, so its
# contract is unusually strict: it must always produce parseable JSON and exit
# cleanly, even outside a Rails app. Failure states are data, not exceptions.
class StatusTest < Minitest::Test
  FIXTURE_APP = File.expand_path("fixtures/app", __dir__)
  FILE_REGISTRY = "file://#{File.expand_path("fixtures/registry", __dir__)}"

  def noop_runner
    ->(_cmd, chdir:) { true }
  end

  def silent_ui(out: StringIO.new, err: StringIO.new)
    Shadwire::UI.new(out:, err:, yes: true)
  end

  def initialized_app
    Dir.mktmpdir do |tmp|
      root = File.join(tmp, "app")
      FileUtils.cp_r(FIXTURE_APP, root)
      Shadwire::Commands::Init.new(
        root:, registry: FILE_REGISTRY, yes: true, ui: silent_ui, runner: noop_runner
      ).call
      yield root
    end
  end

  def add(root, name)
    Shadwire::Commands::Add.new(
      root:, names: Array(name), registry: FILE_REGISTRY, yes: true, ui: silent_ui, runner: noop_runner
    ).call
  end

  def status(root, ui: silent_ui, **opts)
    Shadwire::Commands::Status.new(root:, registry: FILE_REGISTRY, ui:, **opts).call
  end

  def test_reports_a_plain_directory_as_data_rather_than_raising
    Dir.mktmpdir do |root|
      result = status(root)

      assert_equal false, result.fetch("rails")
      assert_equal false, result.fetch("configPresent")
      assert_empty result.fetch("installed")
    end
  end

  def test_emits_parseable_json_outside_a_rails_app
    Dir.mktmpdir do |root|
      out = StringIO.new
      status(root, json: true, ui: silent_ui(out:))

      parsed = JSON.parse(out.string)
      assert_equal false, parsed.fetch("rails")
    end
  end

  def test_detects_a_rails_app_and_its_stack
    initialized_app do |root|
      result = status(root)

      assert_equal true, result.fetch("rails")
      assert_equal true, result.fetch("configPresent")
      assert_equal true, result.dig("stack", "importmap")
      assert_equal true, result.dig("stack", "tailwindcssRails")
    end
  end

  def test_lists_installed_components_with_the_helpers_they_define
    initialized_app do |root|
      add(root, "button")
      entry = status(root).fetch("installed").find { |item| item["name"] == "button" }

      refute_nil entry
      assert_includes entry.fetch("helpers"), "ui_button"
      assert_includes entry.fetch("classes"), "Ui::ButtonComponent"
      assert_equal "unchanged", entry.fetch("drift")
    end
  end

  def test_reports_drift_for_a_locally_modified_file
    initialized_app do |root|
      add(root, "button")
      target = File.join(root, "app/components/ui/button_component.rb")
      File.write(target, "#{File.read(target)}\n# local edit\n")

      assert_equal "modified", status(root).fetch("installed").first.fetch("drift")
    end
  end

  def test_reports_missing_when_an_installed_file_was_deleted
    initialized_app do |root|
      add(root, "button")
      FileUtils.rm(File.join(root, "app/components/ui/button_component.rb"))

      assert_equal "missing", status(root).fetch("installed").first.fetch("drift")
    end
  end

  def test_flags_a_leftover_monolithic_helper
    initialized_app do |root|
      FileUtils.mkdir_p(File.join(root, "app/helpers"))
      File.write(File.join(root, "app/helpers/ui_helper.rb"), "module UiHelper\nend\n")

      assert_equal true, status(root).dig("helpers", "legacyHelperPresent")
    end
  end

  # Absent config/application.rb means we cannot prove the app opted out, so the
  # Rails default (true) stands.
  def test_assumes_helper_auto_inclusion_when_there_is_no_application_config
    initialized_app do |root|
      assert_equal true, status(root).dig("helpers", "includeAllHelpers")
    end
  end

  def test_reports_include_all_helpers_when_the_app_disables_it
    initialized_app do |root|
      config = File.join(root, "config/application.rb")
      FileUtils.mkdir_p(File.dirname(config))
      File.write(config, <<~RUBY)
        module Dummy
          class Application < Rails::Application
            config.action_controller.include_all_helpers = false
          end
        end
      RUBY

      assert_equal false, status(root).dig("helpers", "includeAllHelpers")
    end
  end

  def test_reports_the_catalog_size_and_registry_version
    initialized_app do |root|
      result = status(root)

      assert_operator result.fetch("availableCount"), :>, 0
      refute_nil result.fetch("registryVersion")
    end
  end

  # An unreachable registry must degrade to a reported error, not an exception —
  # the skill's context injection would otherwise break.
  def test_an_unreachable_registry_is_reported_without_raising
    initialized_app do |root|
      out = StringIO.new
      result = Shadwire::Commands::Status.new(
        root:, registry: "file:///nonexistent/registry", json: true, ui: silent_ui(out:)
      ).call

      refute_nil result["registryError"]
      assert_equal true, result.fetch("rails")
      assert JSON.parse(out.string), "output must still be parseable JSON"
    end
  end

  def test_human_output_names_installed_components
    initialized_app do |root|
      add(root, "button")
      out = StringIO.new
      status(root, ui: silent_ui(out:))

      assert_match(/button/, out.string)
      assert_match(/ui_button/, out.string)
    end
  end

  # ── cli entry point ──────────────────────────────────────────────────────────

  def test_reports_the_binstub_after_init
    initialized_app do |root|
      result = status(root)

      assert_equal true, result.dig("cli", "binstub")
    end
  end

  def test_reports_a_missing_binstub
    initialized_app do |root|
      FileUtils.rm_f(File.join(root, "bin/shadwire"))

      result = status(root)

      assert_equal false, result.dig("cli", "binstub")
    end
  end

  # The recording runner never mutates the Gemfile, so after init the gem is
  # still absent there — which is exactly the state this field must report.
  def test_reports_the_cli_gem_from_the_gemfile
    initialized_app do |root|
      assert_equal false, status(root).dig("cli", "gem")

      File.write(File.join(root, "Gemfile"), %(gem "shadwire"\n), mode: "a")

      assert_equal true, status(root).dig("cli", "gem")
    end
  end

  def test_plain_directory_reports_no_cli
    Dir.mktmpdir do |root|
      result = status(root)

      assert_equal false, result.dig("cli", "gem")
      assert_equal false, result.dig("cli", "binstub")
    end
  end
end
