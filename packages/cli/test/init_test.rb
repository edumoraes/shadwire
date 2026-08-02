# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"
require "json"
require "stringio"

class InitTest < Minitest::Test
  FIXTURE_APP = File.expand_path("fixtures/app", __dir__)
  FILE_REGISTRY = "file://#{File.expand_path("fixtures/registry", __dir__)}"

  def with_app
    Dir.mktmpdir do |tmp|
      root = File.join(tmp, "app")
      FileUtils.cp_r(FIXTURE_APP, root)
      yield root
    end
  end

  def recording_runner
    calls = []
    runner = ->(cmd, chdir:) { calls << { cmd:, chdir: }; true }
    [runner, calls]
  end

  def silent_ui(yes: true)
    Shadwire::UI.new(out: StringIO.new, err: StringIO.new, yes:)
  end

  def run_init(root, ui: silent_ui, runner: recording_runner.first, **opts)
    Shadwire::Commands::Init.new(
      root:, registry: FILE_REGISTRY, yes: true, ui:, runner:, **opts
    ).call
  end

  # ── config ───────────────────────────────────────────────────────────────────

  def test_writes_shadwire_json_with_registry_and_defaults
    with_app do |root|
      run_init(root)

      config = JSON.parse(File.read(File.join(root, "shadwire.json")))
      assert_equal FILE_REGISTRY, config["registry"]
      assert_equal "app/assets/tailwind/application.css", config.dig("tailwind", "css")
      assert_equal "vendor/shadwire", config.dig("aliases", "vendorCss")
      assert_equal({}, config["installed"])
    end
  end

  # ── base files ───────────────────────────────────────────────────────────────

  def test_installs_base_files
    with_app do |root|
      run_init(root)

      assert_equal "# ui_component\n", File.read(File.join(root, "app/components/ui_component.rb"))
      assert_equal "# ui_helper\n", File.read(File.join(root, "app/helpers/ui_helper.rb"))
      assert_equal "/* shadwire */\n", File.read(File.join(root, "vendor/shadwire/shadwire.css"))
    end
  end

  # ── base gems ────────────────────────────────────────────────────────────────

  def test_applies_base_gems_via_bundle_add
    with_app do |root|
      runner, calls = recording_runner
      run_init(root, runner:)

      assert_equal 2, calls.size
      assert_equal ["bundle", "add", "view_component", "lucide-rails"], calls.first[:cmd]
      assert_equal root, calls.first[:chdir]
    end
  end

  # The CLI gem itself is development-only, and is not part of the registry's
  # base gems: installed component files carry no Shadwire dependency.
  def test_adds_the_cli_gem_to_the_development_group
    with_app do |root|
      runner, calls = recording_runner
      run_init(root, runner:)

      assert_equal ["bundle", "add", "shadwire", "--group", "development"], calls.last[:cmd]
    end
  end

  # ── tailwind import ──────────────────────────────────────────────────────────

  def test_inserts_tailwind_import
    with_app do |root|
      run_init(root)

      lines = File.read(File.join(root, "app/assets/tailwind/application.css")).lines.map(&:chomp)
      assert_equal %(@import "tailwindcss";), lines[0]
      assert_equal %(@import "../../../vendor/shadwire/shadwire.css";), lines[1]
    end
  end

  def test_tailwind_import_idempotent_on_rerun
    with_app do |root|
      run_init(root)
      before = File.read(File.join(root, "app/assets/tailwind/application.css"))
      run_init(root)
      after = File.read(File.join(root, "app/assets/tailwind/application.css"))

      assert_equal before, after
    end
  end

  # ── not a Rails app ──────────────────────────────────────────────────────────

  def test_raises_project_error_outside_rails_app
    Dir.mktmpdir do |root|
      assert_raises(Shadwire::ProjectError) { run_init(root) }
    end
  end

  # ── unsupported stack warns, does not crash ──────────────────────────────────

  def test_warns_without_crashing_when_stack_missing
    Dir.mktmpdir do |root|
      # A bare Rails app: rails? is true via config/application.rb, but none of the
      # front-end stack (importmap / stimulus / tailwindcss) is present.
      FileUtils.mkdir_p(File.join(root, "config"))
      File.write(File.join(root, "config/application.rb"), "# app\n")
      File.write(File.join(root, "Gemfile"), %(source "https://rubygems.org"\ngem "rails"\n))
      err = StringIO.new
      ui = Shadwire::UI.new(out: StringIO.new, err:, yes: true)

      run_init(root, ui:)

      warnings = err.string
      assert_match(/importmap/i, warnings)
      assert_match(/stimulus/i, warnings)
      assert_match(/tailwind/i, warnings)
      # config + base files still written despite the incomplete stack
      assert File.exist?(File.join(root, "shadwire.json"))
      assert File.exist?(File.join(root, "app/components/ui_component.rb"))
    end
  end

  # ── --force resets config ────────────────────────────────────────────────────

  def test_force_resets_installed
    with_app do |root|
      File.write(File.join(root, "shadwire.json"), JSON.generate(
        "registry" => FILE_REGISTRY,
        "tailwind" => { "css" => "app/assets/tailwind/application.css" },
        "aliases" => {},
        "installed" => { "button" => { "version" => "1", "files" => [] } }
      ))

      run_init(root, force: true)

      config = JSON.parse(File.read(File.join(root, "shadwire.json")))
      assert_equal({}, config["installed"])
    end
  end

  # ── binstub ──────────────────────────────────────────────────────────────────

  def test_writes_an_executable_binstub
    with_app do |root|
      run_init(root)

      path = File.join(root, "bin/shadwire")
      assert_path_exists path
      assert_equal 0o755, File.stat(path).mode & 0o777
      assert_includes File.read(path), %(load Gem.bin_path("shadwire", "shadwire"))
    end
  end

  def test_leaves_an_existing_binstub_alone
    with_app do |root|
      FileUtils.mkdir_p(File.join(root, "bin"))
      File.write(File.join(root, "bin/shadwire"), "# from bundle binstubs\n")

      run_init(root)

      assert_equal "# from bundle binstubs\n", File.read(File.join(root, "bin/shadwire"))
    end
  end

  def test_force_rewrites_the_binstub
    with_app do |root|
      FileUtils.mkdir_p(File.join(root, "bin"))
      File.write(File.join(root, "bin/shadwire"), "# from bundle binstubs\n")

      run_init(root, force: true)

      assert_includes File.read(File.join(root, "bin/shadwire")), "bundler/setup"
    end
  end

  # A bundler binstub raises Gem::LoadError when the gem is not in the Gemfile,
  # so a declined confirm must not leave a broken entry point behind.
  def test_skips_the_binstub_when_the_cli_gem_was_declined
    with_app do |root|
      ui = Shadwire::UI.new(out: StringIO.new, err: StringIO.new, yes: false, confirm_proc: ->(_) { false })

      Shadwire::Commands::Init.new(
        root:, registry: FILE_REGISTRY, yes: false, ui:, runner: recording_runner.first
      ).call

      refute_path_exists File.join(root, "bin/shadwire")
    end
  end

  # Collapsing the two bundle results would advise `bundle add shadwire`, which
  # lands the development-only CLI in the app's runtime dependencies.
  def test_failed_cli_gem_recovery_keeps_the_development_group
    with_app do |root|
      only_cli_fails = ->(cmd, chdir:) { !cmd.include?("shadwire") }

      err = assert_raises(Shadwire::Error) { run_init(root, runner: only_cli_fails) }

      assert_match(/bundle add shadwire --group development/, err.message)
      refute_path_exists File.join(root, "bin/shadwire")
    end
  end

  def test_failed_base_gem_recovery_has_no_group
    with_app do |root|
      only_base_fails = ->(cmd, chdir:) { cmd.include?("shadwire") }

      err = assert_raises(Shadwire::Error) { run_init(root, runner: only_base_fails) }

      assert_match(/bundle add view_component lucide-rails`/, err.message)
    end
  end

  # Telling someone to create a file that is already there is worse than saying
  # nothing; the real problem is that the binstub cannot run without the gem.
  def test_reports_an_existing_binstub_as_unusable_without_the_gem
    with_app do |root|
      FileUtils.mkdir_p(File.join(root, "bin"))
      File.write(File.join(root, "bin/shadwire"), "# from bundle binstubs\n")
      out = StringIO.new
      ui = Shadwire::UI.new(out:, err: StringIO.new, yes: false, confirm_proc: ->(_) { false })

      Shadwire::Commands::Init.new(
        root:, registry: FILE_REGISTRY, yes: false, ui:, runner: recording_runner.first
      ).call

      refute_match(/add `gem "shadwire"` to the Gemfile, then re-run/, out.string)
      assert_match(/bin\/shadwire exists but/, out.string)
    end
  end

  def test_json_reports_the_binstub
    with_app do |root|
      out = StringIO.new
      ui = Shadwire::UI.new(out:, err: StringIO.new, yes: true)

      run_init(root, ui:, json: true)

      payload = JSON.parse(out.string.lines.last)
      assert_equal "bin/shadwire", payload.dig("binstub", "path")
      assert_equal true, payload.dig("binstub", "written")
      assert_equal false, payload.dig("binstub", "skipped")
    end
  end
end
