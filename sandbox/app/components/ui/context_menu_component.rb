# frozen_string_literal: true

module Ui
  # A right-click (context) menu. Wraps a trigger area and a hidden menu that the
  # ui-context-menu controller opens at the pointer. Compose a
  # `Ui::ContextMenu::TriggerComponent` and `ContentComponent`.
  class ContextMenuComponent < UiComponent
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
        attrs[:class] = class_names("relative", @class_name)
        attrs[:data] = menu_data(attrs[:data])
      end
    end

    def menu_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "context-menu"
        data[:controller] = append_token(data[:controller], "ui-context-menu")
        data[:action] = append_token(data[:action], "click@window->ui-context-menu#outsideClick")
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
