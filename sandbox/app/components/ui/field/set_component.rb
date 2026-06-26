# frozen_string_literal: true

module Ui
  module Field
    class SetComponent < UiComponent
      def initialize(class_name: nil, **attrs)
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.fieldset(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "field-set")
        end)
      end

      private

      def base_classes
        "flex flex-col gap-6 has-[>[data-slot=checkbox-group]]:gap-3 has-[>[data-slot=radio-group]]:gap-3"
      end
    end
  end
end
