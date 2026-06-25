# frozen_string_literal: true

module Ui
  module Field
    # The `<label>` for a field. Carries the base label styling plus field-aware
    # selectors; associate it with a control via `for:`.
    class LabelComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.label(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "field-label")
        end)
      end

      private

      def base_classes
        "flex w-fit items-center gap-2 text-sm font-medium leading-snug select-none " \
        "group/field-label peer/field-label " \
        "group-data-[disabled=true]/field:opacity-50 " \
        "has-[>[data-slot=field]]:w-full has-[>[data-slot=field]]:flex-col has-[>[data-slot=field]]:rounded-md has-[>[data-slot=field]]:border has-[>[data-slot=field]]:p-4"
      end
    end
  end
end
