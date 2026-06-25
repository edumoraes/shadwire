# frozen_string_literal: true

module Ui
  module InputGroup
    # The text control inside an `Ui::InputGroupComponent`. Strips its own
    # border/ring so the surrounding group draws the frame.
    class InputComponent < UiComponent
      def initialize(type: :text, class_name: nil, **attrs)
        @type = type
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.input(type: @type, **input_attrs)
      end

      private

      def input_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "input-group-control")
        end
      end

      def base_classes
        "flex-1 rounded-none border-0 bg-transparent px-3 shadow-none outline-none h-full w-full min-w-0 text-base md:text-sm placeholder:text-muted-foreground focus-visible:ring-0 disabled:cursor-not-allowed disabled:opacity-50 dark:bg-transparent"
      end
    end
  end
end
