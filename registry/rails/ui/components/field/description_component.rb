# frozen_string_literal: true

module Ui
  module Field
    class DescriptionComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.p(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "field-description")
        end)
      end

      private

      def base_classes
        "text-muted-foreground text-sm leading-normal font-normal [&>a:hover]:text-primary [&>a]:underline [&>a]:underline-offset-4"
      end
    end
  end
end
