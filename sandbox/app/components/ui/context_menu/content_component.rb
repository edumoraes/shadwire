# frozen_string_literal: true

module Ui
  module ContextMenu
    # The floating menu. Hidden until the controller opens it at the pointer.
    class ContentComponent < UiComponent
      def initialize(class_name: nil, **attrs)
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
          data[:slot] = "context-menu-content"
          data[:ui_context_menu_target] = append_token(data[:ui_context_menu_target], "content")
          data[:action] = append_token(data[:action], "keydown->ui-context-menu#keydown")
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def content_classes
        class_names(base_classes, @class_name)
      end

      def base_classes
        "absolute z-50 min-w-[8rem] overflow-hidden rounded-md border bg-popover p-1 text-popover-foreground shadow-md data-[state=open]:animate-popover-in"
      end
    end
  end
end
