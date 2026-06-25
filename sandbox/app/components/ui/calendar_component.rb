# frozen_string_literal: true

require "date"

module Ui
  # A single-month date picker grid. The ui-calendar controller builds and
  # navigates the month client-side (no server round-trip) and mirrors the
  # selected ISO date into a hidden input (`name:`). `month:`/`selected:`/`min:`/
  # `max:` accept `Date`s or `YYYY-MM(-DD)` strings.
  class CalendarComponent < UiComponent
    def initialize(month: nil, selected: nil, min: nil, max: nil, name: nil, week_start: 0, class_name: nil, **attrs)
      @month = normalize_month(month)
      @selected = normalize_date(selected)
      @min = normalize_date(min)
      @max = normalize_date(max)
      @name = name
      @week_start = week_start
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(**calendar_attrs) do
        safe_join([ header, grid, hidden_input ].compact)
      end
    end

    private

    def calendar_attrs
      html_attrs.dup.tap do |attrs|
        attrs[:class] = class_names("inline-block rounded-md border p-3", @class_name)
        attrs[:data] = calendar_data(attrs[:data])
      end
    end

    def calendar_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "calendar"
        data[:controller] = append_token(data[:controller], "ui-calendar")
        data[:ui_calendar_month_value] = @month
        data[:ui_calendar_selected_value] = @selected if @selected.present?
        data[:ui_calendar_min_value] = @min if @min.present?
        data[:ui_calendar_max_value] = @max if @max.present?
        data[:ui_calendar_week_start_value] = @week_start
      end
    end

    def header
      tag.div(class: "flex items-center justify-between pb-2") do
        safe_join([
          nav_button("chevron-left", "previous", "Mês anterior"),
          tag.div("", class: "text-sm font-medium", data: { ui_calendar_target: "label" }),
          nav_button("chevron-right", "next", "Próximo mês")
        ])
      end
    end

    def nav_button(icon, action, label)
      tag.button(
        type: "button",
        class: "inline-flex size-7 items-center justify-center rounded-md border border-input bg-transparent text-sm opacity-70 transition-opacity hover:opacity-100 focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none",
        aria: { label: label },
        data: { action: "click->ui-calendar##{action}" }
      ) { helpers.lucide_icon(icon, class: "size-4") }
    end

    def grid
      tag.div(
        "",
        role: "grid",
        class: "text-sm",
        data: { ui_calendar_target: "grid", action: "keydown->ui-calendar#keydown" }
      )
    end

    def hidden_input
      return unless @name.present?

      tag.input(type: "hidden", name: @name, value: @selected, data: { ui_calendar_target: "input" })
    end

    def normalize_month(value)
      return Date.today.strftime("%Y-%m") if value.blank?
      return value.strftime("%Y-%m") if value.respond_to?(:strftime)

      value.to_s[0, 7]
    end

    def normalize_date(value)
      return nil if value.blank?
      return value.strftime("%Y-%m-%d") if value.respond_to?(:strftime)

      value.to_s
    end

    def append_token(existing, token)
      [ existing, token ].compact_blank.join(" ")
    end
  end
end
