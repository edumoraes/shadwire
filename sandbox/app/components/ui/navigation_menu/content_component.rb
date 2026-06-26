# frozen_string_literal: true

module Ui
  module NavigationMenu
    # The disclosed panel for a navigation item. Hidden until its trigger opens it.
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
          attrs[:hidden] = attrs.fetch(:hidden, true)
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = content_data(attrs[:data])
        end
      end

      def content_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "navigation-menu-content"
          data[:ui_navigation_menu_target] = append_token(data[:ui_navigation_menu_target], "content")
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def base_classes
        "absolute left-0 top-full z-50 mt-1.5 w-max rounded-md border bg-popover p-4 text-popover-foreground shadow-md data-[state=open]:animate-popover-in"
      end
    end
  end
end
