# frozen_string_literal: true

require "test_helper"

class ProgressComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_progress(value: 33, aria: { label: "Enviando arquivo" })
    end
  end

  def test_renders_progressbar_with_aria_values
    render_inline(Ui::ProgressComponent.new(value: 40))

    assert_selector "[role='progressbar'][aria-valuemin='0'][aria-valuemax='100'][aria-valuenow='40'][data-slot='progress']"
    assert_selector "[data-slot='progress-indicator'][style*='translateX(-60%)']"
  end

  def test_clamps_value_into_range
    render_inline(Ui::ProgressComponent.new(value: 150))

    assert_selector "[role='progressbar'][aria-valuenow='100']"
    assert_selector "[data-slot='progress-indicator'][style*='translateX(-0%)']"
  end

  def test_supports_custom_max
    render_inline(Ui::ProgressComponent.new(value: 5, max: 20))

    assert_selector "[role='progressbar'][aria-valuemax='20'][aria-valuenow='5']"
    assert_selector "[data-slot='progress-indicator'][style*='translateX(-75%)']"
  end

  def test_accepts_class_alias_and_html_attrs
    render_inline(Ui::ProgressComponent.new(value: 10, class: "h-1", data: { testid: "upload" }))

    assert_selector "[role='progressbar'].h-1[data-testid='upload']"
  end

  def test_helper_renders_progress
    render_inline(HelperHarnessComponent.new)

    assert_selector "[role='progressbar'][aria-valuenow='33'][aria-label='Enviando arquivo']"
  end
end
