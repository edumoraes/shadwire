# frozen_string_literal: true

module Ui
  module InputOtp
    # A single character cell. Renders a one-character `<input>` wired to the
    # ui-input-otp controller for auto-advance, backspace and paste handling.
    class SlotComponent < UiComponent
      def initialize(value: nil, inputmode: "numeric", disabled: false, class_name: nil, **attrs)
        @value = value
        @inputmode = inputmode
        @disabled = disabled
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.input(**slot_attrs)
      end

      private

      def slot_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:type] = attrs.fetch(:type, "text")
          attrs[:inputmode] = @inputmode
          attrs[:maxlength] = attrs.fetch(:maxlength, 1)
          attrs[:autocomplete] = attrs.fetch(:autocomplete, "one-time-code")
          attrs[:value] = @value if @value.present?
          attrs[:disabled] = true if @disabled
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = slot_data(attrs[:data])
        end
      end

      def slot_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "input-otp-slot"
          data[:ui_input_otp_target] = append_token(data[:ui_input_otp_target], "slot")
          data[:action] = append_token(data[:action], "input->ui-input-otp#input keydown->ui-input-otp#keydown paste->ui-input-otp#paste")
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def base_classes
        "border-input relative flex h-9 w-9 items-center justify-center border-y border-r text-center text-sm shadow-xs outline-none transition-all first:rounded-l-md first:border-l last:rounded-r-md focus:z-10 focus:border-ring focus:ring-[3px] focus:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50"
      end
    end
  end
end
