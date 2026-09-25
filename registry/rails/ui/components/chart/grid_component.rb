# frozen_string_literal: true

module Ui
  module Chart
    # Reference lines behind a cartesian chart (Recharts' CartesianGrid), at
    # the value axis' ticks. `horizontal:` and `vertical:` are the lines'
    # direction on screen; left unset, the grid draws the lines across the value
    # axis and none between the categories, whichever way the layout runs.
    class GridComponent < LayerComponent
      def initialize(horizontal: nil, vertical: nil, class_name: nil, **attrs)
        @horizontal = horizontal
        @vertical = vertical
        super(controller: "ui-chart-grid", class_name:, **attrs)
      end

      private

      def part_name
        "grid"
      end

      def slot
        "chart-grid"
      end

      def part_options
        { horizontal: @horizontal, vertical: @vertical }
      end

      def base_classes
        "#{super} stroke-border/50"
      end
    end
  end
end
