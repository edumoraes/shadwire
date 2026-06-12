# frozen_string_literal: true

module Ui
  module AlertDialog
    # The native <dialog> with role="alertdialog" and no corner close button.
    class ContentComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.dialog(content, **content_attrs)
      end

      private

      def content_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "alertdialog")
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = content_data(attrs[:data])
        end
      end

      def content_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "alert-dialog-content"
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

      # Resets the UA styles of <dialog> (margin, max sizes, border, padding)
      # before applying the shadcn panel look.
      def base_classes
        "fixed left-[50%] top-[50%] z-50 m-0 grid w-full max-w-[calc(100%-2rem)] translate-x-[-50%] translate-y-[-50%] gap-4 rounded-lg border bg-background p-6 text-foreground shadow-lg sm:max-w-lg data-[state=open]:animate-dialog-in data-[state=closed]:animate-dialog-out"
      end
    end
  end
end
