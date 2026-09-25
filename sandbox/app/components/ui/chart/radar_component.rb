# frozen_string_literal: true

module Ui
  module Chart
    # A radar (Recharts' Radar): a polygon with a corner on each category's
    # spoke, as far out as `data_key:`'s value. The categories are the ones
    # `ui_chart_polar_angle_axis` names. `stroke_width:` outlines the polygon
    # and `fill_opacity: 0` leaves only the outline; `dot: true` marks the
    # corners.
    class RadarComponent < LayerComponent
      def initialize(data_key:, color: nil, fill_opacity: 0.6, stroke_width: 0, dot: false, class_name: nil, **attrs)
        @data_key = data_key
        @color = color
        @fill_opacity = fill_opacity
        @stroke_width = stroke_width
        @dot = dot
        super(controller: "ui-chart-radar", class_name:, **attrs)
      end

      private

      def part_name
        "radar"
      end

      def slot
        "chart-radar"
      end

      def events
        %w[render highlight]
      end

      def part_options
        { data_key: @data_key, color: @color, fill_opacity: @fill_opacity, stroke_width: @stroke_width, dot: @dot }
      end
    end
  end
end
