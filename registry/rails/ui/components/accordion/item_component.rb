# frozen_string_literal: true

module Ui
  module Accordion
    class ItemComponent < UiComponent
      def initialize(value: nil, disabled: false, class_name: nil, **attrs)
        @value = value
        @disabled = disabled
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **item_attrs)
      end

      private

      def item_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("border-b last:border-b-0", @class_name)
          attrs[:data] = item_data(attrs[:data])

          next unless @disabled

          attrs[:aria] = attrs.fetch(:aria, {}).dup.merge(disabled: "true")
        end
      end

      def item_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "accordion-item"
          data[:ui_accordion_target] = append_token(data[:ui_accordion_target], "item")
          data[:ui_accordion_value] = @value.to_s if @value.present?
          data[:disabled] = "" if @disabled
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
