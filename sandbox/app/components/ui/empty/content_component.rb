# frozen_string_literal: true

module Ui
  module Empty
    class ContentComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "empty-content")
        end)
      end

      private

      def base_classes
        "flex w-full max-w-sm min-w-0 flex-col items-center gap-4 text-sm text-balance"
      end
    end
  end
end
