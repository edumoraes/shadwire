# frozen_string_literal: true

module Ui
  module Chart
    # A line through one value per row (Recharts' Line), `data_key:` naming the
    # value. `curve:` is D3's curve: :natural, :linear, :monotone, :step,
    # :step_before, :step_after, :basis, :cardinal or :catmull_rom. `dot: true`
    # marks each point; a gap in the data breaks the line unless
    # `connect_nulls: true`. A `ui_chart_label_list` inside labels the points.
    class LineComponent < LayerComponent
      def initialize(data_key:, color: nil, curve: :natural, stroke_width: 2, dot: false, connect_nulls: false,
                     class_name: nil, **attrs)
        @data_key = data_key
        @color = color
        @curve = curve
        @stroke_width = stroke_width
        @dot = dot
        @connect_nulls = connect_nulls
        super(controller: "ui-chart-line", class_name:, **attrs)
      end

      private

      def part_name
        "line"
      end

      def slot
        "chart-line"
      end

      def events
        %w[render highlight]
      end

      def part_options
        {
          data_key: @data_key, color: @color, curve: @curve, stroke_width: @stroke_width,
          dot: @dot, connect_nulls: @connect_nulls
        }
      end
    end
  end
end
