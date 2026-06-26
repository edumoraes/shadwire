# frozen_string_literal: true

module Ui
  module Field
    class ContentComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("group/field-content flex flex-1 flex-col gap-1.5 leading-snug", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "field-content")
        end)
      end
    end
  end
end
