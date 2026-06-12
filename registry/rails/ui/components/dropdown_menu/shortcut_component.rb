# frozen_string_literal: true

module Ui
  module DropdownMenu
    # A right-aligned keyboard hint inside a menu item (purely visual).
    class ShortcutComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.span(content, **shortcut_attrs)
      end

      private

      def shortcut_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("ml-auto text-xs tracking-widest text-muted-foreground", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "dropdown-menu-shortcut")
        end
      end
    end
  end
end
