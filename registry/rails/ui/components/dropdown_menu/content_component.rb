# frozen_string_literal: true

module Ui
  module DropdownMenu
    # The menu surface. Hidden until the controller opens it; positioned with
    # absolute utilities like the popover (side offset + cross-axis align).
    class ContentComponent < UiComponent
      SIDES = {
        top: "bottom-full mb-1",
        bottom: "top-full mt-1",
        left: "right-full mr-1",
        right: "left-full ml-1"
      }.freeze

      HORIZONTAL_ALIGNS = {
        start: "left-0",
        center: "left-1/2 -translate-x-1/2",
        end: "right-0"
      }.freeze

      VERTICAL_ALIGNS = {
        start: "top-0",
        center: "top-1/2 -translate-y-1/2",
        end: "bottom-0"
      }.freeze

      def initialize(side: :bottom, align: :start, class_name: nil, **attrs)
        @side = side
        @align = align
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **content_attrs)
      end

      private

      def content_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "menu")
          attrs[:tabindex] = attrs.fetch(:tabindex, "-1")
          attrs[:hidden] = attrs.fetch(:hidden, true)
          attrs[:class] = content_classes
          attrs[:data] = content_data(attrs[:data])
        end
      end

      def content_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "dropdown-menu-content"
          data[:ui_dropdown_menu_target] = append_token(data[:ui_dropdown_menu_target], "content")
          data[:action] = append_token(data[:action], "keydown->ui-dropdown-menu#keydown")
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def content_classes
        class_names(
          base_classes,
          fetch_variant(SIDES, @side, fallback: :bottom),
          fetch_variant(align_mapping, @align, fallback: :start),
          @class_name
        )
      end

      def align_mapping
        side_key = @side.presence&.to_sym
        vertical = [ :left, :right ].include?(side_key)
        vertical ? VERTICAL_ALIGNS : HORIZONTAL_ALIGNS
      end

      def base_classes
        "absolute z-50 min-w-[8rem] overflow-hidden rounded-md border bg-popover p-1 text-popover-foreground shadow-md outline-none data-[state=open]:animate-popover-in"
      end
    end
  end
end
