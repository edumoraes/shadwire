# frozen_string_literal: true

module Ui
  class CardComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **html_attrs, class: card_classes)
    end

    private

    def card_classes
      class_names(base_classes, @class_name)
    end

    def base_classes
      "rounded-xl border bg-card text-card-foreground shadow"
    end
  end
end
