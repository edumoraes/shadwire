# frozen_string_literal: true

module Ui
  module Chart
    # The web behind a radar (Recharts' PolarGrid): five rings — polygons
    # through the spokes, or circles with `grid_type: :circle` — and a spoke per
    # category unless `radial_lines: false`. The rings are unfilled; a fill
    # class (`fill-muted`) fills them.
    class PolarGridComponent < LayerComponent
      def initialize(grid_type: :polygon, radial_lines: true, class_name: nil, **attrs)
        @grid_type = grid_type
        @radial_lines = radial_lines
        super(controller: "ui-chart-polar-grid", class_name:, **attrs)
      end

      private

      def part_name
        "polar-grid"
      end

      def slot
        "chart-polar-grid"
      end

      def part_options
        { grid_type: @grid_type, radial_lines: @radial_lines }
      end

      def base_classes
        "#{super} stroke-border"
      end

      # An attribute rather than a class, so that a fill class passed in wins.
      def layer_attrs
        super.tap { |attrs| attrs[:fill] ||= "none" }
      end
    end
  end
end
