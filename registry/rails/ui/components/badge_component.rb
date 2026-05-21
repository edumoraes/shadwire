# frozen_string_literal: true

module Ui
  class BadgeComponent < UiComponent
    VARIANTS = {
      default: "bg-primary text-primary-foreground shadow hover:bg-primary/80",
      secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
      destructive: "bg-destructive text-destructive-foreground shadow hover:bg-destructive/80",
      outline: "border border-input text-foreground"
    }.freeze

    def initialize(variant: :default, class_name: nil, **attrs)
      @variant = variant
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.span(content, **html_attrs, class: badge_classes)
    end

    private

    def badge_classes
      class_names(base_classes, fetch_variant(VARIANTS, @variant, fallback: :default), @class_name)
    end

    def base_classes
      "inline-flex items-center rounded-md px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
    end
  end
end
