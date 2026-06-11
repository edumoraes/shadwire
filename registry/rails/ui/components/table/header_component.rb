# frozen_string_literal: true

module Ui
  module Table
    class HeaderComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.thead(content, **header_attrs)
      end

      private

      def header_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("[&_tr]:border-b", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "table-header")
        end
      end
    end
  end
end
