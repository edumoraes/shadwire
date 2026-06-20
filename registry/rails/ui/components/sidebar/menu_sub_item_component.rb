# frozen_string_literal: true

module Ui
  module Sidebar
    # A row (`li`) within a submenu.
    class MenuSubItemComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.li(content, **menu_sub_item_attrs)
      end

      private

      def menu_sub_item_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("group/menu-sub-item relative", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).to_h.merge(slot: "sidebar-menu-sub-item")
        end
      end
    end
  end
end
