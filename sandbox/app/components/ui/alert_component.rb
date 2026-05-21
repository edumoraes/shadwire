# frozen_string_literal: true

module Ui
  class AlertComponent < UiComponent
    VARIANTS = {
      default: "bg-background text-foreground",
      destructive: "border-destructive/50 text-destructive dark:border-destructive [&>svg]:text-destructive"
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
      html_attrs.merge(role: html_attrs.fetch(:role, "alert"), class: alert_classes)
    end

    def alert_classes
      class_names(
        "relative w-full rounded-lg border p-4",
        fetch_variant(VARIANTS, @variant, fallback: :default),
        @class_name
      )
    end
  end
end
