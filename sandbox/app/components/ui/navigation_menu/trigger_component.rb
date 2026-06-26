# frozen_string_literal: true

module Ui
  module NavigationMenu
    # A button that discloses a content panel. Carries a chevron that rotates
    # while open (`data-state=open`).
    class TriggerComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.button(**trigger_attrs) do
          safe_join([ content, render(Ui::IconComponent.new("chevron-down", class: icon_classes)) ])
        end
      end

      private

      def trigger_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:type] = attrs.fetch(:type, "button")
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:aria] = { expanded: "false" }.merge(attrs.fetch(:aria, {}))
          attrs[:data] = trigger_data(attrs[:data])
        end
      end

      def trigger_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "navigation-menu-trigger"
          data[:ui_navigation_menu_target] = append_token(data[:ui_navigation_menu_target], "trigger")
          data[:action] = append_token(
            data[:action],
            "click->ui-navigation-menu#toggle pointerenter->ui-navigation-menu#openOn"
          )
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def base_classes
        "group inline-flex h-9 w-max items-center justify-center gap-1 rounded-md bg-background px-4 py-2 text-sm font-medium transition-colors hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:outline-none data-[state=open]:bg-accent/50"
      end

      def icon_classes
        "relative top-px size-3 transition-transform duration-200 group-data-[state=open]:rotate-180"
      end
    end
  end
end
