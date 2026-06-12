# frozen_string_literal: true

module Ui
  module Tooltip
    # A Button that the surrounding tooltip describes.
    class TriggerComponent < UiComponent
      def initialize(variant: :outline, size: :default, class_name: nil, **attrs)
        @variant = variant
        @size = size
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        render(
          Ui::ButtonComponent.new(variant: @variant, size: @size, class_name: @class_name, **trigger_attrs)
        ) { content }
      end

      private

      def trigger_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "tooltip-trigger"
            data[:ui_tooltip_target] = append_token(data[:ui_tooltip_target], "trigger")
          end
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
