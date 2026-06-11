# frozen_string_literal: true

module Ui
  module RadioGroup
    class ItemComponent < UiComponent
      def initialize(name:, value:, checked: false, disabled: false, class_name: nil, **attrs)
        @name = name
        @value = value
        @checked = checked
        @disabled = disabled
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.input(type: "radio", name: @name, value: @value, **item_attrs)
      end

      private

      def item_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = item_classes
          attrs[:checked] = true if @checked
          attrs[:disabled] = true if @disabled
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "radio-group-item")
        end
      end

      def item_classes
        class_names(base_classes, @class_name)
      end

      def base_classes
        "shadwire-radio aspect-square size-4 shrink-0 appearance-none rounded-full border border-input bg-background shadow-xs transition-shadow outline-none checked:border-primary disabled:cursor-not-allowed disabled:opacity-50 focus-visible:ring-1 focus-visible:ring-ring aria-invalid:border-destructive dark:bg-input/30"
      end
    end
  end
end
