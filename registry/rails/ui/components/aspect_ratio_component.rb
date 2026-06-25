# frozen_string_literal: true

module Ui
  # Constrains its content to a fixed width/height ratio using the native CSS
  # `aspect-ratio` property. Pass `ratio:` as a number (`16.0 / 9`) or string
  # (`"16 / 9"`); defaults to a square.
  class AspectRatioComponent < UiComponent
    def initialize(ratio: 1, class_name: nil, **attrs)
      @ratio = ratio
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **ratio_attrs)
    end

    private

    def ratio_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names(@class_name)
        attrs[:style] = [ "aspect-ratio: #{@ratio}", attrs[:style] ].compact_blank.join("; ")
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "aspect-ratio")
      end
    end
  end
end
