# frozen_string_literal: true

require "test_helper"

class CalendarComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

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

    assert_selector "button[aria-label='Mês anterior'][data-action='click->ui-calendar#previous']"
    assert_selector "button[aria-label='Próximo mês'][data-action='click->ui-calendar#next']"
    assert_selector "[data-ui-calendar-target='label']"
    assert_selector "[role='grid'][data-ui-calendar-target='grid'][data-action='keydown->ui-calendar#keydown']"
  end

  def test_accepts_ruby_date_objects
    render_inline(Ui::CalendarComponent.new(month: Date.new(2026, 6, 1), selected: Date.new(2026, 6, 20)))

    assert_selector "[data-ui-calendar-month-value='2026-06'][data-ui-calendar-selected-value='2026-06-20']"
  end

  def test_helper_renders_hidden_input
    render_inline(HelperHarnessComponent.new)

    assert_selector "input[type='hidden'][name='due_on'][value='2026-06-15'][data-ui-calendar-target='input']", visible: :all
  end
end
