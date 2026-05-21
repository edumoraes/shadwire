# frozen_string_literal: true

module Ui
  class SeparatorComponent < UiComponent
    ORIENTATION_CLASSES = {
      horizontal: "h-px w-full",
      vertical: "h-full w-px"
    }.freeze

    def initialize(orientation: :horizontal, decorative: true, class_name: nil, **attrs)
      @orientation = orientation
      @decorative = decorative
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(**separator_attrs)
    end

    private

    def separator_attrs
      html_attrs.merge(
        role: "separator",
        "aria-orientation": @orientation.to_s,
        "aria-hidden": @decorative,
        class: separator_classes
      )
    end

    def separator_classes
      class_names(
        "shrink-0 bg-border",
        fetch_variant(ORIENTATION_CLASSES, @orientation, fallback: :horizontal),
        @class_name
      )
    end
  end
end
