# frozen_string_literal: true

module Ui
  module Sidebar
    # A small action button pinned to the right of a menu item (e.g. a "more"
    # menu). `show_on_hover: true` reveals it only on hover/focus of the row.
    class MenuActionComponent < UiComponent
      def initialize(show_on_hover: false, tag: :button, class_name: nil, **attrs)
        @show_on_hover = show_on_hover
        @tag = tag
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.public_send(@tag, content, **menu_action_attrs)
      end

      private

      def menu_action_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:type] = "button" if @tag.to_sym == :button && attrs[:type].blank?
          attrs[:class] = class_names(base_classes, hover_classes, @class_name)
          attrs[:data] = attrs.fetch(:data, {}).to_h.merge(slot: "sidebar-menu-action", sidebar: "menu-action")
        end
      end

      def hover_classes
        return nil unless @show_on_hover

        "peer-data-[active=true]/menu-button:text-sidebar-accent-foreground group-focus-within/menu-item:opacity-100 group-hover/menu-item:opacity-100 data-[state=open]:opacity-100 md:opacity-0"
      end

      def base_classes
        "text-sidebar-foreground ring-sidebar-ring hover:bg-sidebar-accent hover:text-sidebar-accent-foreground peer-hover/menu-button:text-sidebar-accent-foreground absolute top-1.5 right-1 flex aspect-square w-5 items-center justify-center rounded-md p-0 outline-hidden transition-transform focus-visible:ring-2 [&>svg]:size-4 [&>svg]:shrink-0 after:absolute after:-inset-2 md:after:hidden peer-data-[size=sm]/menu-button:top-1 peer-data-[size=default]/menu-button:top-1.5 peer-data-[size=lg]/menu-button:top-2.5 group-data-[collapsible=icon]:hidden"
      end
    end
  end
end
