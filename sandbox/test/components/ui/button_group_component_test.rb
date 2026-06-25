# frozen_string_literal: true

require "test_helper"

class ButtonGroupComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_button_group do
        ui_button(variant: :outline) { "Prev" } +
          ui_button_group_separator +
          ui_button(variant: :outline) { "Next" }
      end
    end
  end

  def test_root_is_horizontal_group_by_default
    render_inline(Ui::ButtonGroupComponent.new) { "x" }

    assert_selector "div[role='group'][data-slot='button-group'][data-orientation='horizontal']", text: "x"
  end

  def test_vertical_orientation
    render_inline(Ui::ButtonGroupComponent.new(orientation: :vertical)) { "x" }

    assert_selector "div[data-slot='button-group'][data-orientation='vertical'].flex-col"
  end

  def test_text_segment
    render_inline(Ui::ButtonGroup::TextComponent.new) { "https://" }

    assert_selector "div[data-slot='button-group-text'].bg-muted", text: "https://"
  end

  def test_helper_composes_group_with_separator
    render_inline(HelperHarnessComponent.new)

    assert_selector "div[data-slot='button-group'] button", count: 2
    assert_selector "div[data-slot='button-group'] [data-slot='button-group-separator'][role='separator']"
  end
end
