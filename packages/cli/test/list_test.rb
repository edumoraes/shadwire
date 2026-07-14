# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "json"
require "stringio"

class ListTest < Minitest::Test
  FILE_REGISTRY = "file://#{File.expand_path("fixtures/registry", __dir__)}"

  def silent_ui(out: StringIO.new, err: StringIO.new)
    Shadwire::UI.new(out:, err:)
  end

  def run_list(root:, ui: silent_ui, **opts)
    Shadwire::Commands::List.new(root:, registry: FILE_REGISTRY, ui:, **opts).call
  end

  def test_list_returns_every_catalog_item
    Dir.mktmpdir do |root|
      result = run_list(root:)

      names = result.map { |item| item["name"] }
      assert_includes names, "button"
      assert_includes names, "data-table"
      assert_equal 13, result.size
    end
  end

  def test_list_works_without_a_shadwire_json
    Dir.mktmpdir do |root|
      refute File.exist?(File.join(root, "shadwire.json"))
      assert_equal 13, run_list(root:).size
    end
  end

  def test_list_human_output_shows_names_and_titles
    Dir.mktmpdir do |root|
      out = StringIO.new
      run_list(root:, ui: silent_ui(out:))

      assert_match(/button/, out.string)
      assert_match(/Button/, out.string)
    end
  end

  def test_list_json_emits_the_catalog_array
    Dir.mktmpdir do |root|
      out = StringIO.new
      result = run_list(root:, json: true, ui: silent_ui(out:))

      assert_equal result, JSON.parse(out.string)
      assert_equal 13, JSON.parse(out.string).size
    end
  end
end
