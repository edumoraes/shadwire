# frozen_string_literal: true

module Ui
  # A horizontal menubar of menus (WAI-ARIA menubar pattern), coordinated by the
  # ui-menubar controller. Compose `Ui::Menubar::MenuComponent`s, each with a
  # `TriggerComponent` and `ContentComponent`.
  class MenubarComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **menubar_attrs)
    end

    private

    def menubar_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:role] = attrs.fetch(:role, "menubar")
        attrs[:class] = class_names(base_classes, @class_name)
        attrs[:data] = menubar_data(attrs[:data])
      end
    end

    def menubar_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "menubar"
        data[:controller] = append_token(data[:controller], "ui-menubar")
        data[:action] = append_token(data[:action], "click@window->ui-menubar#outsideClick")
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end

    def base_classes
      "flex h-9 items-center gap-1 rounded-md border bg-background p-1 shadow-xs"
    end
  end
end
