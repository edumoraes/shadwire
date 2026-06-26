# frozen_string_literal: true

module Ui
  # Wraps an input/textarea with leading or trailing addons (icons, text,
  # buttons). Place an `Ui::InputGroup::InputComponent`/`TextareaComponent`
  # control plus one or more `Ui::InputGroup::AddonComponent`s inside it.
  class InputGroupComponent < UiComponent
    def initialize(class_name: nil, **attrs)
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
        attrs[:class] = class_names(base_classes, @class_name)
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "input-group")
      end
    end

    def base_classes
      "group/input-group border-input dark:bg-input/30 relative flex w-full items-center rounded-md border shadow-xs transition-[color,box-shadow] outline-none " \
      "h-9 min-w-0 has-[>textarea]:h-auto " \
      "has-[[data-slot=input-group-control]:focus-visible]:border-ring has-[[data-slot=input-group-control]:focus-visible]:ring-ring/50 has-[[data-slot=input-group-control]:focus-visible]:ring-[3px] " \
      "has-[[data-slot=input-group-control][aria-invalid=true]]:ring-destructive/20 has-[[data-slot=input-group-control][aria-invalid=true]]:border-destructive"
    end
  end
end
