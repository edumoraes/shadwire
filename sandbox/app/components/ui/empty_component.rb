# frozen_string_literal: true

module Ui
  # An empty / placeholder state. Compose `Ui::Empty::HeaderComponent`,
  # `MediaComponent`, `TitleComponent`, `DescriptionComponent` and
  # `ContentComponent` inside it.
  class EmptyComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **empty_attrs)
    end

    private

    def empty_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names(base_classes, @class_name)
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "empty")
      end
    end

    def base_classes
      "flex min-w-0 flex-1 flex-col items-center justify-center gap-6 rounded-lg border-dashed p-6 text-center text-balance md:p-12"
    end
  end
end
