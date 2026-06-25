# frozen_string_literal: true

require "test_helper"

class InputOtpComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_input_otp(name: "code") do
        ui_input_otp_group do
          ui_input_otp_slot + ui_input_otp_slot
        end +
          ui_input_otp_separator +
          ui_input_otp_group do
            ui_input_otp_slot + ui_input_otp_slot
          end
      end
    end
  end

  def test_root_wires_controller_and_hidden_value
    render_inline(Ui::InputOtpComponent.new(name: "otp", value: "12")) { "x".html_safe }

    assert_selector "[data-controller='ui-input-otp'][data-slot='input-otp']"
    assert_selector "input[type='hidden'][name='otp'][value='12'][data-ui-input-otp-target='value']", visible: :all
  end

  def test_slot_is_single_char_input_with_actions
    render_inline(Ui::InputOtp::SlotComponent.new)

    assert_selector "input[data-slot='input-otp-slot'][maxlength='1'][inputmode='numeric'][data-ui-input-otp-target='slot']"
    assert_selector "input[data-action='input->ui-input-otp#input keydown->ui-input-otp#keydown paste->ui-input-otp#paste']"
  end

  def test_separator_role
    render_inline(Ui::InputOtp::SeparatorComponent.new)

    assert_selector "div[role='separator'][data-slot='input-otp-separator'] svg"
  end

  def test_helper_composes_grouped_slots
    render_inline(HelperHarnessComponent.new)

    assert_selector "[data-controller='ui-input-otp'] [data-slot='input-otp-group']", count: 2
    assert_selector "input[data-slot='input-otp-slot']", count: 4
    assert_selector "[data-slot='input-otp-separator']", count: 1
  end
end
