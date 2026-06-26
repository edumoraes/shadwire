# frozen_string_literal: true

module Ui
  # A one-time-password input. Compose `Ui::InputOtp::GroupComponent`s of
  # `SlotComponent`s (optionally split by `SeparatorComponent`s); the combined
  # value is mirrored into a hidden input named `name:`.
  class InputOtpComponent < UiComponent
    def initialize(name: nil, value: nil, class_name: nil, **attrs)
      @name = name
      @value = value
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(**otp_attrs) do
        safe_join([ content, hidden_input ].compact)
      end
    end

    private

    def otp_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names("flex items-center gap-2 has-[:disabled]:opacity-50", @class_name)
        attrs[:data] = otp_data(attrs[:data])
      end
    end

    def otp_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "input-otp"
        data[:controller] = append_token(data[:controller], "ui-input-otp")
      end
    end

    def hidden_input
      return unless @name.present?

      tag.input(type: "hidden", name: @name, value: @value, data: { ui_input_otp_target: "value" })
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
