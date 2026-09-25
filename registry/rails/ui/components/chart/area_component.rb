# frozen_string_literal: true

module Ui
  module Chart
    # An area under a line (Recharts' Area), `data_key:` naming the value.
    # Areas that share a `stack_id:` stack. The fill is the series color at
    # `fill_opacity:`, or a vertical fade of it with `gradient: true`; `curve:`,
    # `dot:` and `connect_nulls:` are the line's.
    class AreaComponent < LayerComponent
      def initialize(data_key:, color: nil, stack_id: nil, curve: :natural, fill_opacity: 0.4, gradient: false,
                     stroke_width: 1, dot: false, connect_nulls: false, class_name: nil, **attrs)
        @data_key = data_key
        @color = color
        @stack_id = stack_id
        @curve = curve
        @fill_opacity = fill_opacity
        @gradient = gradient
        @stroke_width = stroke_width
        @dot = dot
        @connect_nulls = connect_nulls
        super(controller: "ui-chart-area", class_name:, **attrs)
      end

      private

      def part_name
        "area"
      end

      def slot
        "chart-area"
      end

      def events
        %w[render highlight]
      end

      def part_options
        {
          data_key: @data_key, color: @color, stack_id: @stack_id, curve: @curve, fill_opacity: @fill_opacity,
          gradient: @gradient, stroke_width: @stroke_width, dot: @dot, connect_nulls: @connect_nulls
        }
      end
    end
  end
end
