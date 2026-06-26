# frozen_string_literal: true

module Ui
  module Drawer
    # The native <dialog> drawer anchored to one edge, with a drag handle on the
    # block-axis edges (top/bottom).
    class ContentComponent < UiComponent
      SIDES = {
        bottom: "inset-x-0 bottom-0 top-auto mt-24 h-auto max-h-[90vh] w-full max-w-none rounded-t-lg border-t data-[state=open]:animate-sheet-in-bottom data-[state=closed]:animate-sheet-out-bottom",
        top: "inset-x-0 top-0 bottom-auto mb-24 h-auto max-h-[90vh] w-full max-w-none rounded-b-lg border-b data-[state=open]:animate-sheet-in-top data-[state=closed]:animate-sheet-out-top",
        right: "inset-y-0 right-0 left-auto h-full max-h-none w-3/4 border-l sm:max-w-sm data-[state=open]:animate-sheet-in-right data-[state=closed]:animate-sheet-out-right",
        left: "inset-y-0 left-0 right-auto h-full max-h-none w-3/4 border-r sm:max-w-sm data-[state=open]:animate-sheet-in-left data-[state=closed]:animate-sheet-out-left"
      }.freeze

      def initialize(side: :bottom, class_name: nil, **attrs)
        @side = side
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.dialog(**content_attrs) do
          safe_join([ handle, content ].compact)
        end
      end

      private

      def content_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = content_classes
          attrs[:data] = content_data(attrs[:data])
        end
      end

      def content_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "drawer-content"
          data[:side] = side_key.to_s
          data[:ui_drawer_target] = append_token(data[:ui_drawer_target], "dialog")
          data[:action] = append_token(
            data[:action],
            "click->ui-drawer#backdropClick cancel->ui-drawer#cancel close->ui-drawer#closed"
          )
        end
      end

      def handle
        return unless [ :top, :bottom ].include?(side_key)

        tag.div(
          class: "bg-muted mx-auto mt-4 h-2 w-24 shrink-0 cursor-grab touch-none rounded-full",
          aria: { hidden: "true" },
          data: { slot: "drawer-handle", action: "pointerdown->ui-drawer#dragStart" }
        )
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def content_classes
        class_names(base_classes, fetch_variant(SIDES, @side, fallback: :bottom), @class_name)
      end

      def side_key
        key = @side.presence&.to_sym
        SIDES.key?(key) ? key : :bottom
      end

      def base_classes
        "fixed z-50 m-0 flex flex-col gap-4 bg-background p-4 text-foreground shadow-lg"
      end
    end
  end
end
