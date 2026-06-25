# frozen_string_literal: true

module Ui
  module Field
    # A vertical stack of `Ui::FieldComponent`s; provides the `@container` that
    # `:responsive` fields adapt to.
    class GroupComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.div(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "field-group")
        end)
      end

      private

      def base_classes
        "group/field-group @container/field-group flex w-full flex-col gap-7 [&>[data-slot=field-group]]:gap-4"
      end
    end
  end
end
