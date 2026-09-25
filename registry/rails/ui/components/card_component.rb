# frozen_string_literal: true

module Ui
  class CardComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **card_attrs)
    end

    private

    def card_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names(base_classes, @class_name)
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "card")
      end
    end

    def base_classes
      "rounded-xl border bg-card text-card-foreground shadow"
    end
  end
end
