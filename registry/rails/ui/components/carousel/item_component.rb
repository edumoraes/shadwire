# frozen_string_literal: true

module Ui
  module Carousel
    # A single slide. Defaults to a full-width basis so one slide shows at a time.
    class ItemComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs.dup.tap do |attrs|
          attrs[:role] = attrs.fetch(:role, "group")
          attrs[:aria] = { roledescription: "slide" }.merge(attrs.fetch(:aria, {}))
          attrs[:class] = class_names("min-w-0 shrink-0 grow-0 basis-full", @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
            data[:slot] = "carousel-item"
            data[:ui_carousel_target] = append_token(data[:ui_carousel_target], "slide")
          end
        end)
      end

      private

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
