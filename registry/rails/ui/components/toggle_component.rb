# frozen_string_literal: true

module Ui
  # A standalone two-state toggle button. `pressed: true` starts it on; the
  # `ui-toggle` controller flips `aria-pressed`/`data-state` on click.
  class ToggleComponent < UiComponent
    VARIANTS = {
      default: "bg-transparent",
      outline: "border border-input bg-transparent shadow-xs hover:bg-accent hover:text-accent-foreground"
    }.freeze

    SIZES = {
      default: "h-9 px-2 min-w-9",
      sm: "h-8 px-1.5 min-w-8",
      lg: "h-10 px-2.5 min-w-10"
    }.freeze

    def initialize(variant: :default, size: :default, pressed: false, disabled: false, class_name: nil, **attrs)
      @variant = variant
      @size = size
      @pressed = pressed
      @disabled = disabled
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.button(content, **toggle_attrs)
    end

    private

    def toggle_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:type] = attrs.fetch(:type, "button")
        attrs[:class] = toggle_classes
        attrs[:aria] = { pressed: @pressed ? "true" : "false" }.merge(attrs.fetch(:aria, {}))
        attrs[:disabled] = true if @disabled
        attrs[:data] = toggle_data(attrs[:data])
      end
    end

    def toggle_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "toggle"
        data[:state] = @pressed ? "on" : "off"
        data[:controller] = append_token(data[:controller], "ui-toggle")
        data[:ui_toggle_pressed_value] = @pressed
        data[:action] = append_token(data[:action], "click->ui-toggle#toggle")
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end

    def toggle_classes
      class_names(base_classes, fetch_variant(VARIANTS, @variant, fallback: :default), fetch_variant(SIZES, @size, fallback: :default), @class_name)
    end

    def base_classes
      "inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium whitespace-nowrap transition-colors outline-none hover:bg-muted hover:text-muted-foreground focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 data-[state=on]:bg-accent data-[state=on]:text-accent-foreground [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 [&_svg]:shrink-0"
    end
  end
end
