# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/shadwire_registry/llms_writer"

# llms.txt is the fallback for agents that never install the skill or the CLI,
# so it has to be self-sufficient: how to install, what exists, and what each
# component's API is.
class LlmsWriterTest < Minitest::Test
  REGISTRY = {
    "name" => "shadwire",
    "version" => "0.2.0",
    "license" => "MIT",
    "licenseUrl" => "https://github.com/edumoraes/shadwire/blob/main/LICENSE",
    "attribution" => {
      "derivedFrom" => "shadcn/ui",
      "url" => "https://ui.shadcn.com",
      "license" => "MIT",
      "notice" => "Files installed into an application carry no attribution requirement of their own."
    }
  }.freeze

  ITEMS = [
    {
      "name" => "button",
      "title" => "Button",
      "description" => "Displays a button or a link styled as a button.",
      "whenToUse" => "Any clickable action.",
      "requiresStimulus" => false,
      "usage" => [%(<%= ui_button(variant: :outline) { "Save" } %>)],
      "api" => { "components" => [
        { "class" => "Ui::ButtonComponent", "helper" => "ui_button", "root" => true,
          "variants" => %w[default outline], "sizes" => %w[sm lg],
          "props" => [{ "name" => "tag", "default" => ":button" }], "attrs" => true }
      ] }
    },
    {
      "name" => "dropdown-menu",
      "title" => "Dropdown Menu",
      "description" => "A menu of actions triggered by a button.",
      "whenToUse" => "Row actions and overflow menus.",
      "requiresStimulus" => true,
      "usage" => [],
      "api" => { "components" => [
        { "class" => "Ui::DropdownMenuComponent", "helper" => "ui_dropdown_menu", "root" => true,
          "variants" => [], "sizes" => [], "props" => [], "attrs" => true },
        { "class" => "UiComponent", "helper" => nil, "root" => false,
          "variants" => [], "sizes" => [], "props" => [], "attrs" => false }
      ] }
    }
  ].freeze

  def index
    ShadwireRegistry::LlmsWriter.index(registry: REGISTRY, items: ITEMS)
  end

  def full
    ShadwireRegistry::LlmsWriter.full(registry: REGISTRY, items: ITEMS)
  end

  def test_index_states_the_version
    assert_includes index, "shadwire 0.2.0"
  end

  def test_index_explains_how_to_install
    assert_includes index, "gem install shadwire"
    assert_includes index, "shadwire add"
  end

  def test_index_lists_each_component_with_when_to_use
    assert_includes index, "button — Any clickable action."
    assert_includes index, "dropdown-menu — Row actions and overflow menus."
  end

  def test_index_points_at_the_full_reference
    assert_includes index, "llms-full.txt"
  end

  def test_full_includes_the_api
    assert_includes full, "Ui::ButtonComponent"
    assert_includes full, "ui_button"
    assert_includes full, "default | outline"
    assert_includes full, "tag: :button"
  end

  def test_full_includes_usage_as_erb_blocks
    assert_includes full, "```erb"
    assert_includes full, %(<%= ui_button(variant: :outline) { "Save" } %>)
  end

  def test_full_flags_stimulus_requirements
    assert_includes full, "Requires Stimulus"
  end

  def test_full_gives_the_install_command_per_component
    assert_includes full, "shadwire add dropdown-menu"
  end

  # Components with no ui_* wrapper would teach an agent a call it cannot make.
  def test_full_omits_components_without_a_helper
    refute_includes full, "UiComponent\n"
  end

  # These are the files most likely to be pasted into a model's context, so the
  # terms have to be in them and not only in the repository.
  def test_both_files_state_the_licence_and_what_it_derives_from
    [ index, full ].each do |text|
      assert_includes text, "## Licence"
      assert_includes text, "MIT — https://github.com/edumoraes/shadwire/blob/main/LICENSE"
      assert_includes text, "Ported from shadcn/ui (https://ui.shadcn.com), MIT."
      assert_includes text, "no attribution requirement"
    end
  end
end
