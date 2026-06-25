# frozen_string_literal: true

module Ui
  module NavigationMenu
    class ItemComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.li(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("relative", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "navigation-menu-item")
        end)
      end
    end
  end
end
