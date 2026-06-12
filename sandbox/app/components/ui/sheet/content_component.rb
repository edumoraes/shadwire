# frozen_string_literal: true

module Ui
  module Sheet
    # The native <dialog> anchored to one edge of the screen.
    class ContentComponent < UiComponent
      SIDES = {
        right: "inset-y-0 right-0 left-auto h-full max-h-none w-3/4 border-l sm:max-w-sm data-[state=open]:animate-sheet-in-right data-[state=closed]:animate-sheet-out-right",
        left: "inset-y-0 left-0 right-auto h-full max-h-none w-3/4 border-r sm:max-w-sm data-[state=open]:animate-sheet-in-left data-[state=closed]:animate-sheet-out-left",
        top: "inset-x-0 top-0 bottom-auto h-auto w-full max-w-none border-b data-[state=open]:animate-sheet-in-top data-[state=closed]:animate-sheet-out-top",
        bottom: "inset-x-0 bottom-0 top-auto h-auto w-full max-w-none border-t data-[state=open]:animate-sheet-in-bottom data-[state=closed]:animate-sheet-out-bottom"
      }.freeze

      def initialize(side: :right, show_close_button: true, class_name: nil, **attrs)
        @side = side
        @show_close_button = show_close_button
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.dialog(**content_attrs) do
          safe_join([ content, close_button ].compact)
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
          data[:slot] = "sheet-content"
          data[:side] = side_key.to_s
          data[:ui_dialog_target] = append_token(data[:ui_dialog_target], "dialog")
          data[:action] = append_token(
            data[:action],
            "click->ui-dialog#backdropClick cancel->ui-dialog#cancel close->ui-dialog#closed"
          )
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def close_button
        return unless @show_close_button

        tag.button(type: "button", class: close_button_classes, data: { slot: "sheet-close-x", action: "click->ui-dialog#close" }) do
          safe_join([ render(Ui::IconComponent.new("x")), tag.span("Fechar", class: "sr-only") ])
        end
      end

      def close_button_classes
        "absolute right-4 top-4 rounded-xs opacity-70 transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:pointer-events-none"
      end

      def content_classes
        class_names(base_classes, fetch_variant(SIDES, @side, fallback: :right), @class_name)
      end

      def side_key
        key = @side.presence&.to_sym
        SIDES.key?(key) ? key : :right
      end

      # Resets the UA styles of <dialog> before anchoring it to an edge.
      def base_classes
        "fixed z-50 m-0 flex flex-col gap-4 bg-background text-foreground shadow-lg"
      end
    end
  end
end
