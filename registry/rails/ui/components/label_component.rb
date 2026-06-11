# frozen_string_literal: true

module Ui
  # The `for` attribute is passed through `**attrs` (`ui_label(for: "email")`)
  # because `for` cannot be a Ruby keyword argument.
  class LabelComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.label(content, **label_attrs)
    end

    private

    def label_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = label_classes
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "label")
      end
    end

    def label_classes
      class_names(base_classes, @class_name)
    end

    def base_classes
      "flex items-center gap-2 text-sm font-medium leading-none select-none peer-disabled:cursor-not-allowed peer-disabled:opacity-50 group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50"
    end
  end
end
