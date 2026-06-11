# frozen_string_literal: true

module Ui
  class TextareaComponent < UiComponent
    def initialize(class_name: nil, **attrs)
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.textarea(content, **textarea_attrs)
    end

    private

    def textarea_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = textarea_classes
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "textarea")
      end
    end

    def textarea_classes
      class_names(base_classes, @class_name)
    end

    def base_classes
      "flex field-sizing-content min-h-16 w-full rounded-md border border-input bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none placeholder:text-muted-foreground disabled:cursor-not-allowed disabled:opacity-50 focus-visible:ring-1 focus-visible:ring-ring aria-invalid:border-destructive md:text-sm dark:bg-input/30"
    end
  end
end
