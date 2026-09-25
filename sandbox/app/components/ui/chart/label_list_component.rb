# frozen_string_literal: true

module Ui
  module Chart
    # Labels on the points of the series it sits in (Recharts' LabelList): put
    # it inside a bar, line, area, pie, radial bar or radar. It prints the value,
    # or another field of the row with `data_key:`, formatted by `format:` (a d3
    # specifier) — or, when the field names a config entry, that entry's label.
    # `position:` is :top, :bottom, :left, :right or :center, plus
    # :inside_top, :inside_bottom, :inside_left and :inside_right on bars and
    # :outside, :inside and :inside_start on slices and rings; `offset:` is the
    # gap in pixels. It is text, so a fill class colors it.
    class LabelListComponent < LayerComponent
      def initialize(data_key: nil, position: nil, offset: 5, format: nil, class_name: nil, **attrs)
        @data_key = data_key
        @position = position
        @offset = offset
        @format = format
        super(controller: "ui-chart-label-list", class_name:, **attrs)
      end

      private

      def root_tag
        :g
      end

      def part_name
        "label-list"
      end

      def slot
        "chart-label-list"
      end

      def top_level?
        false
      end

      def part_options
        { data_key: @data_key, position: @position, offset: @offset, format: @format }
      end

      # Text, which would otherwise take the stroke of the series around it.
      def base_classes
        "fill-foreground stroke-none"
      end
    end
  end
end
