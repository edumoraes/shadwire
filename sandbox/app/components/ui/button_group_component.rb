# frozen_string_literal: true

module Ui
  # Visually joins a row (or column) of buttons/inputs, collapsing the inner
  # borders and corner radii. Compose `Ui::Button`s, `Ui::ButtonGroup::TextComponent`
  # and `SeparatorComponent` inside it.
  class ButtonGroupComponent < UiComponent
    ORIENTATIONS = {
      horizontal: "[&>*:not(:first-child)]:rounded-l-none [&>*:not(:first-child)]:border-l-0 [&>*:not(:last-child)]:rounded-r-none",
      vertical: "flex-col [&>*:not(:first-child)]:rounded-t-none [&>*:not(:first-child)]:border-t-0 [&>*:not(:last-child)]:rounded-b-none"
    }.freeze

    def initialize(orientation: :horizontal, class_name: nil, **attrs)
      @orientation = orientation
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(content, **group_attrs)
    end

    private

    def group_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:role] = attrs.fetch(:role, "group")
        attrs[:class] = class_names(base_classes, fetch_variant(ORIENTATIONS, @orientation, fallback: :horizontal), @class_name)
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "button-group", orientation: @orientation.to_s)
      end
    end

    def base_classes
      "flex w-fit items-stretch [&>*]:shadow-none [&>*]:focus-visible:z-10 [&>*]:focus-visible:relative [&>input]:flex-1 has-[>[data-slot=button-group]]:gap-2"
    end
  end
end
