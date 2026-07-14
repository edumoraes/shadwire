# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "json"
require "stringio"

class InfoTest < Minitest::Test
  FILE_REGISTRY = "file://#{File.expand_path("fixtures/registry", __dir__)}"

  def silent_ui(out: StringIO.new, err: StringIO.new)
    Shadwire::UI.new(out:, err:)
  end

  def run_info(name, root:, ui: silent_ui, **opts)
    Shadwire::Commands::Info.new(root:, name:, registry: FILE_REGISTRY, ui:, **opts).call
  end

  def test_info_returns_item_metadata
    Dir.mktmpdir do |root|
      result = run_info("data-table", root:)

      assert_equal "component", result["type"]
      assert_equal "Data Table", result["title"]
      assert_includes result["files"].map { |f| f["target"] },
                      "app/components/ui/data_table_component.rb"
      assert_equal %w[table button input checkbox dropdown-menu], result["registryDependencies"]
    end
  end

  def test_info_strips_file_content
    Dir.mktmpdir do |root|
      result = run_info("button", root:)

      result["files"].each do |file|
        refute file.key?("content"), "info must not leak file content"
        assert file.key?("target")
        assert file.key?("type")
      end
    end
  end

  def test_info_human_output_shows_title_and_targets
    Dir.mktmpdir do |root|
      out = StringIO.new
      run_info("chart", root:, ui: silent_ui(out:))

      assert_match(/Chart/, out.string)
      assert_match(%r{app/components/ui/chart_component\.rb}, out.string)
      assert_match(%r{chart\.js/auto}, out.string) # importmap pin surfaced
    end
  end

  def test_info_json_omits_content
    Dir.mktmpdir do |root|
      out = StringIO.new
      result = run_info("button", root:, json: true, ui: silent_ui(out:))

      parsed = JSON.parse(out.string)
      assert_equal result, parsed
      parsed["files"].each { |f| refute f.key?("content") }
    end
  end

  def test_info_unknown_item_raises_registry_error
    Dir.mktmpdir do |root|
      assert_raises(Shadwire::RegistryError) { run_info("nonexistent", root:) }
    end
  end
end
