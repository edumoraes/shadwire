# frozen_string_literal: true

module Ui
  module Chart
    # The labels around a radar (Recharts' PolarAngleAxis): `data_key:` names
    # the field that labels each spoke, and the tooltip takes its label from
    # it too. `tick_format:` is the axes' d3 specifier.
    class PolarAngleAxisComponent < LayerComponent
      def initialize(data_key: nil, tick_format: nil, tick_margin: 8, class_name: nil, **attrs)
        @data_key = data_key
        @tick_format = tick_format
        @tick_margin = tick_margin
        super(controller: "ui-chart-polar-angle-axis", class_name:, **attrs)
      end

      private

      def part_name
        "polar-angle-axis"
      end

      def slot
        "chart-polar-angle-axis"
      end

      def part_options
        { data_key: @data_key, tick_format: @tick_format, tick_margin: @tick_margin }
      end

      def base_classes
        "#{super} [&_text]:fill-muted-foreground"
      end
    end
  end
end
