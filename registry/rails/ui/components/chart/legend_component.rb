# frozen_string_literal: true

module Ui
  module Chart
    # The chart's legend (Recharts' Legend with shadcn's ChartLegendContent): a
    # swatch and a label for each series — or for each slice of a pie, or each
    # row when `name_key:` names them — with the config's icon in place of the
    # swatch unless `hide_icon: true`. It sits at the `vertical_align:` edge,
    # :bottom or :top, and the plot leaves it the room it takes.
    class LegendComponent < LayerComponent
      VERTICAL_ALIGNS = %i[bottom top].freeze

      def initialize(name_key: nil, hide_icon: false, vertical_align: :bottom, class_name: nil, **attrs)
        @name_key = name_key
        @hide_icon = hide_icon
        @vertical_align = VERTICAL_ALIGNS.include?(vertical_align&.to_sym) ? vertical_align.to_sym : :bottom
        super(controller: "ui-chart-legend", class_name:, **attrs)
      end

      def call
        tag.div(item_template, **layer_attrs)
      end

      private

      def root_tag
        :div
      end

      def part_name
        "legend"
      end

      def slot
        "chart-legend"
      end

      def events
        %w[layout]
      end

      def part_options
        { name_key: @name_key, hide_icon: @hide_icon, vertical_align: @vertical_align }
      end

      def base_classes
        edge = @vertical_align == :top ? "top-0 pb-3" : "bottom-0 pt-3"
        "absolute inset-x-0 #{edge} flex flex-wrap items-center justify-center gap-4"
      end

      # The controller copies this once per entry and fills in the color and
      # the label.
      def item_template
        tag.template(data: { ui_chart_legend_target: "item" }) do
          tag.div(class: "flex items-center gap-1.5 [&>svg]:text-muted-foreground", data: { slot: "chart-legend-item" }) do
            safe_join([
              tag.div(class: "size-2 shrink-0 rounded-[2px] bg-(--color-bg)", data: { swatch: "" }),
              tag.span(data: { label: "" })
            ])
          end
        end
      end
    end
  end
end
