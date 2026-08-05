# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "pathname"
require "set"

# Structural validation of registry/registry.json, complementing the file/target
# checks in registry_manifest_test.rb. Encodes the invariants the publish
# manifest and bin/sync_registry rely on, without fetching the remote $schema.
class RegistrySchemaTest < Minitest::Test
  ROOT = Pathname.new(__dir__).join("..").expand_path
  REGISTRY = JSON.parse(ROOT.join("registry/registry.json").read)
  KEBAB = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/
  ITEM_TYPES = %w[component block].freeze

  # Which item owns a component file, by its path under app/components/ui/.
  # An item owns `<name>_component.rb`, anything under `<name>/`, and anything
  # prefixed `<name>_` (resizable_panel_component.rb belongs to `resizable`).
  # Longest prefix wins, so input_group_component.rb resolves to `input-group`
  # rather than `input`.
  PREFIXES = REGISTRY.fetch("items").to_h { |item|
    snake = item.fetch("name").tr("-", "_")
    [item.fetch("name"), item.fetch("type") == "block" ? "blocks/#{snake}" : snake]
  }.freeze

  def owner_for(path)
    REGISTRY.fetch("items").select { |item|
      prefix = PREFIXES[item.fetch("name")]
      path == "#{prefix}_component.rb" || path.start_with?("#{prefix}/") || path.start_with?("#{prefix}_")
    }.max_by { |item| PREFIXES[item.fetch("name")].length }&.fetch("name")
  end

  def helper_source_for(name)
    ROOT.join("registry/rails/ui/helpers/ui/#{name.tr("-", "_")}_helper.rb")
  end

  # Every component file an item bundles must arrive with the helper module that
  # wraps it, otherwise the install defines a component with no ui_* helper.
  def test_items_ship_helpers_for_every_component_they_bundle
    REGISTRY.fetch("items").each do |item|
      targets = item.fetch("files").map { |file| file.fetch("target") }
      helpers = targets.select { |target| target.start_with?("app/helpers/ui/") }

      targets.select { |target| target.start_with?("app/components/ui/") }.each do |target|
        owner = owner_for(target.sub("app/components/ui/", ""))
        next unless owner && helper_source_for(owner).file?

        assert_includes helpers, "app/helpers/ui/#{owner.tr("-", "_")}_helper.rb",
                        "#{item.fetch("name")} ships #{target} without its helper module"
      end
    end
  end

  # The inverse: no item may ship a helper for a component it does not bundle.
  def test_items_do_not_ship_orphan_helpers
    REGISTRY.fetch("items").each do |item|
      targets = item.fetch("files").map { |file| file.fetch("target") }
      owners = targets.select { |target| target.start_with?("app/components/ui/") }
                      .filter_map { |target| owner_for(target.sub("app/components/ui/", "")) }.uniq

      targets.select { |target| target.start_with?("app/helpers/ui/") }.each do |helper|
        name = File.basename(helper, "_helper.rb")
        assert_includes owners.map { |owner| owner.tr("-", "_") }, name,
                        "#{item.fetch("name")} ships #{helper} but none of its components need it"
      end
    end
  end

  # Prose an AST cannot infer. The published registry is the agent-facing
  # discovery surface, so these are required rather than defaulted: a humanized
  # fallback made `shadwire search form` match nothing while ten form components
  # existed.
  REQUIRED_PROSE = %w[title description whenToUse].freeze

  def test_every_item_has_hand_written_prose
    REGISTRY.fetch("items").each do |item|
      REQUIRED_PROSE.each do |key|
        value = item[key]

        refute_nil value, "#{item.fetch("name")} is missing #{key}"
        refute_empty value.to_s.strip, "#{item.fetch("name")} has an empty #{key}"
      end
    end
  end

  def test_descriptions_are_not_just_the_humanized_name
    REGISTRY.fetch("items").each do |item|
      humanized = item.fetch("name").split("-").map(&:capitalize).join(" ")

      refute_equal humanized, item["description"],
                   "#{item.fetch("name")} description is a placeholder"
    end
  end

  def test_component_items_carry_erb_usage_snippets
    REGISTRY.fetch("items").select { |item| item.fetch("type") == "component" }.each do |item|
      snippets = Array(item["usage"])

      refute_empty snippets, "#{item.fetch("name")} has no usage snippet"
      snippets.each do |snippet|
        assert_includes snippet, "<%", "#{item.fetch("name")} usage is not ERB: #{snippet}"
      end
    end
  end

  # A usage snippet that calls a helper nothing defines would teach an agent a
  # method that raises at request time.
  def test_usage_snippets_only_call_helpers_that_exist
    defined_helpers = Dir[ROOT.join("registry/rails/ui/helpers/ui/*.rb")]
                        .flat_map { |file| File.read(file).scan(/def (ui_\w+)/).flatten }.to_set

    REGISTRY.fetch("items").each do |item|
      Array(item["usage"]).each do |snippet|
        snippet.scan(/\bui_[a-z_0-9]+\b(?!:)/).uniq.each do |helper|
          assert_includes defined_helpers, helper,
                          "#{item.fetch("name")} usage calls #{helper}, which no helper module defines"
        end
      end
    end
  end

  def test_every_helper_module_source_exists_and_is_namespaced
    Dir[ROOT.join("registry/rails/ui/helpers/ui/*.rb")].each do |file|
      base = File.basename(file, "_helper.rb")
      expected = base.split("_").map { |part| part[0].upcase + part[1..] }.join

      assert_includes File.read(file), "module #{expected}Helper",
                      "#{file} does not define Ui::#{expected}Helper"
    end
  end

  def test_top_level_keys_are_present
    %w[name version framework dependencies tailwind items].each do |key|
      assert REGISTRY.key?(key), "registry.json is missing top-level key: #{key}"
    end
  end

  def test_framework_is_rails
    assert_equal "rails", REGISTRY.fetch("framework")
  end

  def test_version_is_semver
    assert_match(/\A\d+\.\d+\.\d+\z/, REGISTRY.fetch("version"), "version must be MAJOR.MINOR.PATCH")
  end

  def test_item_names_are_unique_and_kebab_case
    names = REGISTRY.fetch("items").map { |item| item.fetch("name") }

    names.each { |name| assert_match KEBAB, name, "item name is not kebab-case: #{name}" }

    duplicates = names.tally.select { |_, count| count > 1 }.keys
    assert_empty duplicates, "duplicate item names: #{duplicates.join(", ")}"
  end

  def test_item_types_are_known
    REGISTRY.fetch("items").each do |item|
      assert_includes ITEM_TYPES, item.fetch("type"), "#{item.fetch("name")} has unknown type: #{item.fetch("type")}"
    end
  end

  def test_items_have_non_empty_files_with_registry_relative_sources
    REGISTRY.fetch("items").each do |item|
      files = item.fetch("files")
      refute_empty files, "#{item.fetch("name")} declares no files"

      files.each do |file|
        source = file.fetch("source")
        target = file.fetch("target")
        assert source.is_a?(String) && !source.empty?, "#{item.fetch("name")} has a file with a blank source"
        assert target.is_a?(String) && !target.empty?, "#{item.fetch("name")} has a file with a blank target"
        assert source.start_with?("registry/"), "#{item.fetch("name")} source must live under registry/: #{source}"
      end
    end
  end

  def test_no_target_maps_to_two_different_sources
    # Mirrors the conflict guard in bin/sync_registry, but across the whole manifest.
    by_target = {}

    REGISTRY.fetch("items").each do |item|
      item.fetch("files").each do |file|
        target = file.fetch("target")
        source = file.fetch("source")
        if by_target.key?(target) && by_target[target] != source
          flunk "target #{target} maps to both #{by_target[target]} and #{source}"
        end
        by_target[target] = source
      end
    end
  end

  def test_registry_dependencies_reference_known_items
    names = REGISTRY.fetch("items").map { |item| item.fetch("name") }

    REGISTRY.fetch("items").each do |item|
      Array(item["registryDependencies"]).each do |dependency|
        assert_includes names, dependency, "#{item.fetch("name")} depends on unknown item: #{dependency}"
      end
    end
  end

  def test_top_level_gems_is_an_array_of_non_empty_strings
    gems = REGISTRY.fetch("gems")
    assert gems.is_a?(Array), "top-level gems must be an array"
    refute_empty gems, "top-level gems must list the base install gems"
    gems.each do |gem|
      assert gem.is_a?(String) && !gem.empty?, "top-level gems entry is not a non-empty string: #{gem.inspect}"
    end
  end

  def test_optional_item_gems_are_non_empty_strings
    REGISTRY.fetch("items").each do |item|
      next unless item.key?("gems")

      gems = item.fetch("gems")
      assert gems.is_a?(Array), "#{item.fetch("name")} gems must be an array"
      gems.each do |gem|
        assert gem.is_a?(String) && !gem.empty?, "#{item.fetch("name")} gems entry is not a non-empty string: #{gem.inspect}"
      end
    end
  end

  def test_optional_item_importmap_pins_are_name_to_objects
    REGISTRY.fetch("items").each do |item|
      next unless item.key?("importmap")

      pins = item.fetch("importmap")
      assert pins.is_a?(Array), "#{item.fetch("name")} importmap must be an array"
      refute_empty pins, "#{item.fetch("name")} importmap must not be empty when present"

      pins.each do |pin|
        assert pin.is_a?(Hash), "#{item.fetch("name")} importmap entry must be an object"
        %w[name to].each do |key|
          value = pin[key]
          assert value.is_a?(String) && !value.empty?, "#{item.fetch("name")} importmap entry is missing a string #{key}: #{pin.inspect}"
        end
      end
    end
  end

  # The published payload is fetched on its own, so the terms have to be in it.
  # bin/build_registry copies these into index.json and every r/{name}.json.
  def test_registry_declares_its_licence_as_an_spdx_identifier
    license = REGISTRY.fetch("license")

    assert license.is_a?(String) && !license.empty?, "license must be a non-empty SPDX identifier"
    assert_match(/\A[A-Za-z0-9.\-+ ]+\z/, license, "license must look like an SPDX identifier: #{license.inspect}")
    assert_match(%r{\Ahttps://}, REGISTRY.fetch("licenseUrl"), "licenseUrl must be an absolute URL")
  end

  # What Shadwire derives from is the part a reader cannot guess from the source.
  def test_registry_attributes_what_it_derives_from
    attribution = REGISTRY.fetch("attribution")

    assert attribution.is_a?(Hash), "attribution must be an object"
    %w[derivedFrom url license notice].each do |key|
      value = attribution[key]
      assert value.is_a?(String) && !value.empty?, "attribution is missing a non-empty #{key}"
    end
    assert_match(%r{\Ahttps://}, attribution.fetch("url"), "attribution url must be absolute")
  end

  def test_optional_item_title_and_description_are_strings
    REGISTRY.fetch("items").each do |item|
      %w[title description].each do |key|
        next unless item.key?(key)

        value = item.fetch(key)
        assert value.is_a?(String) && !value.empty?, "#{item.fetch("name")} #{key} is not a non-empty string: #{value.inspect}"
      end
    end
  end
end
