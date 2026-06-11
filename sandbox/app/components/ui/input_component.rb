# frozen_string_literal: true

module Ui
  class InputComponent < UiComponent
    def initialize(type: :text, class_name: nil, **attrs)
      @type = type
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.input(type: @type, **input_attrs)
    end

    private

    def input_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = input_classes
        attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "input")
      end
    end

    def input_classes
      class_names(base_classes, @class_name)
    end

    def base_classes
      "flex h-9 w-full min-w-0 rounded-md border border-input bg-transparent px-3 py-1 text-base shadow-xs transition-[color,box-shadow] outline-none placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium file:text-foreground disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 focus-visible:ring-1 focus-visible:ring-ring aria-invalid:border-destructive md:text-sm dark:bg-input/30"
    end
  end
end
