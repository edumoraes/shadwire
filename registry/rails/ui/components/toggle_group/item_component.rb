# frozen_string_literal: true

module Ui
  module ToggleGroup
    # One toggle inside an `Ui::ToggleGroupComponent`. `value:` identifies it in
    # the group's emitted value; `pressed: true` starts it on.
    class ItemComponent < UiComponent
      VARIANTS = {
        default: "bg-transparent",
        outline: "border border-input bg-transparent shadow-xs hover:bg-accent hover:text-accent-foreground"
      }.freeze

      SIZES = {
        default: "h-9 px-2 min-w-9",
        sm: "h-8 px-1.5 min-w-8",
        lg: "h-10 px-2.5 min-w-10"
      }.freeze

      def initialize(value: nil, variant: :default, size: :default, pressed: false, disabled: false, class_name: nil, **attrs)
        @value = value
        @variant = variant
        @size = size
        @pressed = pressed
        @disabled = disabled
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.button(content, **item_attrs)
      end

      private

      def item_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:type] = attrs.fetch(:type, "button")
          attrs[:class] = item_classes
          attrs[:aria] = { pressed: @pressed ? "true" : "false" }.merge(attrs.fetch(:aria, {}))
          attrs[:disabled] = true if @disabled
          attrs[:data] = item_data(attrs[:data])
        end
      end

      def item_data(existing_data)
        existing_data.to_h.dup.tap do |data|
          data[:slot] = "toggle-group-item"
          data[:state] = @pressed ? "on" : "off"
          data[:value] = @value.to_s if @value.present?
          data[:ui_toggle_group_target] = append_token(data[:ui_toggle_group_target], "item")
          data[:action] = append_token(data[:action], "click->ui-toggle-group#select keydown->ui-toggle-group#keydown")
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def item_classes
        class_names(base_classes, fetch_variant(VARIANTS, @variant, fallback: :default), fetch_variant(SIZES, @size, fallback: :default), @class_name)
      end

      def base_classes
        "inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium whitespace-nowrap transition-colors outline-none hover:bg-muted hover:text-muted-foreground focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 data-[state=on]:bg-accent data-[state=on]:text-accent-foreground first:rounded-l-md last:rounded-r-md [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 [&_svg]:shrink-0"
      end
    end
  end
end
