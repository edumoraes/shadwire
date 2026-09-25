# frozen_string_literal: true

module Ui
  module Chart
    # The x axis (Recharts' XAxis). The category axis — x, unless the chart's
    # layout is vertical — labels the categories with the `data_key:` field, and
    # the tooltip takes its label from the same field; `hide: true` keeps that
    # without drawing the axis. The value axis takes `domain:` ([min, max],
    # either one nil to leave it to the data) and `tick_count:`.
    #
    # `tick_format:` is a d3-format specifier for numbers ("~s", "$,.0f",
    # ".0%") or a d3-time-format one for dates ("%b %d"), in the page's
    # language. `height:` fixes the room the axis takes; unset, it measures its
    # labels.
    class XAxisComponent < LayerComponent
      def initialize(data_key: nil, hide: false, tick_line: false, axis_line: false, tick_margin: 8,
                     tick_count: 5, tick_format: nil, min_tick_gap: 5, domain: nil, height: nil,
                     class_name: nil, **attrs)
        @data_key = data_key
        @hide = hide
        @tick_line = tick_line
        @axis_line = axis_line
        @tick_margin = tick_margin
        @tick_count = tick_count
        @tick_format = tick_format
        @min_tick_gap = min_tick_gap
        @domain = domain
        @size = height
        super(controller: "ui-chart-axis", class_name:, **attrs)
      end

      private

      def part_name
        "x-axis"
      end

      def slot
        "chart-x-axis"
      end

      def events
        %w[layout render]
      end

      def part_options
        {
          data_key: @data_key, hide: @hide, tick_line: @tick_line, axis_line: @axis_line,
          tick_margin: @tick_margin, tick_count: @tick_count, tick_format: @tick_format,
          min_tick_gap: @min_tick_gap, domain: @domain, size: @size
        }
      end

      def base_classes
        "#{super} [&_line]:stroke-border [&_text]:fill-muted-foreground"
      end
    end
  end
end
