# frozen_string_literal: true

require "test_helper"

class AspectRatioComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_aspect_ratio(ratio: "16 / 9", class: "rounded-md") { "media" }
    end
  end

  def test_renders_square_by_default
    render_inline(Ui::AspectRatioComponent.new) { "media" }

    assert_selector "div[data-slot='aspect-ratio'][style*='aspect-ratio: 1']", text: "media"
  end

  def test_accepts_custom_ratio_and_preserves_inline_style
    render_inline(Ui::AspectRatioComponent.new(ratio: "16 / 9", style: "background: red")) { "x" }

    assert_selector "div[style*='aspect-ratio: 16 / 9'][style*='background: red']"
  end

  def test_helper_renders_aspect_ratio
    render_inline(HelperHarnessComponent.new)

    assert_selector "div[data-slot='aspect-ratio'].rounded-md[style*='aspect-ratio: 16 / 9']", text: "media"
  end
end
