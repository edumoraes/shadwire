# frozen_string_literal: true

module Ui
  module InputGroup
    # A multi-line control inside an `Ui::InputGroupComponent`.
    class TextareaComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.textarea(content, **textarea_attrs)
      end

      private

      def textarea_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "input-group-control")
        end
      end

      def base_classes
        "flex-1 resize-none rounded-none border-0 bg-transparent px-3 py-3 shadow-none outline-none w-full min-w-0 text-base md:text-sm placeholder:text-muted-foreground focus-visible:ring-0 disabled:cursor-not-allowed disabled:opacity-50 dark:bg-transparent"
      end
    end
  end
end
