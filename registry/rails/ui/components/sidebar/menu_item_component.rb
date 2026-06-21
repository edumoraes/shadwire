# frozen_string_literal: true

module Ui
  module Sidebar
    # A single menu row (`li`); the positioning context for actions/badges.
    class MenuItemComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.li(content, **menu_item_attrs)
      end

      private

      def menu_item_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("group/menu-item relative", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).to_h.merge(slot: "sidebar-menu-item")
        end
      end
    end
  end
end
