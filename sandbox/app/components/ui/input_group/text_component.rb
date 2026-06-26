# frozen_string_literal: true

module Ui
  module InputGroup
    class TextComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.span(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "input-group-text")
        end)
      end

      private

      def base_classes
        "text-muted-foreground flex items-center gap-2 text-sm [&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none"
      end
    end
  end
end
