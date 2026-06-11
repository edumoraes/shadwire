# frozen_string_literal: true

module Ui
  module Table
    class HeadComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.th(content, **head_attrs)
      end

      private

      def head_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(
            "h-10 whitespace-nowrap px-2 text-left align-middle font-medium text-foreground",
            @class_name
          )
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "table-head")
        end
      end
    end
  end
end
