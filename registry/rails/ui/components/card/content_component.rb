# frozen_string_literal: true

module Ui
  module Card
    class ContentComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **content_attrs)
      end

      private

      def content_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("p-6 pt-0", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "card-content")
        end
      end
    end
  end
end
