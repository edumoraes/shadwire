# frozen_string_literal: true

require "test_helper"

class ToggleGroupComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_toggle_group(type: :multiple, variant: :outline) do
        ui_toggle_group_item(value: "bold", pressed: true) { "B" } +
          ui_toggle_group_item(value: "italic") { "I" }
      end
    end
  end

  def test_root_wires_controller_and_type
    render_inline(Ui::ToggleGroupComponent.new(type: :multiple)) { "x" }

    assert_selector "div[role='group'][data-slot='toggle-group'][data-controller='ui-toggle-group'][data-ui-toggle-group-type-value='multiple']", text: "x"
  end

  def test_item_wires_target_and_actions
    render_inline(Ui::ToggleGroup::ItemComponent.new(value: "bold", pressed: true)) { "B" }

    assert_selector "button[data-slot='toggle-group-item'][data-value='bold'][data-state='on'][aria-pressed='true'][data-ui-toggle-group-target='item']", text: "B"
    assert_selector "button[data-action='click->ui-toggle-group#select keydown->ui-toggle-group#keydown']"
  end

  def test_helper_renders_group_with_items
    render_inline(HelperHarnessComponent.new)

    assert_selector "div[data-controller='ui-toggle-group'][data-variant='outline'] button[data-slot='toggle-group-item']", count: 2
    assert_selector "button[data-value='bold'][data-state='on']", text: "B"
    assert_selector "button[data-value='italic'][data-state='off']", text: "I"
  end
end
