# frozen_string_literal: true

module Ui
  module Table
    class RowComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.tr(content, **row_attrs)
      end

      private

      def row_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(
            "border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted",
            @class_name
          )
          attrs[:data] = attrs.fetch(:data, {}).dup.tap { |data| data[:slot] = "table-row" }
        end
      end
    end
  end
end
