# frozen_string_literal: true

module Ui
  module ScrollArea
    class CornerComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(**corner_attrs)
      end

      private

      def corner_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:aria] = { hidden: "true" }.merge(attrs.fetch(:aria, {}))
          attrs[:class] = class_names("absolute right-0 bottom-0 size-2.5 bg-background", @class_name)
          attrs[:data] = corner_data(attrs[:data])
        end
      end

      def corner_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "scroll-area-corner"
          data[:ui_scroll_area_target] = append_token(data[:ui_scroll_area_target], "corner")
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
