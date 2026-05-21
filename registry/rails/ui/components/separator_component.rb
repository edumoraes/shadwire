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
      html_attrs.merge(role_attrs).merge(class: separator_classes)
    end

    # A decorative separator is purely visual, so it is removed from the
    # accessibility tree with role="none". A non-decorative separator is a
    # semantic divider and exposes role="separator" with its orientation.
    def role_attrs
      return { role: "none" } if @decorative

      { role: "separator", "aria-orientation": @orientation.to_s }
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
