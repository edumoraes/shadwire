# frozen_string_literal: true

module Ui
  module InputGroup
    # A compact button addon for an input group. `size:` maps to the small
    # variants shadcn uses inside input groups (`:xs`, `:sm`, `:icon_xs`, `:icon_sm`).
    class ButtonComponent < UiComponent
      VARIANTS = {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        outline: "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
        secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground"
      }.freeze

      SIZES = {
        xs: "h-6 gap-1 px-2 rounded-sm has-[>svg]:px-2",
        sm: "h-8 gap-1.5 px-2.5 rounded-md",
        icon_xs: "size-6 rounded-sm p-0",
        icon_sm: "size-8 rounded-md p-0"
      }.freeze

      def initialize(variant: :ghost, size: :xs, type: "button", class_name: nil, **attrs)
        @variant = variant
        @size = size
        @type = type
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.button(content, **button_attrs)
      end

      private

      def button_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:type] = @type
          attrs[:class] = class_names(
            base_classes,
            fetch_variant(VARIANTS, @variant, fallback: :ghost),
            fetch_variant(SIZES, @size, fallback: :xs),
            @class_name
          )
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "input-group-control")
        end
      end

      def base_classes
        "inline-flex shrink-0 items-center justify-center gap-1 text-sm font-medium whitespace-nowrap shadow-none transition-colors outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4"
      end
    end
  end
end
