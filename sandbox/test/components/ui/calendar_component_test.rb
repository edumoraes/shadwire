# frozen_string_literal: true

require "test_helper"

class CalendarComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include Ui::CalendarHelper

    def call
      ui_calendar(month: "2026-06", selected: "2026-06-15", name: "due_on")
    end
  end

  def test_wires_controller_with_month_values
    render_inline(Ui::CalendarComponent.new(month: "2026-06", selected: "2026-06-15", min: "2026-06-01"))

    assert_selector "[data-controller='ui-calendar'][data-slot='calendar'][data-ui-calendar-month-value='2026-06'][data-ui-calendar-selected-value='2026-06-15'][data-ui-calendar-min-value='2026-06-01']"
  end

  def test_renders_nav_and_grid_scaffold
    render_inline(Ui::CalendarComponent.new(month: "2026-06"))

    assert_selector "button[aria-label='Previous month'][data-action='click->ui-calendar#previous']"
    assert_selector "button[aria-label='Next month'][data-action='click->ui-calendar#next']"
    assert_selector "[data-ui-calendar-target='months'][data-action*='keydown->ui-calendar#keydown']"
    assert_selector "[data-ui-calendar-target='months'][data-action*='mouseover->ui-calendar#preview']"
  end

  def test_accepts_ruby_date_objects
    render_inline(Ui::CalendarComponent.new(month: Date.new(2026, 6, 1), selected: Date.new(2026, 6, 20)))

    assert_selector "[data-ui-calendar-month-value='2026-06'][data-ui-calendar-selected-value='2026-06-20']"
  end

  def test_first_visible_month_defaults_to_the_selection
    render_inline(Ui::CalendarComponent.new(selected: Date.new(2031, 3, 9)))

    assert_selector "[data-ui-calendar-month-value='2031-03']"
  end

  def test_helper_renders_hidden_input
    render_inline(HelperHarnessComponent.new)

    assert_selector "input[type='hidden'][name='due_on'][value='2026-06-15'][data-ui-calendar-target='input']", visible: :all
  end

  def test_single_mode_stays_free_of_range_wiring
    render_inline(Ui::CalendarComponent.new(month: "2026-06", name: "due_on", end_name: "ignored"))

    assert_no_selector "[data-ui-calendar-mode-value]"
    assert_no_selector "[data-ui-calendar-target='endInput']", visible: :all
  end

  def test_range_mode_writes_both_ends
    render_inline(
      Ui::CalendarComponent.new(
        mode: :range,
        selected: Date.new(2026, 6, 1)..Date.new(2026, 6, 21),
        number_of_months: 2,
        name: "stay[from]",
        end_name: "stay[to]"
      )
    )

    assert_selector "[data-ui-calendar-mode-value='range'][data-ui-calendar-from-value='2026-06-01'][data-ui-calendar-to-value='2026-06-21'][data-ui-calendar-number-of-months-value='2']"
    assert_selector "input[type='hidden'][name='stay[from]'][value='2026-06-01'][data-ui-calendar-target='input']", visible: :all
    assert_selector "input[type='hidden'][name='stay[to]'][value='2026-06-21'][data-ui-calendar-target='endInput']", visible: :all
    assert_no_selector "[data-ui-calendar-selected-value]"
  end

  def test_range_accepts_separate_ends
    render_inline(Ui::CalendarComponent.new(mode: :range, from: "2026-06-01", to: "2026-06-05"))

    assert_selector "[data-ui-calendar-from-value='2026-06-01'][data-ui-calendar-to-value='2026-06-05'][data-ui-calendar-month-value='2026-06']"
  end

  def test_dropdown_caption_bounds_years_by_max
    travel_to Date.new(2026, 6, 1) do
      render_inline(Ui::CalendarComponent.new(caption_layout: :dropdown, max: Date.new(2026, 6, 1)))

      assert_selector "[data-ui-calendar-caption-layout-value='dropdown'][data-ui-calendar-first-year-value='1926'][data-ui-calendar-last-year-value='2026']"
    end
  end

  def test_explicit_year_range_wins_over_min_and_max
    render_inline(Ui::CalendarComponent.new(caption_layout: :dropdown, min: "2000-01-01", year_range: 1970..1990))

    assert_selector "[data-ui-calendar-first-year-value='1970'][data-ui-calendar-last-year-value='1990']"
  end

  def test_label_caption_omits_dropdown_wiring
    render_inline(Ui::CalendarComponent.new(month: "2026-06"))

    assert_no_selector "[data-ui-calendar-caption-layout-value]"
    assert_no_selector "[data-ui-calendar-first-year-value]"
  end

  # lucide-rails inlines the raw path, so the arrow direction only shows up in
  # the path data — these are Lucide's chevron-left and chevron-right.
  CHEVRON_LEFT = "m15 18-6-6 6-6"
  CHEVRON_RIGHT = "m9 18 6-6-6-6"

  def test_nav_arrows_point_forward_by_default
    render_inline(Ui::CalendarComponent.new(month: "2026-06"))

    assert_no_selector "[data-slot='calendar'][dir]"
    assert_selector "button[aria-label='Previous month'] svg path[d='#{CHEVRON_LEFT}']"
    assert_selector "button[aria-label='Next month'] svg path[d='#{CHEVRON_RIGHT}']"
  end

  def test_rtl_flips_the_nav_arrows
    render_inline(Ui::CalendarComponent.new(month: "2026-06", dir: :rtl))

    assert_selector "[data-slot='calendar'][dir='rtl']"
    assert_selector "button[aria-label='Previous month'] svg path[d='#{CHEVRON_RIGHT}']"
    assert_selector "button[aria-label='Next month'] svg path[d='#{CHEVRON_LEFT}']"
  end

  def test_localized_labels_ride_along_as_json
    render_inline(Ui::CalendarComponent.new(month: "2026-06", month_names: %w[Jan Fev], day_names: %w[D S]))

    assert_selector "[data-ui-calendar-month-names-value='[\"Jan\",\"Fev\"]']"
    assert_selector "[data-ui-calendar-day-names-value='[\"D\",\"S\"]']"
  end

  def test_unknown_mode_falls_back_to_single
    render_inline(Ui::CalendarComponent.new(month: "2026-06", mode: :multiple, caption_layout: :bogus))

    assert_no_selector "[data-ui-calendar-mode-value]"
    assert_no_selector "[data-ui-calendar-caption-layout-value]"
  end
end
