# frozen_string_literal: true

module Ui
  # A navigation menu: a row of links and disclosure triggers that open content
  # panels, driven by the ui-navigation-menu controller. Compose a
  # `Ui::NavigationMenu::ListComponent` of `ItemComponent`s.
  class NavigationMenuComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.nav(content, **nav_attrs)
    end

    private

    def nav_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names("relative flex max-w-max flex-1 items-center justify-center", @class_name)
        attrs[:data] = nav_data(attrs[:data])
      end
    end

    def nav_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "navigation-menu"
        data[:controller] = append_token(data[:controller], "ui-navigation-menu")
        data[:action] = append_token(
          data[:action],
          "click@window->ui-navigation-menu#outsideClick keydown.esc->ui-navigation-menu#closeOnEscape " \
          "pointerleave->ui-navigation-menu#scheduleClose pointerenter->ui-navigation-menu#cancelClose"
        )
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
