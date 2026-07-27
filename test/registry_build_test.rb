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

  # There is no humanized fallback any more: prose is published exactly as
  # written, so a title like "Input OTP" survives instead of becoming "Input Otp".
  def test_prose_is_published_verbatim
    otp = item_json("input-otp")
    assert_equal "Input OTP", otp.fetch("title")
    refute_equal "Input Otp", otp.fetch("description")
  end

  def test_when_to_use_and_usage_are_published
    button = item_json("button")
    assert_includes button.fetch("whenToUse"), "clickable action"
    refute_empty button.fetch("usage")
    assert_includes button.fetch("usage").first, "ui_button"
  end

  def test_index_entries_carry_when_to_use_for_search
    entry = index_json.fetch("items").find { |item| item.fetch("name") == "dropdown-menu" }
    refute_empty entry.fetch("whenToUse")
  end

  # The build must refuse to publish an item with placeholder prose rather than
  # silently humanizing its name.
  def test_build_fails_when_required_prose_is_missing
    Dir.mktmpdir("shadwire-prose") do |dir|
      source = JSON.parse(ROOT.join("registry/registry.json").read)
      source.fetch("items").first.delete("whenToUse")

      registry_dir = Pathname.new(dir).join("registry")
      FileUtils.mkdir_p(registry_dir)
      FileUtils.cp_r(ROOT.join("registry/rails").to_s, registry_dir.to_s)
      registry_dir.join("registry.json").write(JSON.generate(source))
      FileUtils.cp_r(ROOT.join("bin").to_s, dir)
      FileUtils.cp_r(ROOT.join("lib").to_s, dir) if ROOT.join("lib").directory?

      output = `cd #{dir.shellescape} && BUILD_DIR=#{dir.shellescape}/out ruby bin/build_registry 2>&1`

      refute $?.success?, "build should fail on missing prose, got:\n#{output}"
      assert_includes output, "missing required prose"
    end
  end

  # The API block is generated from source by ShadwireRegistry::ApiExtractor, so
  # an agent can read a component's real signature before installing it.
  def test_item_carries_the_generated_api
    button = item_json("button").fetch("api").fetch("components")
                                .find { |component| component["class"] == "Ui::ButtonComponent" }

    refute_nil button
    assert_equal "ui_button", button.fetch("helper")
    assert_equal true, button.fetch("root")
    assert_includes button.fetch("variants"), "destructive"
    assert_includes button.fetch("sizes"), "icon"
    assert_equal true, button.fetch("attrs")
  end

  def test_subcomponents_are_published_as_non_root_entries
    header = item_json("card").fetch("api").fetch("components")
                              .find { |component| component["class"] == "Ui::Card::HeaderComponent" }

    refute_nil header
    assert_equal false, header.fetch("root")
    assert_equal "ui_card_header", header.fetch("helper")
  end

  # 28 of 58 items ship a Stimulus controller and need importmap with eager
  # loading; the flag lets an agent check before installing.
  def test_stimulus_requirement_is_published
    assert_equal true, item_json("dropdown-menu").fetch("requiresStimulus")
    assert_equal false, item_json("button").fetch("requiresStimulus")
  end

  def test_every_published_component_resolves_a_helper
    %w[button card dialog field sidebar].each do |name|
      item_json(name).fetch("api").fetch("components").each do |component|
        next if component["class"] == "UiComponent" # shared base, has no helper

        refute_nil component["helper"], "#{name}: #{component["class"]} resolved no helper"
      end
    end
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
    assert_includes targets, "vendor/shadwire/shadwire.css"
    # Helpers are per-item, not part of the shared base install.
    refute_includes targets, "app/helpers/ui_helper.rb"
    base.fetch("files").each do |file|
      refute_empty file.fetch("content"), "base file #{file.fetch("target")} inlined empty content"
    end

    assert_includes base.fetch("gems"), "view_component"
    assert_includes base.fetch("gems"), "lucide-rails"

    assert_equal "4", base.fetch("tailwind").fetch("version").to_s
    assert_equal "shadwire.css", base.fetch("tailwind").fetch("css")
  end
end
