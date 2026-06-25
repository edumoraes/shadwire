# frozen_string_literal: true

module Ui
  module Item
    class ContentComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("flex flex-1 flex-col gap-1 [&+[data-slot=item-content]]:flex-none", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "item-content")
        end)
      end
    end
  end
end
