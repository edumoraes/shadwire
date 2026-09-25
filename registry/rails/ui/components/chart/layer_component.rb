# frozen_string_literal: true

module Ui
  module Chart
    # One layer of a chart: an <svg> over the whole chart that a Stimulus
    # controller draws into with D3. Every built-in part is one — the grid, the
    # axes, the bars — and so is anything you draw yourself. Name the controller
    # and it receives `ui-chart:render`, with the chart's scales in
    # `event.detail.chart` and these `options:` in `event.detail.options`:
    #
    #   <%= ui_chart_layer(controller: "target-line", options: { value: 250 }) %>
    #
    # A controller that connects after the chart has drawn announces itself
    # with `this.dispatch("connect", { prefix: "ui-chart" })`, as the built-in
    # ones do, and the chart draws again.
    class LayerComponent < UiComponent
      def initialize(controller: nil, options: {}, class_name: nil, **attrs)
        @controller = controller
        @options = options
        @attrs = attrs
        @class_name = extract_class_name(@attrs, class_name)
      end

      def call
        content_tag(root_tag, content, **layer_attrs)
      end

      private

      # What each part sets. The rest is wiring every part shares.
      def root_tag
        :svg
      end

      def part_name
        "layer"
      end

      def slot
        "chart-layer"
      end

      def controller_name
        @controller
      end

      # The chart events the controller handles: `layout` (claim room at an edge
      # before the scales are fixed), `render` and `highlight` (the category
      # the tooltip is on).
      def events
        %w[render]
      end

      def part_options
        @options
      end

      def base_classes
        "pointer-events-none absolute inset-0 size-full overflow-visible"
      end

      # The chart draws the parts it contains. A label list is drawn by the
      # series it sits in instead, so it is not one of them.
      def top_level?
        true
      end

      def layer_attrs
        html_attrs.dup.tap do |attrs|
          attrs[:class] = class_names(base_classes, @class_name)
          attrs[:aria] = { hidden: "true" }.merge(attrs.fetch(:aria, {})) if root_tag == :svg
          attrs[:data] = attrs.fetch(:data, {}).to_h.dup.tap do |data|
            data[:slot] = slot
            data[:chart_part] = part_name
            data[:chart_options] = options_json
            data[:ui_chart_target] = append_token(data[:ui_chart_target], "part") if top_level?
            next if controller_name.blank?

            data[:controller] = append_token(data[:controller], controller_name)
            data[:action] = append_token(data[:action], actions)
          end
        end
      end

      def actions
        events.map { |event| "ui-chart:#{event}->#{controller_name}##{event}" }.join(" ")
      end

      # camelCased and without the unset ones, the way the controllers read them.
      def options_json
        part_options.to_h.compact.transform_keys { |key| key.to_s.camelize(:lower) }.to_json
      end

      def append_token(existing, token)
        [ existing, token ].compact_blank.join(" ")
      end
    end
  end
end
