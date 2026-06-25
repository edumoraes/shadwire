# frozen_string_literal: true

module Ui
  module HoverCard
    # The floating card. Hidden until the ui-hover-card controller opens it.
    # `side`/`align` position it relative to the trigger like the popover.
    class ContentComponent < UiComponent
      SIDES = {
        top: "bottom-full mb-2",
        bottom: "top-full mt-2",
        left: "right-full mr-2",
        right: "left-full ml-2"
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

      def initialize(side: :bottom, align: :center, class_name: nil, **attrs)
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
          attrs[:hidden] = attrs.fetch(:hidden, true)
          attrs[:class] = content_classes
          attrs[:data] = content_data(attrs[:data])
        end
      end

      def content_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "hover-card-content"
          data[:ui_hover_card_target] = append_token(data[:ui_hover_card_target], "content")
        end
      end

      def content_classes
        class_names(
          base_classes,
          fetch_variant(SIDES, @side, fallback: :bottom),
          fetch_variant(align_mapping, @align, fallback: :center),
          @class_name
        )
      end

      def align_mapping
        horizontal_side? ? HORIZONTAL_ALIGNS : VERTICAL_ALIGNS
      end

      def horizontal_side?
        side_key = @side.presence&.to_sym
        [ :top, :bottom ].include?(side_key) || !SIDES.key?(side_key)
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def base_classes
        "absolute z-50 w-64 rounded-md border bg-popover p-4 text-popover-foreground shadow-md outline-none data-[state=open]:animate-popover-in"
      end
    end
  end
end
