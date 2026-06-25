# frozen_string_literal: true

module Ui
  module Carousel
    # The viewport that clips the slide track.
    class ContentComponent < UiComponent
      def initialize(orientation: :horizontal, class_name: nil, **attrs)
        @orientation = orientation
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(class: "overflow-hidden", data: { slot: "carousel-content" }) do
          tag.div(content, **track_attrs)
        end
      end

      private

      def track_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(track_classes, @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "carousel-track"
            data[:ui_carousel_target] = append_token(data[:ui_carousel_target], "track")
          end
        end
      end

      def track_classes
        base = "flex transition-transform duration-300 ease-out"
        @orientation.to_sym == :vertical ? "#{base} flex-col" : base
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
