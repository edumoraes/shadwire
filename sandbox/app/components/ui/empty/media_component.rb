# frozen_string_literal: true

module Ui
  module Empty
    # Holds an icon or illustration for an empty state. `variant: :icon` draws a
    # rounded muted tile; `:default` is a bare slot.
    class MediaComponent < UiComponent
      VARIANTS = {
        default: "bg-transparent",
        icon: "bg-muted text-foreground flex size-10 shrink-0 items-center justify-center rounded-lg [&_svg:not([class*='size-'])]:size-6"
      }.freeze

      def initialize(variant: :default, class_name: nil, **attrs)
        @variant = variant
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(base_classes, fetch_variant(VARIANTS, @variant, fallback: :default), @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "empty-media", variant: @variant.to_s)
        end)
      end

      private

      def base_classes
        "flex shrink-0 items-center justify-center mb-2 [&_svg:not([class*='size-'])]:size-6"
      end
    end
  end
end
