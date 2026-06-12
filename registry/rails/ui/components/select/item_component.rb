# frozen_string_literal: true

module Ui
  module Select
    # A selectable option. The controller toggles aria-selected and a check
    # indicator (data-state="checked") and drives highlight via data-highlighted.
    class ItemComponent < UiComponent
      def initialize(value:, disabled: false, class_name: nil, **attrs)
        @value = value
        @disabled = disabled
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(**item_attrs) do
          safe_join([ indicator, tag.span(content) ])
        end
      end

      private

      def item_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "option")
          attrs[:aria] = { selected: "false" }.merge(attrs.fetch(:aria, {}))
          attrs[:class] = item_classes
          attrs[:data] = item_data(attrs[:data])

          next unless @disabled

          attrs[:aria] = attrs[:aria].merge(disabled: "true")
        end
      end

      def item_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "select-item"
          data[:ui_select_target] = append_token(data[:ui_select_target], "item")
          data[:value] = @value.to_s
          data[:action] = append_token(data[:action], "click->ui-select#select mouseenter->ui-select#highlight")
          data[:disabled] = "" if @disabled
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def indicator
        tag.span(
          class: "absolute right-2 flex size-3.5 items-center justify-center",
          data: { slot: "select-item-indicator" }
        ) do
          render(Ui::IconComponent.new("check", class: "size-4"))
        end
      end

      def item_classes
        class_names(base_classes, @class_name)
      end

      def base_classes
        "relative flex w-full cursor-default select-none items-center gap-2 rounded-sm py-1.5 pr-8 pl-2 text-sm outline-none data-[highlighted]:bg-accent data-[highlighted]:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&[data-state=checked]_[data-slot=select-item-indicator]]:opacity-100 [&:not([data-state=checked])_[data-slot=select-item-indicator]]:opacity-0"
      end
    end
  end
end
