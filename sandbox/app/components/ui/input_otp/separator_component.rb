# frozen_string_literal: true

module Ui
  module InputOtp
    # A visual divider between OTP groups.
    class SeparatorComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(**html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "separator")
          attrs[:class] = class_names("text-muted-foreground", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "input-otp-separator")
        end) do
          helpers.lucide_icon("minus", class: "size-4", "aria-hidden": "true")
        end
      end
    end
  end
end
