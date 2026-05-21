# frozen_string_literal: true

module Ui
  class ButtonComponent < UiComponent
    VARIANTS = {
      default: "bg-primary text-primary-foreground shadow-xs hover:bg-primary/90",
      destructive: "bg-destructive text-destructive-foreground shadow-xs hover:bg-destructive/90",
      outline: "border border-input bg-background shadow-xs hover:bg-accent hover:text-accent-foreground",
      secondary: "bg-secondary text-secondary-foreground shadow-xs hover:bg-secondary/80",
      ghost: "hover:bg-accent hover:text-accent-foreground",
      link: "text-primary underline-offset-4 hover:underline"
    }.freeze

    SIZES = {
      default: "h-9 px-4 py-2",
      sm: "h-8 rounded-md px-3 text-xs",
      lg: "h-10 rounded-md px-6",
      icon: "size-9"
    }.freeze

    def initialize(variant: :default, size: :default, tag: :button, class_name: nil, **attrs)
      @variant = variant
      @size = size
      @tag = tag
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.public_send(@tag, content, **button_attrs)
    end

    private

    def button_attrs
      html_attrs.merge(class: button_classes).tap do |attrs|
        attrs[:type] = "button" if @tag.to_sym == :button && attrs[:type].blank?
      end
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
      "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-colors disabled:pointer-events-none disabled:opacity-50 focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
    end
  end
end
