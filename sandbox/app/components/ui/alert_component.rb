# frozen_string_literal: true

module Ui
  # An inline callout. Compose `Ui::Alert::TitleComponent` and
  # `Ui::Alert::DescriptionComponent` inside it, optionally after a `ui_icon`:
  # the icon takes a fixed first column and the text lines up beside it. Plain
  # content without the parts renders as before.
  class AlertComponent < UiComponent
    VARIANTS = {
      default: "bg-background text-foreground",
      destructive: "border-destructive/50 text-destructive dark:border-destructive [&>svg]:text-current *:data-[slot=alert-description]:text-destructive/90"
    }.freeze

    def initialize(variant: :default, class_name: nil, **attrs)
      @variant = variant
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **alert_attrs)
    end

    private

    def alert_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:role] = attrs.fetch(:role, "alert")
        attrs[:class] = alert_classes
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "alert")
      end
    end

    def alert_classes
      class_names(base_classes, fetch_variant(VARIANTS, @variant, fallback: :default), @class_name)
    end

    # A grid, so a leading icon gets its own column and every other child lines
    # up in the second. Without an icon there is a single column: bare text and
    # the parts alike stay full width.
    def base_classes
      "relative grid w-full items-start gap-y-0.5 rounded-lg border px-4 py-3 text-sm has-[>svg]:grid-cols-[calc(var(--spacing)*4)_1fr] has-[>svg]:gap-x-3 [&:has(>svg)>:not(svg)]:col-start-2 [&>svg]:size-4 [&>svg]:translate-y-0.5 [&>svg]:text-current"
    end
  end
end
