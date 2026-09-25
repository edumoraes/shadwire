# frozen_string_literal: true

module Ui
  module Chart
    # The y axis (Recharts' YAxis): the value axis, or the category axis when
    # the chart's layout is vertical. It takes what the x axis takes, with
    # `width:` for the room it claims at the left.
    class YAxisComponent < XAxisComponent
      def initialize(data_key: nil, hide: false, tick_line: false, axis_line: false, tick_margin: 8,
                     tick_count: 5, tick_format: nil, min_tick_gap: 5, domain: nil, width: nil,
                     class_name: nil, **attrs)
        super(data_key:, hide:, tick_line:, axis_line:, tick_margin:, tick_count:, tick_format:,
              min_tick_gap:, domain:, height: width, class_name:, **attrs)
      end

      private

      def part_name
        "y-axis"
      end

      def slot
        "chart-y-axis"
      end
    end
  end
end
