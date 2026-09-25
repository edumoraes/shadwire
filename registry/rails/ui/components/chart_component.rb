# frozen_string_literal: true

module Ui
  # A chart drawn with D3: shadcn's ChartContainer.
  #
  # The container holds what every part shares — the rows, the series config,
  # the layout — and each part inside it draws one layer: a grid, an axis, a
  # series of bars, a tooltip, a legend. Parts stack in the order they are
  # written, like Recharts' children, so a chart is whatever you compose:
  #
  #   <%= ui_chart(config: { desktop: { label: "Desktop", color: "var(--chart-1)" } },
  #                rows: [ { month: "January", desktop: 186 }, { month: "February", desktop: 305 } ]) do %>
  #     <%= ui_chart_grid %>
  #     <%= ui_chart_x_axis(data_key: :month) %>
  #     <%= ui_chart_tooltip %>
  #     <%= ui_chart_bar(data_key: :desktop, radius: 4) %>
  #   <% end %>
  #
  # `config:` maps each series key — and each category a pie or a legend names —
  # to a `label:`, a `color:` (or a `theme:` of `light:` and `dark:` colors) and
  # an optional Lucide `icon:`. Each color becomes a `--color-<key>` custom
  # property scoped to this chart. That is what every part paints with, so a
  # theme change repaints the chart without any JavaScript, and your own markup
  # inside the chart can paint with the same properties.
  #
  # `layout: :vertical` runs the categories down the y axis (horizontal bars).
  # `stack_offset:` is D3's offset for series that share a `stack_id:`. The
  # polar arguments set the geometry pies, radial bars and radars share: radii
  # in pixels or as a percentage of the room there is, angles in degrees
  # clockwise from twelve o'clock.
  #
  # The drawing is D3's. The `ui-chart` controller works out the scales and
  # hands them to one controller per part, and imports D3 only on pages that
  # have a chart. Pin it in your importmap:
  #   pin "d3", to: "https://cdn.jsdelivr.net/npm/d3@7.9.0/+esm"
  class ChartComponent < UiComponent
    LAYOUTS = %i[horizontal vertical].freeze
    STACK_OFFSETS = %i[none expand diverging silhouette wiggle].freeze

    # Colors reach a stylesheet as written, so a color may hold nothing that
    # ends a declaration or a rule. Hex, rgb(), hsl(), oklch(), var(--chart-1)
    # and named colors all pass.
    SAFE_COLOR = %r{\A[\w\s#%.,()/+*-]+\z}

    THEMES = { light: "", dark: ".dark " }.freeze

    ACTIONS = [
      "ui-chart:connect->ui-chart#refresh",
      "turbo:morph@document->ui-chart#refresh",
      "turbo:before-cache@document->ui-chart#leave",
      "pointermove->ui-chart#pointer",
      "pointerleave->ui-chart#leave",
      "keydown->ui-chart#keydown",
      "focusout->ui-chart#blur"
    ].join(" ").freeze

    def initialize(config: {}, rows: [], layout: :horizontal, stack_offset: :none, margin: {},
                   inner_radius: 0, outer_radius: "80%", start_angle: 0, end_angle: 360,
                   label: nil, class_name: nil, **attrs)
      @config = normalize_config(config)
      @rows = rows
      @layout = LAYOUTS.include?(layout&.to_sym) ? layout.to_sym : :horizontal
      @stack_offset = STACK_OFFSETS.include?(stack_offset&.to_sym) ? stack_offset.to_sym : :none
      @margin = margin
      @inner_radius = inner_radius
      @outer_radius = outer_radius
      @start_angle = start_angle
      @end_angle = end_angle
      @label = label
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.figure(**figure_attrs) do
        safe_join([ theme_style, icon_templates, content ].compact)
      end
    end

    private

    def figure_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names(
          "relative flex aspect-video justify-center text-xs outline-none " \
          "focus-visible:ring-[3px] focus-visible:ring-ring/50",
          @class_name
        )
        attrs[:aria] = { label: @label }.merge(attrs.fetch(:aria, {})) if @label.present?
        attrs[:data] = attrs.fetch(:data, {}).to_h.dup.tap do |data|
          data[:slot] = "chart"
          data[:chart] = chart_id
          data[:controller] = append_token(data[:controller], "ui-chart")
          data[:action] = append_token(data[:action], ACTIONS)
          data[:ui_chart_rows_value] = @rows.to_a.to_json
          data[:ui_chart_config_value] = labels.to_json
          data[:ui_chart_layout_value] = @layout
          data[:ui_chart_stack_offset_value] = @stack_offset
          data[:ui_chart_margin_value] = @margin.to_h.to_json
          data[:ui_chart_inner_radius_value] = @inner_radius
          data[:ui_chart_outer_radius_value] = @outer_radius
          data[:ui_chart_start_angle_value] = @start_angle
          data[:ui_chart_end_angle_value] = @end_angle
          data[:ui_chart_locale_value] = locale.to_json
        end
      end
    end

    # Scopes the chart's colors, as data-chart does upstream. Taken from the id
    # when there is one, so the stylesheet is stable across renders.
    def chart_id
      @chart_id ||= "chart-#{(html_attrs[:id].presence || SecureRandom.hex(4)).to_s.gsub(/[^A-Za-z0-9_-]/, "")}"
    end

    # shadcn's ChartStyle: a `--color-<key>` for every configured color, with
    # the dark theme's overrides under `.dark`. A color given as `color:` holds
    # in both themes.
    def theme_style
      rules = THEMES.filter_map do |theme, prefix|
        declarations = @config.filter_map do |key, entry|
          color = theme_color(entry, theme)
          "--color-#{css_key(key)}: #{color};" if color
        end
        "#{prefix}[data-chart=#{chart_id}] { #{declarations.join(" ")} }" if declarations.any?
      end
      return if rules.empty?

      # Keys, the id and the colors are all sanitised, so the rules go out as
      # they are: escaping them would print &quot; into the stylesheet.
      tag.style(rules.join("\n").html_safe, nonce: csp_nonce)
    end

    def theme_color(entry, theme)
      color = entry[:theme].to_h.transform_keys(&:to_sym)[theme]
      color ||= entry[:color] if theme == :light
      color = color.to_s.strip
      color if color.match?(SAFE_COLOR)
    end

    # The Lucide icons the config names, for the legend and the tooltip to copy
    # in place of their color swatch.
    def icon_templates
      icons = @config.filter_map { |key, entry| [ key, entry[:icon].to_s ] if entry[:icon].present? }
      return if icons.empty?

      safe_join(icons.map { |key, icon|
        tag.template(render(Ui::IconComponent.new(icon, size: :sm)), data: { ui_chart_target: "icon", chart_key: key })
      })
    end

    def labels
      @config.to_h { |key, entry| [ key, { label: (entry[:label] || key).to_s } ] }
    end

    # The names and separators D3 formats with, from Rails' own translations —
    # the ones the calendar reads — so "%b" reads "Fev" on a Portuguese page.
    def locale
      {
        lang: I18n.locale.to_s,
        decimal: I18n.t("number.format.separator", default: "."),
        thousands: I18n.t("number.format.delimiter", default: ","),
        currency: currency_affixes,
        months: date_names("date.month_names"),
        shortMonths: date_names("date.abbr_month_names"),
        days: date_names("date.day_names"),
        shortDays: date_names("date.abbr_day_names")
      }.compact
    end

    def date_names(key)
      names = I18n.t(key, default: nil)
      names.compact.map(&:to_s) if names.is_a?(Array)
    end

    # Rails writes the currency as a template ("%u%n", "%n %u"); D3 wants what
    # goes before and after the number.
    def currency_affixes
      unit = I18n.t("number.currency.format.unit", default: "$").to_s
      template = I18n.t("number.currency.format.format", default: "%u%n").to_s
      before, after = template.split("%n", 2)

      [ before.to_s.gsub("%u", unit), after.to_s.gsub("%u", unit) ]
    end

    def normalize_config(config)
      config.to_h.to_h { |key, entry| [ key.to_s, entry.to_h.transform_keys(&:to_sym) ] }
    end

    def css_key(key)
      key.to_s.gsub(/[^A-Za-z0-9_-]/, "-")
    end

    def csp_nonce
      helpers.content_security_policy_nonce if helpers.respond_to?(:content_security_policy_nonce)
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
