# frozen_string_literal: true

module Ui
  module InputGroup
    # Positioned content (icon, text, button) attached to an input group.
    # `align:` controls placement: `:inline_start`/`:inline_end` sit on the
    # sides, `:block_start`/`:block_end` span a full row above/below.
    class AddonComponent < UiComponent
      ALIGNMENTS = {
        inline_start: "order-first pl-3 has-[>button]:ml-[-0.45rem] has-[>kbd]:ml-[-0.35rem]",
        inline_end: "order-last pr-3 has-[>button]:mr-[-0.45rem] has-[>kbd]:mr-[-0.35rem]",
        block_start: "order-first w-full justify-start px-3 pt-3 [.border-b]:pb-3 group-has-[>input]/input-group:pt-2.5",
        block_end: "order-last w-full justify-start px-3 pb-3 [.border-t]:pt-3 group-has-[>input]/input-group:pb-2.5"
      }.freeze

      def initialize(align: :inline_start, class_name: nil, **attrs)
        @align = align
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(base_classes, fetch_variant(ALIGNMENTS, @align, fallback: :inline_start), @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "input-group-addon", align: @align.to_s.tr("_", "-"))
        end)
      end

      private

      def base_classes
        "text-muted-foreground flex h-auto cursor-text items-center justify-center gap-2 py-1.5 text-sm font-medium select-none [&>svg:not([class*='size-'])]:size-4 group-data-[disabled=true]/input-group:opacity-50"
      end
    end
  end
end
