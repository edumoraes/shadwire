# frozen_string_literal: true

require "test_helper"

class SeparatorComponentTest < ViewComponent::TestCase
  def test_renders_horizontal_separator
    render_inline(Ui::SeparatorComponent.new)

    assert_selector "div[role='separator'][aria-orientation='horizontal'].h-px.w-full"
  end

  def test_renders_vertical_separator
    render_inline(Ui::SeparatorComponent.new(orientation: :vertical, class_name: "mx-2"))

    assert_selector "div[role='separator'][aria-orientation='vertical'].h-full.w-px.mx-2"
  end
end
