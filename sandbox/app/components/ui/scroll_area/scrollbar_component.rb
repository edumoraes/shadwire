# frozen_string_literal: true

module Ui
  module ScrollArea
    class ScrollbarComponent < UiComponent
      ORIENTATION_CLASSES = {
        vertical: "top-0 right-0 h-full w-2.5 border-l border-l-transparent",
        horizontal: "bottom-0 left-0 h-2.5 w-full flex-col border-t border-t-transparent"
      }.freeze

      def initialize(orientation: :vertical, class_name: nil, **attrs)
        @orientation = orientation_value(orientation)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(**scrollbar_attrs) do
          content.presence || render(Ui::ScrollArea::ThumbComponent.new)
        end
      end

      private

      def scrollbar_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:aria] = { hidden: "true" }.merge(attrs.fetch(:aria, {}))
          attrs[:class] = class_names(base_classes, fetch_variant(ORIENTATION_CLASSES, @orientation, fallback: :vertical), @class_name)
          attrs[:data] = scrollbar_data(attrs[:data])
        end
      end

      def scrollbar_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "scroll-area-scrollbar"
          data[:orientation] = @orientation
          data[:ui_scroll_area_target] = append_token(data[:ui_scroll_area_target], "scrollbar")
          data[:action] = append_token(
            data[:action],
            "pointerdown->ui-scroll-area#trackPointerDown click->ui-scroll-area#trackPointerDown pointerenter->ui-scroll-area#hoverStart pointerleave->ui-scroll-area#hoverEnd"
          )
        end
      end

      def orientation_value(orientation)
        key = orientation.presence&.to_sym
        ORIENTATION_CLASSES.key?(key) ? key : :vertical
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def base_classes
        "absolute z-10 flex touch-none p-px transition-colors select-none"
      end
    end
  end
end
