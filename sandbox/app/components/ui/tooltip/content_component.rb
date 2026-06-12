# frozen_string_literal: true

module Ui
  module Tooltip
    # The floating label. Hidden until the ui-tooltip controller opens it;
    # positioned with absolute utilities relative to the tooltip root.
    class ContentComponent < UiComponent
      SIDES = {
        top: "bottom-full left-1/2 mb-1.5 -translate-x-1/2",
        bottom: "top-full left-1/2 mt-1.5 -translate-x-1/2",
        left: "right-full top-1/2 mr-1.5 -translate-y-1/2",
        right: "left-full top-1/2 ml-1.5 -translate-y-1/2"
      }.freeze

      def initialize(side: :top, class_name: nil, **attrs)
        @side = side
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **content_attrs)
      end

      private

      def content_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "tooltip")
          attrs[:hidden] = attrs.fetch(:hidden, true)
          attrs[:class] = content_classes
          attrs[:data] = content_data(attrs[:data])
        end
      end

      def content_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "tooltip-content"
          data[:ui_tooltip_target] = append_token(data[:ui_tooltip_target], "content")
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def content_classes
        class_names(base_classes, fetch_variant(SIDES, @side, fallback: :top), @class_name)
      end

      def base_classes
        "absolute z-50 w-max max-w-xs text-balance rounded-md bg-primary px-3 py-1.5 text-xs text-primary-foreground shadow-md data-[state=open]:animate-tooltip-in"
      end
    end
  end
end
