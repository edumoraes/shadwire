# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "json"
require "stringio"

class SearchTest < Minitest::Test
  FILE_REGISTRY = "file://#{File.expand_path("fixtures/registry", __dir__)}"

  def silent_ui(out: StringIO.new, err: StringIO.new)
    Shadwire::UI.new(out:, err:)
  end

  def run_search(query, root:, ui: silent_ui, **opts)
    Shadwire::Commands::Search.new(root:, query:, registry: FILE_REGISTRY, ui:, **opts).call
  end

  def test_search_matches_name_title_and_description
    Dir.mktmpdir do |root|
      result = run_search("table", root:)

      names = result.map { |item| item["name"] }
      assert_includes names, "table"          # name + title match
      assert_includes names, "data-table"     # description "...filterable table"
      assert_equal %w[table data-table], names
    end
  end

  def test_search_is_case_insensitive
    Dir.mktmpdir do |root|
      names = run_search("BUTTON", root:).map { |item| item["name"] }
      assert_equal %w[button], names
    end
  end

  def test_search_with_no_match_returns_empty
    Dir.mktmpdir do |root|
      out = StringIO.new
      result = run_search("zzzznope", root:, ui: silent_ui(out:))

      assert_empty result
      assert_match(/no match/i, out.string)
    end
  end

  def test_search_json_emits_matches
    Dir.mktmpdir do |root|
      out = StringIO.new
      result = run_search("table", root:, json: true, ui: silent_ui(out:))

      assert_equal result, JSON.parse(out.string)
    end
  end
end
