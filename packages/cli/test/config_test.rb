# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "json"

class ConfigTest < Minitest::Test
  def test_defaults_when_no_file_present
    Dir.mktmpdir do |root|
      config = Shadwire::Config.load(root)

      assert_equal "https://edumoraes.github.io/shadwire/r", config.registry
      assert_equal "app/assets/tailwind/application.css", config.tailwind_css
      assert_equal "app/components",          config.aliases["components"]
      assert_equal "app/components/ui",       config.aliases["ui"]
      assert_equal "app/helpers",             config.aliases["helpers"]
      assert_equal "app/javascript/controllers", config.aliases["controllers"]
      assert_equal "vendor/shadwire",         config.aliases["vendorCss"]
      assert_equal({}, config.installed)
    end
  end

  def test_round_trip_load_save_load_yields_equal_data
    Dir.mktmpdir do |root|
      original = Shadwire::Config.load(root)
      original.save

      reloaded = Shadwire::Config.load(root)
      assert_equal original.registry,     reloaded.registry
      assert_equal original.tailwind_css, reloaded.tailwind_css
      assert_equal original.aliases,      reloaded.aliases
      assert_equal original.installed,    reloaded.installed
    end
  end

  def test_save_writes_pretty_json_with_trailing_newline
    Dir.mktmpdir do |root|
      Shadwire::Config.load(root).save

      raw = File.read(File.join(root, "shadwire.json"))
      assert raw.end_with?("\n"), "expected file to end with newline"
      parsed = JSON.parse(raw)
      assert_equal "https://edumoraes.github.io/shadwire/r", parsed["registry"]
    end
  end

  def test_record_installed_stores_version_and_files
    Dir.mktmpdir do |root|
      config = Shadwire::Config.load(root)
      config.record_installed("button", "1.0.0", ["app/components/ui/button_component.rb"])

      entry = config.installed["button"]
      assert_equal "1.0.0", entry["version"]
      assert_equal ["app/components/ui/button_component.rb"], entry["files"]
    end
  end

  def test_forget_removes_installed_entry
    Dir.mktmpdir do |root|
      config = Shadwire::Config.load(root)
      config.record_installed("button", "1.0.0", ["app/components/ui/button_component.rb"])
      config.forget("button")

      assert_nil config.installed["button"]
    end
  end

  def test_installed_shape_persists_through_round_trip
    Dir.mktmpdir do |root|
      config = Shadwire::Config.load(root)
      config.record_installed("badge", "2.1.0", [
        "app/components/ui/badge_component.rb",
        "app/helpers/ui_helper.rb"
      ])
      config.save

      reloaded = Shadwire::Config.load(root)
      entry = reloaded.installed["badge"]
      assert_equal "2.1.0", entry["version"]
      assert_equal ["app/components/ui/badge_component.rb", "app/helpers/ui_helper.rb"], entry["files"]
    end
  end
end
