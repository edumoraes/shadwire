# frozen_string_literal: true

module Ui
  module Sidebar
    # The clickable element of a submenu row. Renders an `<a>` by default.
    class MenuSubButtonComponent < UiComponent
      SIZES = {
        sm: "text-xs",
        md: "text-sm"
      }.freeze

      def initialize(is_active: false, size: :md, tag: :a, class_name: nil, **attrs)
        @is_active = is_active
        @size = size
        @tag = tag
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.public_send(@tag, content, **menu_sub_button_attrs)
      end

      private

      def menu_sub_button_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:type] = "button" if @tag.to_sym == :button && attrs[:type].blank?
          attrs[:class] = class_names(base_classes, fetch_variant(SIZES, @size, fallback: :md), @class_name)
          attrs[:data] = menu_sub_button_data(attrs[:data])
        end
      end

      def menu_sub_button_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "sidebar-menu-sub-button"
          data[:size] = @size.to_s
          data[:active] = "true" if @is_active
        end
      end

      def base_classes
        "text-sidebar-foreground ring-sidebar-ring hover:bg-sidebar-accent hover:text-sidebar-accent-foreground active:bg-sidebar-accent active:text-sidebar-accent-foreground [&>svg]:text-sidebar-accent-foreground data-[active=true]:bg-sidebar-accent data-[active=true]:text-sidebar-accent-foreground flex h-7 min-w-0 -translate-x-px items-center gap-2 overflow-hidden rounded-md px-2 outline-hidden focus-visible:ring-2 disabled:pointer-events-none disabled:opacity-50 aria-disabled:pointer-events-none aria-disabled:opacity-50 group-data-[collapsible=icon]:hidden [&>span:last-child]:truncate [&>svg]:size-4 [&>svg]:shrink-0"
      end
    end
  end
end
