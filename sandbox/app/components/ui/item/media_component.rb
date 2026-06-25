# frozen_string_literal: true

module Ui
  module Item
    # Leading media for an `Ui::ItemComponent`. `variant: :icon` draws a bordered
    # tile; `:image` clips a square thumbnail; `:default` is a bare slot.
    class MediaComponent < UiComponent
      VARIANTS = {
        default: "bg-transparent",
        icon: "bg-muted size-8 rounded-sm border [&_svg:not([class*='size-'])]:size-4",
        image: "size-10 rounded-sm overflow-hidden [&_img]:size-full [&_img]:object-cover"
      }.freeze

      def initialize(variant: :default, class_name: nil, **attrs)
        @variant = variant
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(base_classes, fetch_variant(VARIANTS, @variant, fallback: :default), @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "item-media", variant: @variant.to_s)
        end)
      end

      private

      def base_classes
        "flex shrink-0 items-center justify-center gap-2 group-has-[[data-slot=item-description]]/item:self-start [&_svg]:pointer-events-none group-has-[[data-slot=item-description]]/item:translate-y-0.5"
      end
    end
  end
end
