# frozen_string_literal: true

module Ui
  module Breadcrumb
    class ItemComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.li(content, **item_attrs)
      end

      private

      def item_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("inline-flex items-center gap-1.5", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "breadcrumb-item")
        end
      end
    end
  end
end
