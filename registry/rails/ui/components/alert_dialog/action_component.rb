# frozen_string_literal: true

module Ui
  module AlertDialog
    # The confirming Button. It closes the dialog; add your own action
    # (e.g. data: { action: "click->my-controller#destroy" } or a form).
    class ActionComponent < UiComponent
      def initialize(variant: :default, size: :default, class_name: nil, **attrs)
        @variant = variant
        @size = size
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        render(
          Ui::ButtonComponent.new(variant: @variant, size: @size, class_name: @class_name, **action_attrs)
        ) { content }
      end

      private

      def action_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "alert-dialog-action"
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
