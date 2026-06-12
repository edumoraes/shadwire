# frozen_string_literal: true

module Ui
  module DropdownMenu
    # A Button that opens the surrounding menu.
    class TriggerComponent < UiComponent
      def initialize(variant: :outline, size: :default, class_name: nil, **attrs)
        @variant = variant
        @size = size
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        render(
          Ui::ButtonComponent.new(variant: @variant, size: @size, class_name: @class_name, **trigger_attrs)
        ) { content }
      end

      private

      def trigger_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:aria] = { haspopup: "menu", expanded: "false" }.merge(attrs.fetch(:aria, {}))
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "dropdown-menu-trigger"
            data[:ui_dropdown_menu_target] = append_token(data[:ui_dropdown_menu_target], "trigger")
            data[:action] = append_token(
              data[:action],
              "click->ui-dropdown-menu#toggle keydown->ui-dropdown-menu#triggerKeydown"
            )
          end
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
