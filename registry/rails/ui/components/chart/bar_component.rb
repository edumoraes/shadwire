# frozen_string_literal: true

module Ui
  module Chart
    # A series of bars (Recharts' Bar): one per row, `data_key:` naming the
    # value. Bars that share a `stack_id:` stack; the others stand side by side.
    # `radius:` rounds the corners — one number for all four, or
    # [top_left, top_right, bottom_right, bottom_left] as they sit on screen.
    #
    # The color is the config's for `data_key:`, `color:` if given, or a row's
    # own `fill` value. A `ui_chart_label_list` inside labels the bars.
    class BarComponent < LayerComponent
      def initialize(data_key:, color: nil, stack_id: nil, radius: 0, class_name: nil, **attrs)
        @data_key = data_key
        @color = color
        @stack_id = stack_id
        @radius = radius
        super(controller: "ui-chart-bar", class_name:, **attrs)
      end

      private

      def part_name
        "bar"
      end

      def slot
        "chart-bar"
      end

      def part_options
        { data_key: @data_key, color: @color, stack_id: @stack_id, radius: @radius }
      end
    end
  end
end
