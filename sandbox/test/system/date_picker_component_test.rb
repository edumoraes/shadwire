# frozen_string_literal: true

require "application_system_test_case"

class DatePickerComponentTest < ApplicationSystemTestCase
  test "picking a day names the trigger, fills the field and closes the popover" do
    visit components_date_picker_path

    label = find("#example-date_picker_default [data-ui-date-picker-target='label']")
    assert_equal "true", label["data-empty"]

    find("#example-date_picker_default button[data-slot='popover-trigger']").click
    day = Date.current.beginning_of_month + 14
    find("#example-date_picker_default [data-date='#{day}']").click

    assert_no_selector "#example-date_picker_default [data-slot='popover-content']", visible: true
    assert_equal "false", label["data-empty"]
    assert_match(/\d/, label.text, "the trigger should show the picked date")
    assert_equal day.to_s, hidden_value("#example-date_picker_default input[name='due_on']")
  end

  test "a range stays open until both ends are picked" do
    visit components_date_picker_path

    find("#example-date_picker_range button[data-slot='popover-trigger']").click

    starts_on = Date.current.beginning_of_month + 4
    ends_on = Date.current.beginning_of_month + 9

    find("#example-date_picker_range [data-date='#{starts_on}']").click
    assert_selector "#example-date_picker_range [data-slot='popover-content']", visible: true

    find("#example-date_picker_range [data-date='#{ends_on}']").click
    assert_no_selector "#example-date_picker_range [data-slot='popover-content']", visible: true

    assert_equal starts_on.to_s, hidden_value("#example-date_picker_range input[name='stay[from]']")
    assert_equal ends_on.to_s, hidden_value("#example-date_picker_range input[name='stay[to]']")

    # The ends carry the selection, the days between them the span. The popover
    # is closed by now, so look past visibility.
    assert_selector "#example-date_picker_range [data-date='#{starts_on}'][data-selected='true']", visible: :all
    assert_selector "#example-date_picker_range [data-date='#{ends_on}'][data-selected='true']", visible: :all
    assert_selector "#example-date_picker_range [data-date='#{starts_on + 1}'][data-range-middle='true']", visible: :all
    assert_selector "#example-date_picker_range [data-date='#{ends_on + 1}'][data-range-middle='false']", visible: :all
  end

  test "the dropdown caption jumps decades without a round trip" do
    visit components_date_picker_path

    find("#born-on").click
    year = (Date.current.year - 30).to_s
    find("#example-date_picker_dob select[aria-label='Ano'] option[value='#{year}']").select_option

    assert_selector "#example-date_picker_dob [data-date^='#{year}-']"
  end

  # The options inherit `color` from the select — near-white under the dark
  # theme — so if their own background falls through to the UA surface the popup
  # is white text on white. Pinning it is the whole fix; the exact system colour
  # is the browser's business.
  test "the caption select popup does not fall through to the browser surface" do
    visit components_date_picker_path
    page.execute_script("document.documentElement.classList.add('dark')")
    find("#born-on").click

    background = page.evaluate_script(<<~JS)
      getComputedStyle(document.querySelector("#example-date_picker_dob select[aria-label='Ano'] option")).backgroundColor
    JS

    refute_equal "rgba(0, 0, 0, 0)", background,
                 "the option must paint its own surface, not inherit the UA's"
  end

  test "typing a date moves the calendar and picking one writes it back" do
    visit components_date_picker_path

    field = find("#subscribed-on")
    assert_match(/\d/, field.value, "the seeded date should show up once the calendar connects")

    field.set("2026-08-01")
    assert_selector "#example-date_picker_input [data-date='2026-08-01']", visible: :all
    assert_equal "2026-08-01", hidden_value("#example-date_picker_input input[name='subscribed_on']")

    find("#example-date_picker_input button[aria-label='Escolher data']").click
    find("#example-date_picker_input [data-date='2026-08-12']").click

    assert_equal "2026-08-12", hidden_value("#example-date_picker_input input[name='subscribed_on']")
    assert_match(/12/, field.value, "the picked date should come back formatted into the input")
  end

  test "natural language phrases resolve to a date" do
    visit components_date_picker_path

    assert_selector "#example-date_picker_natural [data-ui-date-picker-target='preview']", text: /\S/
    assert_equal (Date.current + 2).to_s,
                 hidden_value("#example-date_picker_natural input[name='post[publish_on]']")

    find("#publish-on").set("amanhã")

    tomorrow = Date.current + 1
    assert_selector "#example-date_picker_natural [data-date='#{tomorrow}'][data-selected='true']", visible: :all
    assert_equal tomorrow.to_s, hidden_value("#example-date_picker_natural input[name='post[publish_on]']")
  end

  private

  # The calendar mirrors its selection into a hidden input, so that is where the
  # form value lives — never rendered, always current.
  def hidden_value(selector)
    find(selector, visible: :all).value
  end
end
