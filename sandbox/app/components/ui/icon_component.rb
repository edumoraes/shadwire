# frozen_string_literal: true

module Ui
  # Renders a Lucide icon via the lucide-rails gem (the consuming app must
  # bundle `lucide-rails`). Icons are decorative by default (`aria-hidden`);
  # pass `label:` to expose a meaningful icon to assistive technology.
  class IconComponent < UiComponent
    SIZES = {
      sm: "size-3",
      default: "size-4",
      lg: "size-5",
      xl: "size-6"
    }.freeze

    def initialize(name, size: :default, label: nil, class_name: nil, **attrs)
      @name = name
      @size = size
      @label = label
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      helpers.lucide_icon(@name, **icon_attrs)
    end

    private

    def icon_attrs
      attrs = html_attrs.merge(class: icon_classes)
      return attrs if @label.blank?

      # A labelled icon carries meaning: expose it and cancel the gem's
      # default `aria-hidden="true"` (nil drops the attribute entirely).
      attrs.merge(role: "img", "aria-label": @label, "aria-hidden": nil)
    end

    def icon_classes
      class_names(
        "shrink-0",
        fetch_variant(SIZES, @size, fallback: :default),
        @class_name
      )
    end
  end
end
