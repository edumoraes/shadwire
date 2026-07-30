# frozen_string_literal: true

require "date"

module Ui
  # A date picker grid. The ui-calendar controller builds and navigates the
  # month(s) client-side (no server round-trip) and mirrors the selection into
  # hidden inputs.
  #
  # - `mode: :range` picks a span; pair `name:` (start) with `end_name:` (end).
  # - `number_of_months: 2` shows consecutive months side by side.
  # - `caption_layout: :dropdown` swaps the month label for month/year selects,
  #   bounded by `year_range:` (or by `min:`/`max:` when given).
  # - `dir: :rtl` flips the grid, the nav arrows and the arrow keys.
  # - `month_names:`/`day_names:` localize the caption and column headers, e.g.
  #   `month_names: I18n.t("date.month_names").compact`.
  #
  # `month:`/`selected:`/`from:`/`to:`/`min:`/`max:` accept `Date`s or
  # `YYYY-MM(-DD)` strings; `selected:` also accepts a `Date` range or array.
  # The first visible month defaults to the selection's month.
  class CalendarComponent < UiComponent
    MODES = [ :single, :range ].freeze
    CAPTION_LAYOUTS = [ :label, :dropdown ].freeze
    # How far the year dropdown reaches when neither `year_range:` nor
    # `min:`/`max:` bounds it — wide enough back for a date of birth.
    DEFAULT_YEARS_BACK = 100
    DEFAULT_YEARS_AHEAD = 10

    def initialize(
      month: nil, selected: nil, from: nil, to: nil, min: nil, max: nil,
      name: nil, end_name: nil, mode: :single, number_of_months: 1,
      caption_layout: :label, year_range: nil, dir: nil, week_start: 0,
      month_names: nil, day_names: nil, class_name: nil, **attrs
    )
      @mode = fetch_option(MODES, mode, fallback: :single)
      @caption_layout = fetch_option(CAPTION_LAYOUTS, caption_layout, fallback: :label)
      first, last = split_selection(selected)
      @selected = range? ? nil : normalize_date(first)
      @from = normalize_date(from || (range? ? first : nil))
      @to = normalize_date(to || (range? ? last : nil))
      @min = normalize_date(min)
      @max = normalize_date(max)
      @month = normalize_month(month || @selected || @from)
      @name = name
      @end_name = end_name
      @number_of_months = [ number_of_months.to_i, 1 ].max
      @year_range = year_bounds(year_range)
      @dir = dir.presence&.to_s
      @week_start = week_start
      @month_names = month_names.presence
      @day_names = day_names.presence
      @attrs = attrs
      @class_name = extract_class_name(@attrs, class_name)
    end

    def call
      tag.div(**calendar_attrs) do
        safe_join([ month_area, hidden_inputs ].compact)
      end
    end

    private

    def range?
      @mode == :range
    end

    def dropdown?
      @caption_layout == :dropdown
    end

    def rtl?
      @dir == "rtl"
    end

    def calendar_attrs
      html_attrs.dup.tap do |attrs|
        # No frame of its own: inside a popover the popover draws it. Rendered
        # inline, add one — `ui_calendar(class: "border")`.
        attrs[:class] = class_names("inline-block rounded-md p-3", @class_name)
        attrs[:dir] = @dir if @dir
        attrs[:data] = calendar_data(attrs[:data])
      end
    end

    def calendar_data(existing_data)
      existing_data.to_h.dup.tap do |data|
        data[:slot] = "calendar"
        data[:controller] = append_token(data[:controller], "ui-calendar")
        data[:ui_calendar_month_value] = @month
        data[:ui_calendar_selected_value] = @selected if @selected.present?
        data[:ui_calendar_from_value] = @from if @from.present?
        data[:ui_calendar_to_value] = @to if @to.present?
        data[:ui_calendar_min_value] = @min if @min.present?
        data[:ui_calendar_max_value] = @max if @max.present?
        data[:ui_calendar_week_start_value] = @week_start
        data[:ui_calendar_mode_value] = @mode if range?
        data[:ui_calendar_number_of_months_value] = @number_of_months if @number_of_months > 1
        data.merge!(dropdown_data) if dropdown?
        data[:ui_calendar_month_names_value] = @month_names.to_json if @month_names
        data[:ui_calendar_day_names_value] = @day_names.to_json if @day_names
      end
    end

    def dropdown_data
      {
        ui_calendar_caption_layout_value: @caption_layout,
        ui_calendar_first_year_value: @year_range.first,
        ui_calendar_last_year_value: @year_range.last
      }
    end

    # The nav sits in an overlay so it can hug both edges of a one- or
    # two-month span while the client-rendered captions stay centred.
    def month_area
      tag.div(class: "relative") do
        safe_join([ nav, months ])
      end
    end

    def nav
      tag.div(class: "pointer-events-none absolute inset-x-0 top-0 flex items-center justify-between") do
        safe_join([
          nav_button(rtl? ? "chevron-right" : "chevron-left", "previous", "Mês anterior"),
          nav_button(rtl? ? "chevron-left" : "chevron-right", "next", "Próximo mês")
        ])
      end
    end

    def nav_button(icon, action, label)
      tag.button(
        type: "button",
        class: "pointer-events-auto inline-flex size-7 items-center justify-center rounded-md border border-input bg-transparent text-sm opacity-70 transition-opacity hover:opacity-100 focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none",
        aria: { label: label },
        data: { action: "click->ui-calendar##{action}" }
      ) { helpers.lucide_icon(icon, class: "size-4") }
    end

    def months
      tag.div(
        "",
        class: "flex gap-4",
        data: {
          ui_calendar_target: "months",
          action: "keydown->ui-calendar#keydown mouseover->ui-calendar#preview mouseleave->ui-calendar#clearPreview"
        }
      )
    end

    def hidden_inputs
      inputs = [ hidden_input(@name, range? ? @from : @selected, "input") ]
      inputs << hidden_input(@end_name, @to, "endInput") if range?
      inputs.compact!
      return nil if inputs.empty?

      safe_join(inputs)
    end

    def hidden_input(name, value, target)
      return nil if name.blank?

      tag.input(type: "hidden", name: name, value: value, data: { ui_calendar_target: target })
    end

    def split_selection(value)
      return [ value.first, value.last ] if value.is_a?(Range) || value.is_a?(Array)

      [ value, nil ]
    end

    # Explicit `year_range:` wins; otherwise `min:`/`max:` bound the dropdown so
    # it can never offer a year the calendar would disable anyway.
    def year_bounds(year_range)
      return [ year_range.first.to_i, year_range.last.to_i ] if year_range.present?

      [
        @min ? year_of(@min) : Date.today.year - DEFAULT_YEARS_BACK,
        @max ? year_of(@max) : Date.today.year + DEFAULT_YEARS_AHEAD
      ]
    end

    def year_of(iso)
      iso.to_s[0, 4].to_i
    end

    def fetch_option(allowed, value, fallback:)
      key = value.presence&.to_sym
      allowed.include?(key) ? key : fallback
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
