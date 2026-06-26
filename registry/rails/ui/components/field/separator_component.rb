# frozen_string_literal: true

module Ui
  module Field
    # A divider between fields, optionally with centered text (pass a block).
    class SeparatorComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(**wrapper_attrs) do
          safe_join([ separator, label ].compact)
        end
      end

      private

      def wrapper_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("relative -my-2 h-5 text-sm", @class_name)
          data = attrs.fetch(:data, {}).dup.merge(slot: "field-separator")
          data[:content] = "true" if content.present?
          attrs[:data] = data
        end
      end

      def separator
        render(Ui::SeparatorComponent.new(class: "absolute inset-0 top-1/2"))
      end

      def label
        return unless content.present?

        tag.span(content, class: "bg-background text-muted-foreground relative mx-auto block w-fit px-2")
      end
    end
  end
end
