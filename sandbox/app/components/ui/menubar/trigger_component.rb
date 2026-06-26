# frozen_string_literal: true

module Ui
  module Menubar
    class TriggerComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.button(content, **trigger_attrs)
      end

      private

      def trigger_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:type] = attrs.fetch(:type, "button")
          attrs[:role] = attrs.fetch(:role, "menuitem")
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:aria] = { haspopup: "menu", expanded: "false" }.merge(attrs.fetch(:aria, {}))
          attrs[:data] = trigger_data(attrs[:data])
        end
      end

      def trigger_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "menubar-trigger"
          data[:ui_menubar_target] = append_token(data[:ui_menubar_target], "trigger")
          data[:action] = append_token(
            data[:action],
            "click->ui-menubar#toggle pointerenter->ui-menubar#triggerEnter keydown->ui-menubar#triggerKeydown"
          )
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def base_classes
        "flex select-none items-center rounded-sm px-3 py-1 text-sm font-medium outline-none focus:bg-accent focus:text-accent-foreground data-[state=open]:bg-accent data-[state=open]:text-accent-foreground"
      end
    end
  end
end
