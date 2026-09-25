# frozen_string_literal: true

module Ui
  module Chart
    # Bars bent into rings (Recharts' RadialBar): one ring per row, swept from
    # the chart's start angle in proportion to `data_key:`'s value. With a
    # `name_key:` each ring is a category, colored and named by its config entry
    # like a pie's slices; radial bars that share a `stack_id:` stack along
    # their ring instead. `background: true` draws the rest of each ring as a
    # muted track.
    class RadialBarComponent < LayerComponent
      def initialize(data_key:, name_key: nil, color: nil, stack_id: nil, background: false, corner_radius: 0,
                     class_name: nil, **attrs)
        @data_key = data_key
        @name_key = name_key
        @color = color
        @stack_id = stack_id
        @background = background
        @corner_radius = corner_radius
        super(controller: "ui-chart-radial-bar", class_name:, **attrs)
      end

      private

      def part_name
        "radial-bar"
      end

      def slot
        "chart-radial-bar"
      end

      def part_options
        {
          data_key: @data_key, name_key: @name_key, color: @color, stack_id: @stack_id,
          background: @background, corner_radius: @corner_radius
        }
      end

      # The track's color: the rings carry their own, so only the track takes
      # it, and a fill class passed in recolors the track.
      def base_classes
        "#{super} fill-muted"
      end
    end
  end
end
