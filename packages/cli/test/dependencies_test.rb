# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"

class DependenciesTest < Minitest::Test
  FIXTURE_APP = File.expand_path("fixtures/app", __dir__)

  def with_app
    Dir.mktmpdir do |tmp|
      root = File.join(tmp, "app")
      FileUtils.cp_r(FIXTURE_APP, root)
      yield root
    end
  end

  # Records every shell invocation instead of shelling out.
  def recording_runner
    calls = []
    runner = ->(cmd, chdir:) { calls << { cmd:, chdir: }; true }
    [runner, calls]
  end

  # ── ensure_gems ──────────────────────────────────────────────────────────────

  def test_ensure_gems_runs_bundle_add_for_missing_gem
    with_app do |root|
      runner, calls = recording_runner
      deps = Shadwire::Dependencies.new(Shadwire::Project.new(root), runner:)

      result = deps.ensure_gems(["lucide-rails"], yes: true)

      assert_equal 1, calls.size
      assert_equal ["bundle", "add", "lucide-rails"], calls.first[:cmd]
      assert_equal root, calls.first[:chdir]
      assert_includes result[:applied], "lucide-rails"
    end
  end

  def test_ensure_gems_batches_multiple_missing_gems
    with_app do |root|
      runner, calls = recording_runner
      deps = Shadwire::Dependencies.new(Shadwire::Project.new(root), runner:)

      deps.ensure_gems(["view_component", "lucide-rails"], yes: true)

      assert_equal ["bundle", "add", "view_component", "lucide-rails"], calls.first[:cmd]
    end
  end

  def test_ensure_gems_skips_present_gem
    with_app do |root|
      runner, calls = recording_runner
      deps = Shadwire::Dependencies.new(Shadwire::Project.new(root), runner:)

      result = deps.ensure_gems(["importmap-rails"], yes: true)

      assert_empty calls
      assert_includes result[:skipped], "importmap-rails"
    end
  end

  def test_ensure_gems_pending_without_yes_or_confirm
    with_app do |root|
      runner, calls = recording_runner
      deps = Shadwire::Dependencies.new(Shadwire::Project.new(root), runner:)

      result = deps.ensure_gems(["lucide-rails"], yes: false)

      assert_empty calls
      assert_includes result[:pending], "lucide-rails"
    end
  end

  def test_ensure_gems_applies_when_confirm_true
    with_app do |root|
      runner, calls = recording_runner
      deps = Shadwire::Dependencies.new(Shadwire::Project.new(root), runner:)

      result = deps.ensure_gems(["lucide-rails"], yes: false, confirm: ->(_desc) { true })

      assert_equal 1, calls.size
      assert_includes result[:applied], "lucide-rails"
    end
  end

  # ── ensure_importmap_pins ────────────────────────────────────────────────────

  def test_ensure_importmap_pins_appends_missing_pin
    with_app do |root|
      deps = Shadwire::Dependencies.new(Shadwire::Project.new(root))

      result = deps.ensure_importmap_pins(
        [{ "name" => "chart.js/auto", "to" => "https://cdn.example/x" }], yes: true
      )

      content = File.read(File.join(root, "config/importmap.rb"))
      assert_includes content, %(pin "chart.js/auto", to: "https://cdn.example/x")
      assert_includes result[:applied], "chart.js/auto"
    end
  end

  def test_ensure_importmap_pins_idempotent
    with_app do |root|
      deps = Shadwire::Dependencies.new(Shadwire::Project.new(root))
      pins = [{ "name" => "chart.js/auto", "to" => "https://cdn.example/x" }]

      deps.ensure_importmap_pins(pins, yes: true)
      before = File.read(File.join(root, "config/importmap.rb"))
      result = deps.ensure_importmap_pins(pins, yes: true)
      after = File.read(File.join(root, "config/importmap.rb"))

      assert_equal before, after
      assert_includes result[:skipped], "chart.js/auto"
    end
  end

  def test_ensure_importmap_pins_manual_when_no_importmap
    Dir.mktmpdir do |root|
      File.write(File.join(root, "Gemfile"), %(gem "rails"\ngem "tailwindcss-rails"\n))
      deps = Shadwire::Dependencies.new(Shadwire::Project.new(root))

      result = deps.ensure_importmap_pins(
        [{ "name" => "chart.js/auto", "to" => "https://cdn.example/x" }], yes: true
      )

      refute_empty result[:manual]
      refute File.exist?(File.join(root, "config/importmap.rb"))
    end
  end

  # ── ensure_tailwind_import ───────────────────────────────────────────────────

  def test_ensure_tailwind_import_inserts_after_tailwindcss
    with_app do |root|
      deps = Shadwire::Dependencies.new(Shadwire::Project.new(root))

      result = deps.ensure_tailwind_import("vendor/shadwire/shadwire.css", yes: true)

      lines = File.read(File.join(root, "app/assets/tailwind/application.css")).lines.map(&:chomp)
      assert_equal %(@import "tailwindcss";), lines[0]
      assert_equal %(@import "../../../vendor/shadwire/shadwire.css";), lines[1]
      assert_includes result[:applied], "../../../vendor/shadwire/shadwire.css"
    end
  end

  def test_ensure_tailwind_import_idempotent
    with_app do |root|
      deps = Shadwire::Dependencies.new(Shadwire::Project.new(root))

      deps.ensure_tailwind_import("vendor/shadwire/shadwire.css", yes: true)
      before = File.read(File.join(root, "app/assets/tailwind/application.css"))
      result = deps.ensure_tailwind_import("vendor/shadwire/shadwire.css", yes: true)
      after = File.read(File.join(root, "app/assets/tailwind/application.css"))

      assert_equal before, after
      assert_includes result[:skipped], "../../../vendor/shadwire/shadwire.css"
    end
  end

  def test_ensure_tailwind_import_manual_when_no_tailwind
    Dir.mktmpdir do |root|
      File.write(File.join(root, "Gemfile"), %(gem "rails"\ngem "importmap-rails"\n))
      deps = Shadwire::Dependencies.new(Shadwire::Project.new(root))

      result = deps.ensure_tailwind_import("vendor/shadwire/shadwire.css", yes: true)

      refute_empty result[:manual]
    end
  end
end
