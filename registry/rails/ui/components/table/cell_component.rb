# frozen_string_literal: true

module Ui
  module Table
    class CellComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.td(content, **cell_attrs)
      end

      private

      def cell_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("whitespace-nowrap p-2 align-middle", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "table-cell")
        end
      end
    end
  end
end
