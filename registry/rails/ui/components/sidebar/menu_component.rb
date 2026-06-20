# frozen_string_literal: true

module Ui
  module Sidebar
    # The list (`ul`) of menu items within a group.
    class MenuComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.ul(content, **menu_attrs)
      end

      private

      def menu_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("flex w-full min-w-0 flex-col gap-1", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).to_h.merge(slot: "sidebar-menu")
        end
      end
    end
  end
end
