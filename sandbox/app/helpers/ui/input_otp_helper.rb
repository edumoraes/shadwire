# frozen_string_literal: true

module Ui
  module InputOtpHelper
    def ui_input_otp(**options, &block)
      render(Ui::InputOtpComponent.new(**options), &block)
    end

    def ui_input_otp_group(**options, &block)
      render(Ui::InputOtp::GroupComponent.new(**options), &block)
    end

    def ui_input_otp_slot(**options)
      render(Ui::InputOtp::SlotComponent.new(**options))
    end

    def ui_input_otp_separator(**options)
      render(Ui::InputOtp::SeparatorComponent.new(**options))
    end
  end
end
