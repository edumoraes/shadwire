# frozen_string_literal: true

module Ui
  module NavigationMenu
    class ListComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.ul(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("group flex flex-1 list-none items-center justify-center gap-1", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "navigation-menu-list")
        end)
      end
    end
  end
end
