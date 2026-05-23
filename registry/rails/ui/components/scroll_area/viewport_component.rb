# frozen_string_literal: true

module Ui
  module ScrollArea
    class ViewportComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **viewport_attrs)
      end

      private

      def viewport_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:tabindex] = attrs.fetch(:tabindex, 0)
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = viewport_data(attrs[:data])
        end
      end

      def viewport_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "scroll-area-viewport"
          data[:ui_scroll_area_target] = append_token(data[:ui_scroll_area_target], "viewport")
          data[:action] = append_token(data[:action], "scroll->ui-scroll-area#scroll")
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def base_classes
        "shadwire-scroll-area-viewport size-full overflow-scroll rounded-[inherit] outline-none transition-[color,box-shadow] focus-visible:ring-ring/50 focus-visible:ring-[3px] focus-visible:outline-1"
      end
    end
  end
end
