# frozen_string_literal: true

module Ui
  module Chart
    # The chart's tooltip (Recharts' Tooltip with shadcn's ChartTooltipContent).
    # Pointing at a category — or moving along them with the arrow keys once the
    # chart has focus — lists each series' value there, under the category's
    # label; on a pie or a ring it names the slice under the pointer.
    #
    # `indicator:` is :dot, :line or :dashed. `label_key:` reads the label from
    # another config entry or field, `name_key:` the names; `label_format:` and
    # `value_format:` are d3 specifiers. `cursor:` shades the hovered category,
    # and `default_index:` opens the tooltip on a category before anyone points.
    #
    # The markup is all here: the controller copies the item template and fills
    # in the text.
    class TooltipComponent < LayerComponent
      INDICATORS = %i[dot line dashed].freeze

      def initialize(indicator: :dot, hide_label: false, hide_indicator: false, label_key: nil, name_key: nil,
                     label_format: nil, value_format: nil, cursor: true, default_index: nil,
                     class_name: nil, **attrs)
        @indicator = INDICATORS.include?(indicator&.to_sym) ? indicator.to_sym : :dot
        @hide_label = hide_label
        @hide_indicator = hide_indicator
        @label_key = label_key
        @name_key = name_key
        @label_format = label_format
        @value_format = value_format
        @cursor = cursor
        @default_index = default_index
        super(controller: "ui-chart-tooltip", class_name:, **attrs)
      end

      def call
        tag.div(**layer_attrs) do
          safe_join([ cursor_layer, content_box, item_template, status ])
        end
      end

      private

      def root_tag
        :div
      end

      def part_name
        "tooltip"
      end

      def slot
        "chart-tooltip"
      end

      def events
        %w[render highlight]
      end

      def part_options
        {
          indicator: @indicator, hide_label: @hide_label, label_key: @label_key, name_key: @name_key,
          label_format: @label_format, value_format: @value_format, cursor: @cursor, default_index: @default_index
        }
      end

      def base_classes
        "pointer-events-none absolute inset-0"
      end

      # What the pointer is on, behind the series: a band on a bar chart, a line
      # on the others.
      def cursor_layer
        tag.svg(class: "absolute inset-0 size-full overflow-visible fill-muted stroke-border",
                aria: { hidden: "true" }, data: { ui_chart_tooltip_target: "cursor" })
      end

      # Hidden from assistive technology: `status` below says the same thing, and
      # only when the keyboard moved it.
      def content_box
        tag.div(hidden: true, aria: { hidden: "true" },
                class: "absolute top-0 left-0 z-10 grid min-w-[8rem] items-start gap-1.5 rounded-lg " \
                       "border border-border/50 bg-background px-2.5 py-1.5 text-xs shadow-xl",
                data: { slot: "chart-tooltip-content", ui_chart_tooltip_target: "content" }) do
          safe_join([
            tag.div(class: "font-medium", hidden: true, data: { ui_chart_tooltip_target: "label" }),
            tag.div(class: "grid gap-1.5", data: { ui_chart_tooltip_target: "list" })
          ])
        end
      end

      # One row per series. With a single row and a line or dashed indicator,
      # the controller moves the label into the row, beside the name.
      def item_template
        tag.template(data: { ui_chart_tooltip_target: "item" }) do
          tag.div(class: item_classes, data: { slot: "chart-tooltip-item" }) do
            safe_join([ indicator, item_body ].compact)
          end
        end
      end

      def indicator
        tag.div(class: indicator_classes, data: { indicator: "" }) unless @hide_indicator
      end

      def item_body
        tag.div(class: "flex flex-1 items-center justify-between gap-4 leading-none data-[nested]:items-end", data: { body: "" }) do
          safe_join([
            tag.div(class: "grid gap-1.5") do
              safe_join([
                tag.div(class: "font-medium", hidden: true, data: { nested_label: "" }),
                tag.span(class: "text-muted-foreground", data: { name: "" })
              ])
            end,
            tag.span(class: "font-mono font-medium text-foreground tabular-nums", data: { value: "" })
          ])
        end
      end

      def status
        tag.div(class: "sr-only", role: "status", aria: { live: "polite" }, data: { ui_chart_tooltip_target: "status" })
      end

      def item_classes
        class_names(
          "flex w-full flex-wrap items-stretch gap-2 [&>svg]:text-muted-foreground",
          ("items-center" if @indicator == :dot)
        )
      end

      def indicator_classes
        case @indicator
        when :line then "w-1 shrink-0 rounded-[2px] border-(--color-border) bg-(--color-bg)"
        when :dashed
          "w-0 shrink-0 rounded-[2px] border-[1.5px] border-dashed border-(--color-border) data-[nested]:my-0.5"
        else "size-2.5 shrink-0 rounded-[2px] border-(--color-border) bg-(--color-bg)"
        end
      end
    end
  end
end
