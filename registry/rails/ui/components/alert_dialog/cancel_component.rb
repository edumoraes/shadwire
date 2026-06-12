# frozen_string_literal: true

module Ui
  module AlertDialog
    # The dismissing Button.
    class CancelComponent < UiComponent
      def initialize(variant: :outline, size: :default, class_name: nil, **attrs)
        @variant = variant
        @size = size
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        render(
          Ui::ButtonComponent.new(variant: @variant, size: @size, class_name: @class_name, **cancel_attrs)
        ) { content }
      end

      private

      def cancel_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "alert-dialog-cancel"
            data[:action] = append_token(data[:action], "click->ui-dialog#close")
          end
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
