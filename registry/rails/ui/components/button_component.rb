# frozen_string_literal: true

module Ui
  class ButtonComponent < UiComponent
    VARIANTS = {
      default: "bg-primary text-primary-foreground shadow-xs hover:bg-primary/90",
      destructive: "bg-destructive text-destructive-foreground shadow-xs hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40",
      outline: "border border-input bg-background shadow-xs hover:bg-accent hover:text-accent-foreground dark:bg-input/30 dark:hover:bg-input/50",
      secondary: "bg-secondary text-secondary-foreground shadow-xs hover:bg-secondary/80",
      ghost: "hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50",
      link: "text-primary underline-offset-4 hover:underline"
    }.freeze

    SIZES = {
      default: "h-9 px-4 py-2",
      sm: "h-8 rounded-md px-3 text-xs",
      lg: "h-10 rounded-md px-6",
      icon: "size-9"
    }.freeze

    def initialize(
      variant: :default,
      size: :default,
      tag: :button,
      disabled: false,
      focusable_when_disabled: false,
      class_name: nil,
      **attrs
    )
      @variant = variant
      @size = size
      @tag = tag
      @disabled = disabled
      @focusable_when_disabled = focusable_when_disabled
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.public_send(@tag, content, **button_attrs)
    end

    private

    def button_attrs
      html_attrs.dup.merge(class: button_classes).tap do |attrs|
        attrs[:type] = "button" if native_button? && attrs[:type].blank?
        # Components built on a button (dialog triggers, pagination links, …)
        # pass a slot of their own, which wins over the generic one.
        attrs[:data] = { slot: "button" }.merge(attrs[:data].to_h)

        next unless @disabled

        attrs[:data] = attrs[:data].merge(disabled: "")

        if native_button? && !@focusable_when_disabled
          attrs[:disabled] = true
        else
          attrs[:aria] = attrs.fetch(:aria, {}).dup.merge(disabled: "true")
          attrs[:tabindex] = "0" if native_button?
        end
      end
    end

    def native_button?
      @tag.to_sym == :button
    end

    def button_classes
      class_names(
        base_classes,
        fetch_variant(VARIANTS, @variant, fallback: :default),
        fetch_variant(SIZES, @size, fallback: :default),
        @class_name
      )
    end

    def base_classes
      "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
    end
  end
end
