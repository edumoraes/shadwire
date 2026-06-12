# frozen_string_literal: true

module Ui
  module Dialog
    # The native <dialog> element. Closed by default; the ui-dialog
    # controller opens it with showModal().
    class ContentComponent < UiComponent
      def initialize(show_close_button: true, class_name: nil, **attrs)
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
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = content_data(attrs[:data])
        end
      end

      def content_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "dialog-content"
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

        tag.button(type: "button", class: close_button_classes, data: { slot: "dialog-close-x", action: "click->ui-dialog#close" }) do
          safe_join([ render(Ui::IconComponent.new("x")), tag.span("Fechar", class: "sr-only") ])
        end
      end

      def close_button_classes
        "absolute right-4 top-4 rounded-xs opacity-70 transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:pointer-events-none"
      end

      # Resets the UA styles of <dialog> (margin, max sizes, border, padding)
      # before applying the shadcn panel look.
      def base_classes
        "fixed left-[50%] top-[50%] z-50 m-0 grid w-full max-w-[calc(100%-2rem)] translate-x-[-50%] translate-y-[-50%] gap-4 rounded-lg border bg-background p-6 text-foreground shadow-lg sm:max-w-lg data-[state=open]:animate-dialog-in data-[state=closed]:animate-dialog-out"
      end
    end
  end
end
