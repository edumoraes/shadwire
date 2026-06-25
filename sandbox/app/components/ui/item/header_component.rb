# frozen_string_literal: true

module Ui
  module Item
    class HeaderComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("flex basis-full items-center justify-between gap-2", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "item-header")
        end)
      end
    end
  end
end
