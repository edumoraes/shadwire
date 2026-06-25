# frozen_string_literal: true

module Ui
  module Field
    # The caption for a `Ui::Field::SetComponent`. `variant: :legend` (default)
    # is base-sized; `:label` is small.
    class LegendComponent < UiComponent
      VARIANTS = {
        legend: "text-base",
        label: "text-sm"
      }.freeze

      def initialize(variant: :legend, class_name: nil, **attrs)
        @variant = variant
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        tag.legend(content, **html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names("mb-3 font-medium", fetch_variant(VARIANTS, @variant, fallback: :legend), @class_name)
          attrs[:data] = attrs.fetch(:data, {}).dup.merge(slot: "field-legend", variant: @variant.to_s)
        end)
      end
    end
  end
end
