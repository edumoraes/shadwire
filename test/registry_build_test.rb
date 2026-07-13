# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "pathname"
require "tmpdir"
require "fileutils"
require "shellwords"

# Exercises bin/build_registry end-to-end: shells out with a BUILD_DIR override
# into a throwaway directory, then asserts the published artifact under r/ carries
# inlined file content, a resolved transitive dependency list, and a base install
# block consumed by `init`. The source registry.json format is validated
# separately by registry_schema_test.rb / registry_manifest_test.rb.
class RegistryBuildTest < Minitest::Test
  ROOT = Pathname.new(__dir__).join("..").expand_path
  REGISTRY = JSON.parse(ROOT.join("registry/registry.json").read)

  BUILD_DIR = Dir.mktmpdir("shadwire-build")
  Minitest.after_run { FileUtils.remove_entry(BUILD_DIR, true) }

  # Build once for the whole suite by running the real script.
  BUILD_OUTPUT = `BUILD_DIR=#{BUILD_DIR.shellescape} #{ROOT.join("bin/build_registry").to_s.shellescape} 2>&1`
  BUILD_OK = $?.success?
  R_DIR = Pathname.new(BUILD_DIR).join("r")

  def setup
    assert BUILD_OK, "bin/build_registry did not exit cleanly:\n#{BUILD_OUTPUT}"
  end

  def item_json(name)
    JSON.parse(R_DIR.join("#{name}.json").read)
  end

  def index_json
    JSON.parse(R_DIR.join("index.json").read)
  end

  def test_every_item_produces_a_parseable_json_file
    REGISTRY.fetch("items").each do |item|
      name = item.fetch("name")
      path = R_DIR.join("#{name}.json")
      assert path.file?, "missing published item: #{name}.json"
      assert_equal name, item_json(name).fetch("name")
    end
  end

  def test_every_file_inlines_its_on_disk_source
    REGISTRY.fetch("items").each do |item|
      published = item_json(item.fetch("name"))
      by_target = published.fetch("files").to_h { |file| [file.fetch("target"), file] }

      item.fetch("files").each do |source_file|
        target = source_file.fetch("target")
        published_file = by_target.fetch(target) do
          flunk "#{item.fetch("name")} did not publish a file for target #{target}"
        end

        content = published_file.fetch("content")
        refute_empty content, "#{item.fetch("name")} #{target} inlined empty content"
        assert_equal ROOT.join(source_file.fetch("source")).read, content,
                     "#{item.fetch("name")} #{target} content does not match its on-disk source"
      end
    end
  end

  def test_published_files_drop_the_source_path
    files = item_json("button").fetch("files")
    refute_empty files
    files.each do |file|
      refute file.key?("source"), "published files must not leak the registry source path"
      assert file.key?("target"), "published files must carry a target"
      assert file.key?("content"), "published files must carry inlined content"
    end
  end

  def test_registry_dependencies_are_resolved
    deps = item_json("data-table").fetch("registryDependencies")
    %w[table button input checkbox dropdown-menu].each do |dep|
      assert_includes deps, dep, "data-table should depend on #{dep}"
    end
  end

  def test_registry_dependencies_include_the_transitive_closure
    # sidebar-01 -> sidebar -> {button, separator, input, skeleton, tooltip, icon}
    deps = item_json("sidebar-01").fetch("registryDependencies")
    assert_includes deps, "sidebar"
    %w[button separator input skeleton tooltip icon].each do |transitive|
      assert_includes deps, transitive, "sidebar-01 should transitively depend on #{transitive}"
    end
    refute_includes deps, "sidebar-01", "an item must not list itself as a dependency"
  end

  def test_items_without_dependencies_publish_an_empty_array
    assert_equal [], item_json("button").fetch("registryDependencies")
  end

  def test_explicit_title_and_description_are_preserved
    button = item_json("button")
    assert_equal "Button", button.fetch("title")
    assert_equal "Displays a button or a link styled as a button.", button.fetch("description")
  end

  def test_absent_title_and_description_fall_back_to_a_humanized_name
    otp = item_json("input-otp")
    assert_equal "Input Otp", otp.fetch("title")
    assert_equal "Input Otp", otp.fetch("description")
  end

  def test_item_importmap_pins_are_published
    pins = item_json("chart").fetch("importmap")
    assert_equal "chart.js/auto", pins.first.fetch("name")
    assert_equal "https://cdn.jsdelivr.net/npm/chart.js@4.4.6/auto/+esm", pins.first.fetch("to")
  end

  def test_items_without_importmap_or_gems_publish_empty_arrays
    button = item_json("button")
    assert_equal [], button.fetch("importmap")
    assert_equal [], button.fetch("gems")
  end

  def test_index_catalogs_every_item
    catalog = index_json.fetch("items")
    assert_equal REGISTRY.fetch("items").map { |item| item.fetch("name") }.sort,
                 catalog.map { |entry| entry.fetch("name") }.sort
    catalog.each do |entry|
      %w[name type title description].each do |key|
        assert entry.key?(key), "index item #{entry["name"]} is missing #{key}"
      end
    end
  end

  def test_index_base_block_carries_the_shared_install
    base = index_json.fetch("base")

    targets = base.fetch("files").map { |file| file.fetch("target") }
    assert_includes targets, "app/components/ui_component.rb"
    assert_includes targets, "app/helpers/ui_helper.rb"
    assert_includes targets, "vendor/shadwire/shadwire.css"
    base.fetch("files").each do |file|
      refute_empty file.fetch("content"), "base file #{file.fetch("target")} inlined empty content"
    end

    assert_includes base.fetch("gems"), "view_component"
    assert_includes base.fetch("gems"), "lucide-rails"

    assert_equal "4", base.fetch("tailwind").fetch("version").to_s
    assert_equal "shadwire.css", base.fetch("tailwind").fetch("css")
  end
end
