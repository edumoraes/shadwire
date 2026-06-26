# frozen_string_literal: true

module Ui
  # A styled wrapper around the browser's native `<select>`. Pass `<option>`
  # markup as the block; free HTML attributes (`name:`, `id:`, `disabled:`,
  # `multiple:`, `required:`, `data:`) flow through to the `<select>`.
  class NativeSelectComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(class: "relative") do
        safe_join([ tag.select(content, **select_attrs), chevron ])
      end
    end

    private

    def select_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names(base_classes, @class_name)
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "native-select")
      end
    end

    def chevron
      helpers.lucide_icon(
        "chevron-down",
        class: "pointer-events-none absolute top-1/2 right-3 size-4 -translate-y-1/2 opacity-50",
        "aria-hidden": "true"
      )
    end

    def base_classes
      "border-input dark:bg-input/30 flex h-9 w-full appearance-none items-center rounded-md border bg-transparent px-3 py-2 pr-8 text-sm shadow-xs transition-[color,box-shadow] outline-none focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20"
    end
  end
end
