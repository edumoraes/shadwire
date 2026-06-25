# frozen_string_literal: true

require "test_helper"

class InputGroupComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_input_group do
        ui_input_group_addon { "@" } +
          ui_input_group_input(placeholder: "username") +
          ui_input_group_addon(align: :inline_end) do
            ui_input_group_button { "Go" }
          end
      end
    end
  end

  def test_root_is_a_group
    render_inline(Ui::InputGroupComponent.new) { "x" }

    assert_selector "div[role='group'][data-slot='input-group'].relative.flex", text: "x"
  end

  def test_addon_alignment_maps_to_data_align
    render_inline(Ui::InputGroup::AddonComponent.new(align: :block_end)) { "a" }

    assert_selector "div[data-slot='input-group-addon'][data-align='block-end']", text: "a"
  end

  def test_control_marks_input_group_control_slot
    render_inline(Ui::InputGroup::InputComponent.new(placeholder: "x"))

    assert_selector "input[data-slot='input-group-control'][placeholder='x'].border-0"
  end

  def test_helper_composes_group
    render_inline(HelperHarnessComponent.new)

    assert_selector "div[data-slot='input-group'] div[data-slot='input-group-addon'][data-align='inline-start']", text: "@"
    assert_selector "input[data-slot='input-group-control'][placeholder='username']"
    assert_selector "div[data-slot='input-group-addon'][data-align='inline-end'] button[data-slot='input-group-control']", text: "Go"
  end
end
