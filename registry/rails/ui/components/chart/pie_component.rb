# frozen_string_literal: true

module Ui
  module Chart
    # A pie — or, with an inner radius, a donut (Recharts' Pie): one slice per
    # row, `data_key:` naming the value and `name_key:` the category. The
    # category's config entry labels and colors the slice, and a row's own
    # `fill` value wins over it. The radii default to the chart's;
    # `stroke_width:` draws a stroke in the background color between slices,
    # and `padding_angle:` opens a gap between them whatever is behind.
    class PieComponent < LayerComponent
      def initialize(data_key:, name_key: nil, inner_radius: nil, outer_radius: nil, padding_angle: 0,
                     corner_radius: 0, stroke_width: 0, class_name: nil, **attrs)
        @data_key = data_key
        @name_key = name_key
        @inner_radius = inner_radius
        @outer_radius = outer_radius
        @padding_angle = padding_angle
        @corner_radius = corner_radius
        @stroke_width = stroke_width
        super(controller: "ui-chart-pie", class_name:, **attrs)
      end

      private

      def part_name
        "pie"
      end

      def slot
        "chart-pie"
      end

      def part_options
        {
          data_key: @data_key, name_key: @name_key, inner_radius: @inner_radius, outer_radius: @outer_radius,
          padding_angle: @padding_angle, corner_radius: @corner_radius, stroke_width: @stroke_width
        }
      end

      # The stroke between slices, in the page's background: a class, so a
      # chart on a card can pass `stroke-card`.
      def base_classes
        "#{super} stroke-background"
      end
    end
  end
end
