# frozen_string_literal: true

module Ui
  module ScrollArea
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
          attrs[:class] = class_names("min-w-full", @class_name)
          attrs[:data] = content_data(attrs[:data])
        end
      end

      def content_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "scroll-area-content"
        end
      end
    end
  end
end
