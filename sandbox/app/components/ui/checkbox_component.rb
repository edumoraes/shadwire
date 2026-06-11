# frozen_string_literal: true

module Ui
  # Styles the native checkbox input, keeping Rails form semantics. With
  # `form_with`, pass `name: form.field_name(:attr)` / `id: form.field_id(:attr)`.
  class CheckboxComponent < UiComponent
    def initialize(checked: false, disabled: false, class_name: nil, **attrs)
      @checked = checked
      @disabled = disabled
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.input(type: "checkbox", **checkbox_attrs)
    end

    private

    def checkbox_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = checkbox_classes
        attrs[:checked] = true if @checked
        attrs[:disabled] = true if @disabled
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "checkbox")
      end
    end

    def checkbox_classes
      class_names(base_classes, @class_name)
    end

    def base_classes
      "shadwire-checkbox peer size-4 shrink-0 appearance-none rounded-[4px] border border-input bg-background shadow-xs transition-shadow outline-none checked:border-primary checked:bg-primary disabled:cursor-not-allowed disabled:opacity-50 focus-visible:ring-1 focus-visible:ring-ring aria-invalid:border-destructive dark:bg-input/30 dark:checked:bg-primary"
    end
  end
end
