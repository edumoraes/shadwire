# frozen_string_literal: true

module Ui
  # A Chart.js-backed chart. Pass a Chart.js `data` hash (`labels` +
  # `datasets`) and an optional `options` hash; both are serialized to JSON
  # `data-*-value`s and handed to a `ui-chart` controller that instantiates
  # Chart.js. Datasets without explicit colors inherit the `--chart-1..5`
  # theme palette client-side, so charts pick up the active theme.
  #
  # This is the one component with a third-party JS dependency: pin Chart.js in
  # your importmap (`pin "chart.js/auto", to: "https://cdn.jsdelivr.net/npm/chart.js@4.4.6/auto/+esm"`).
  # `type` is any Chart.js type (:bar, :line, :pie, :doughnut, …). Tooltips and
  # the legend are Chart.js `options`, not separate components.
  class ChartComponent < UiComponent
    def initialize(type: :bar, data: {}, options: {}, label: nil, class_name: nil, **attrs)
      @type = type
      @data = data
      @options = options
      @label = label
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.figure(**figure_attrs) do
        tag.canvas("", **canvas_attrs)
      end
    end

    private

    def figure_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names("relative aspect-video w-full text-xs", @class_name)
        attrs[:data] = attrs.fetch(:data, {}).dup.tap do |data|
          data[:slot] = "chart"
          data[:controller] = append_token(data[:controller], "ui-chart")
          data[:"ui-chart-type-value"] = @type
          data[:"ui-chart-data-value"] = @data.to_json
          data[:"ui-chart-options-value"] = @options.to_json
        end
      end
    end

    def canvas_attrs
      { role: "img", data: { "ui-chart-target": "canvas" } }.tap do |attrs|
        attrs[:aria] = { label: @label } if @label.present?
      end
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
