# frozen_string_literal: true

module Ui
  module Menubar
    class ContentComponent < UiComponent
      def initialize(align: :start, class_name: nil, **attrs)
        @align = align
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **content_attrs)
      end

      private

      ALIGNS = { start: "left-0", center: "left-1/2 -translate-x-1/2", end: "right-0" }.freeze

      def content_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "menu")
          attrs[:tabindex] = attrs.fetch(:tabindex, "-1")
          attrs[:hidden] = attrs.fetch(:hidden, true)
          attrs[:class] = class_names(base_classes, fetch_variant(ALIGNS, @align, fallback: :start), @class_name)
          attrs[:data] = content_data(attrs[:data])
        end
      end

      def content_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "menubar-content"
          data[:ui_menubar_target] = append_token(data[:ui_menubar_target], "content")
          data[:action] = append_token(data[:action], "keydown->ui-menubar#contentKeydown")
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def base_classes
        "absolute top-full z-50 mt-1 min-w-[12rem] overflow-hidden rounded-md border bg-popover p-1 text-popover-foreground shadow-md data-[state=open]:animate-popover-in"
      end
    end
  end
end
