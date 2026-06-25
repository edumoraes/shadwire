# frozen_string_literal: true

module Ui
  module Command
    # A selectable command. `value:` overrides the text used for filtering and is
    # reported in the `ui-command:select` event.
    class ItemComponent < UiComponent
      def initialize(value: nil, disabled: false, class_name: nil, **attrs)
        @value = value
        @disabled = disabled
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **item_attrs)
      end

      private

      def item_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "option")
          attrs[:aria] = { selected: "false" }.merge(attrs.fetch(:aria, {}))
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = item_data(attrs[:data])

          attrs[:aria] = attrs[:aria].merge(disabled: "true") if @disabled
        end
      end

      def item_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "command-item"
          data[:value] = @value.to_s if @value.present?
          data[:ui_command_target] = append_token(data[:ui_command_target], "item")
          data[:action] = append_token(data[:action], "click->ui-command#select")
          data[:disabled] = "" if @disabled
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def base_classes
        "relative flex cursor-default select-none items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-none data-[active=true]:bg-accent data-[active=true]:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0"
      end
    end
  end
end
