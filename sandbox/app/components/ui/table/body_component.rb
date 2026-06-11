# frozen_string_literal: true

module Ui
  module Table
    class BodyComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.tbody(content, **body_attrs)
      end

      private

      def body_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("[&_tr:last-child]:border-0", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "table-body")
        end
      end
    end
  end
end
