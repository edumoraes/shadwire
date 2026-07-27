# frozen_string_literal: true

require "minitest/autorun"
require "pathname"
require_relative "../lib/shadwire_registry/api_extractor"

# The extractor is what keeps the published component API from drifting from the
# source it ships: everything here is derived from the .rb file, never written by
# hand. Assertions use real registry components rather than fixtures so a change
# to a component's signature surfaces here.
class ApiExtractorTest < Minitest::Test
  ROOT = Pathname.new(__dir__).join("..").expand_path
  COMPONENTS = ROOT.join("registry/rails/ui/components")

  def extract(relative)
    path = COMPONENTS.join(relative)
    ShadwireRegistry::ApiExtractor.call(source: path.read, path: path.to_s)
  end

  def test_extracts_the_class_name
    assert_equal "Ui::ButtonComponent", extract("button_component.rb").fetch("class")
  end

  def test_extracts_nested_subcomponent_class_names
    assert_equal "Ui::Card::HeaderComponent", extract("card/header_component.rb").fetch("class")
  end

  def test_extracts_variant_keys_in_source_order
    assert_equal %w[default destructive outline secondary ghost link],
                 extract("button_component.rb").fetch("variants")
  end

  def test_extracts_size_keys
    assert_equal %w[default sm lg icon], extract("button_component.rb").fetch("sizes")
  end

  def test_extracts_keyword_arguments_with_their_defaults
    props = extract("button_component.rb").fetch("props")

    assert_equal({ "name" => "tag", "default" => ":button" }, props.find { |p| p["name"] == "tag" })
    assert_equal({ "name" => "disabled", "default" => "false" }, props.find { |p| p["name"] == "disabled" })
    assert_equal({ "name" => "class_name", "default" => "nil" }, props.find { |p| p["name"] == "class_name" })
  end

  def test_reports_a_required_keyword_argument_with_no_default
    props = extract("tabs/trigger_component.rb").fetch("props")
    value = props.find { |prop| prop["name"] == "value" }

    refute_nil value, "expected a :value keyword on Ui::Tabs::TriggerComponent"
    assert_nil value.fetch("default"), "a required keyword must publish a nil default"
  end

  def test_reports_the_keyword_rest_as_free_html_attributes
    assert_equal true, extract("button_component.rb").fetch("attrs")
  end

  def test_components_without_variant_constants_publish_empty_lists
    api = extract("input_component.rb")

    assert_empty api.fetch("variants")
    assert_empty api.fetch("sizes")
  end

  def test_extracts_the_un_namespaced_shared_base_class
    # ui_component.rb defines UiComponent, the base every component subclasses.
    # It is deliberately not under the Ui namespace.
    assert_equal "UiComponent", extract("ui_component.rb").fetch("class")
  end

  def test_every_registry_component_extracts_without_error
    files = Dir[COMPONENTS.join("**/*.rb")]
    refute_empty files

    files.each do |file|
      api = ShadwireRegistry::ApiExtractor.call(source: File.read(file), path: file)

      refute_nil api["class"], "no class extracted from #{file}"
      next if File.basename(file) == "ui_component.rb"

      assert_match(/\AUi::/, api["class"], "#{file} produced an unexpected class: #{api["class"]}")
    end
  end

  def test_raises_on_unparsable_source
    error = assert_raises(ArgumentError) do
      ShadwireRegistry::ApiExtractor.call(source: "class Broken", path: "broken.rb")
    end

    assert_includes error.message, "broken.rb"
  end
end
