# frozen_string_literal: true

module Ui
  module ScrollArea
    class ThumbComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(**thumb_attrs)
      end

      private

      def thumb_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("relative flex-1 rounded-full bg-border", @class_name)
          attrs[:data] = thumb_data(attrs[:data])
        end
      end

      def thumb_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "scroll-area-thumb"
          data[:ui_scroll_area_target] = append_token(data[:ui_scroll_area_target], "thumb")
          data[:action] = append_token(data[:action], "pointerdown->ui-scroll-area#thumbPointerDown")
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
