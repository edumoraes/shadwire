# frozen_string_literal: true

module Ui
  module Table
    class CaptionComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.caption(content, **caption_attrs)
      end

      private

      def caption_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("mt-4 text-sm text-muted-foreground", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "table-caption")
        end
      end
    end
  end
end
