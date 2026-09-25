# frozen_string_literal: true

module Ui
  # A small status label. Renders a `<span>`; pass `tag: :a` with `href:` for a
  # badge that links somewhere — hover styles apply to links only.
  class BadgeComponent < UiComponent
    VARIANTS = {
      default: "border-transparent bg-primary text-primary-foreground shadow [a&]:hover:bg-primary/80",
      secondary: "border-transparent bg-secondary text-secondary-foreground [a&]:hover:bg-secondary/80",
      destructive: "border-transparent bg-destructive text-destructive-foreground shadow [a&]:hover:bg-destructive/80 focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40",
      outline: "border-input text-foreground [a&]:hover:bg-accent [a&]:hover:text-accent-foreground"
    }.freeze

    def initialize(variant: :default, tag: :span, class_name: nil, **attrs)
      @variant = variant
      @tag = tag
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.public_send(@tag, content, **badge_attrs)
    end

    private

    def badge_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = badge_classes
        attrs[:data] = { slot: "badge" }.merge(attrs[:data].to_h)
      end
    end

    def badge_classes
      class_names(base_classes, fetch_variant(VARIANTS, @variant, fallback: :default), @class_name)
    end

    # Every variant carries a border — transparent on the filled ones — so an
    # outline badge is the same height as its neighbours.
    def base_classes
      "inline-flex w-fit shrink-0 items-center justify-center gap-1 overflow-hidden whitespace-nowrap rounded-md border px-2.5 py-0.5 text-xs font-semibold transition-[color,box-shadow] outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 [&>svg]:pointer-events-none [&>svg]:size-3"
    end
  end
end
