# frozen_string_literal: true

require "test_helper"

class SeparatorComponentTest < ViewComponent::TestCase
  def test_renders_decorative_separator_removed_from_a11y_tree
    render_inline(Ui::SeparatorComponent.new)

    assert_selector "div[role='none'].h-px.w-full"
    assert_no_selector "div[aria-hidden]"
  end

  def test_renders_semantic_vertical_separator
    render_inline(Ui::SeparatorComponent.new(orientation: :vertical, decorative: false, class_name: "mx-2"))

    assert_selector "div[role='separator'][aria-orientation='vertical'].h-full.w-px.mx-2"
  end
end
