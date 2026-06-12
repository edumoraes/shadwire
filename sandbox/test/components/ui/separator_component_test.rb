# frozen_string_literal: true

require "test_helper"

class SeparatorComponentTest < ViewComponent::TestCase
  def test_renders_horizontal_separator_with_base_ui_accessibility_attrs_by_default
    render_inline(Ui::SeparatorComponent.new)

    assert_selector "div[role='separator'][aria-orientation='horizontal'][data-orientation='horizontal'].h-px.w-full"
  end

  def test_renders_semantic_vertical_separator
    render_inline(Ui::SeparatorComponent.new(orientation: :vertical, class_name: "mx-2"))

    assert_selector "div[role='separator'][aria-orientation='vertical'][data-orientation='vertical'].h-full.w-px.mx-2"
  end

  def test_decorative_separator_is_hidden_from_assistive_technology
    render_inline(Ui::SeparatorComponent.new(decorative: true))

    assert_selector "div[role='none'][aria-hidden='true'][data-orientation='horizontal'].h-px.w-full"
    assert_no_selector "div[aria-orientation]"
  end

  def test_decorative_vertical_separator
    render_inline(Ui::SeparatorComponent.new(decorative: true, orientation: :vertical))

    assert_selector "div[role='none'][aria-hidden='true'][data-orientation='vertical'].h-full.w-px"
  end

  def test_merges_custom_data_and_aria_attributes
    render_inline(
      Ui::SeparatorComponent.new(
        data: { testid: "section-divider" },
        aria: { label: "Section divider" }
      )
    )

    assert_selector(
      "div[role='separator'][aria-orientation='horizontal'][aria-label='Section divider']" \
      "[data-orientation='horizontal'][data-testid='section-divider']"
    )
  end
end
