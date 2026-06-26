# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "pathname"

# Structural validation of registry/registry.json, complementing the file/target
# checks in registry_manifest_test.rb. Encodes the invariants the publish
# manifest and bin/sync_registry rely on, without fetching the remote $schema.
class RegistrySchemaTest < Minitest::Test
  ROOT = Pathname.new(__dir__).join("..").expand_path
  REGISTRY = JSON.parse(ROOT.join("registry/registry.json").read)
  KEBAB = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/
  ITEM_TYPES = %w[component block].freeze

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
