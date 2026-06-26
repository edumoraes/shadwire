# frozen_string_literal: true

module Ui
  module NavigationMenu
    # A navigation link. Pass `active: true` to mark the current page.
    class LinkComponent < UiComponent
      def initialize(active: false, class_name: nil, **attrs)
        @active = active
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.a(content, **link_attrs)
      end

      private

      def link_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:aria] = attrs.fetch(:aria, {}).dup.merge(current: "page") if @active
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "navigation-menu-link"
            data[:active] = "" if @active
          end
        end
      end

      def base_classes
        "flex select-none flex-col gap-1 rounded-md p-2 text-sm leading-none no-underline outline-none transition-colors hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground data-[active]:bg-accent/50"
      end
    end
  end
end
