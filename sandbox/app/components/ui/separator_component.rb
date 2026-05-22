# frozen_string_literal: true

module Ui
  class SeparatorComponent < UiComponent
    ORIENTATION_CLASSES = {
      horizontal: "h-px w-full",
      vertical: "h-full w-px"
    }.freeze

    def initialize(orientation: :horizontal, decorative: nil, class_name: nil, **attrs)
      @orientation = orientation_value(orientation)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(**separator_attrs)
    end

    private

    def separator_attrs
      html_attrs.dup.merge(role: "separator", class: separator_classes).tap do |attrs|
        attrs[:aria] = (attrs[:aria] || {}).dup.merge(orientation: @orientation)
        attrs[:data] = (attrs[:data] || {}).dup.merge(orientation: @orientation)
      end
    end

    def separator_classes
      class_names(
        "shrink-0 bg-border",
        fetch_variant(ORIENTATION_CLASSES, @orientation, fallback: :horizontal),
        @class_name
      )
    end

    def orientation_value(orientation)
      key = orientation.presence&.to_sym
      ORIENTATION_CLASSES.key?(key) ? key.to_s : "horizontal"
    end
  end
end
