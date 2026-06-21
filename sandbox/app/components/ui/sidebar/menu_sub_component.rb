# frozen_string_literal: true

module Ui
  module Sidebar
    # A nested submenu list (`ul`) under a menu item. Hidden when collapsed.
    class MenuSubComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.ul(content, **menu_sub_attrs)
      end

      private

      def menu_sub_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = attrs.fetch(:data, {}).to_h.merge(slot: "sidebar-menu-sub")
        end
      end

      def base_classes
        "border-sidebar-border mx-3.5 flex min-w-0 translate-x-px flex-col gap-1 border-l px-2.5 py-0.5 group-data-[collapsible=icon]:hidden"
      end
    end
  end
end
