# frozen_string_literal: true

module Ui
  module InputOtp
    class GroupComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("flex items-center", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "input-otp-group")
        end)
      end
    end
  end
end
