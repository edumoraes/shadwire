# frozen_string_literal: true

require "test_helper"

class SliderComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_slider(min: 0, max: 100, step: 5, value: 40, name: "volume", label: "Volume")
    end
  end

  def test_root_wires_controller_and_values
    render_inline(Ui::SliderComponent.new(min: 0, max: 10, step: 2, value: 4))

    assert_selector "[data-controller='ui-slider'][data-slot='slider'][data-ui-slider-min-value='0'][data-ui-slider-max-value='10'][data-ui-slider-step-value='2'][data-ui-slider-value-value='4']"
  end

  def test_thumb_exposes_aria_slider_semantics
    render_inline(Ui::SliderComponent.new(min: 0, max: 100, value: 25, label: "Brilho"))

    assert_selector "span[role='slider'][tabindex='0'][aria-valuemin='0'][aria-valuemax='100'][aria-valuenow='25'][aria-label='Brilho'][data-ui-slider-target='thumb']"
    assert_selector "[data-slot='slider-range'][style*='width: 25']"
  end

  def test_hidden_input_for_form_submission
    render_inline(Ui::SliderComponent.new(value: 30, name: "level"))

    assert_selector "input[type='hidden'][name='level'][value='30'][data-ui-slider-target='input']", visible: :all
  end

  def test_helper_renders_slider
    render_inline(HelperHarnessComponent.new)

    assert_selector "[data-controller='ui-slider'][data-ui-slider-value-value='40']"
    assert_selector "span[role='slider'][aria-valuenow='40'][aria-label='Volume']"
  end
end
