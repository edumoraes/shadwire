# frozen_string_literal: true

module Ui
  module Select
    class LabelComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **label_attrs)
      end

      private

      def label_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("px-2 py-1.5 text-xs text-muted-foreground", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "select-label")
        end
      end
    end
  end
end
