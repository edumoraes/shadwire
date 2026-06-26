# frozen_string_literal: true

module Ui
  module ButtonGroup
    # A non-interactive labelled segment inside a `Ui::ButtonGroupComponent`.
    class TextComponent < UiComponent
      def initialize(tag: :div, class_name: nil, **attrs)
        @tag = tag
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.public_send(@tag, content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "button-group-text")
        end)
      end

      private

      def base_classes
        "bg-muted flex items-center gap-2 rounded-md border px-4 text-sm font-medium shadow-xs [&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none"
      end
    end
  end
end
