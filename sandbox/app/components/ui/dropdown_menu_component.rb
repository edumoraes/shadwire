# frozen_string_literal: true

module Ui
  # A menu of actions opened from a button. CheckboxItem, RadioItem, and
  # submenus are intentionally out of scope for this version.
  class DropdownMenuComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **menu_attrs)
    end

    private

    def menu_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names("relative w-fit", @class_name)
        attrs[:data] = menu_data(attrs[:data])
      end
    end

    def menu_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "dropdown-menu"
        data[:controller] = append_token(data[:controller], "ui-dropdown-menu")
        data[:action] = append_token(data[:action], "click@window->ui-dropdown-menu#outsideClick")
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
