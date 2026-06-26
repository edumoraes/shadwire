# frozen_string_literal: true

module Ui
  module Carousel
    # The "next slide" control. Disabled by the controller at the last slide.
    class NextComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.button(**button_attrs) do
          safe_join([
            helpers.lucide_icon("arrow-right", class: "size-4"),
            tag.span("Próximo slide", class: "sr-only")
          ])
        end
      end

      private

      def button_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:type] = attrs.fetch(:type, "button")
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "carousel-next"
            data[:ui_carousel_target] = append_token(data[:ui_carousel_target], "next")
            data[:action] = append_token(data[:action], "click->ui-carousel#next")
          end
        end
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end

      def base_classes
        "absolute top-1/2 -right-12 inline-flex size-8 -translate-y-1/2 items-center justify-center rounded-full border border-input bg-background shadow-xs transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:ring-1 focus-visible:ring-ring focus-visible:outline-none disabled:pointer-events-none disabled:opacity-50"
      end
    end
  end
end
