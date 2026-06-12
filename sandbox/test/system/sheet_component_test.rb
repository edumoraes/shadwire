# frozen_string_literal: true

require "application_system_test_case"

class SheetComponentTest < ApplicationSystemTestCase
  test "sheet slides in anchored to a side and closes by escape" do
    visit components_sheet_path

    within "#example-sheet_default" do
      click_button "Abrir sheet"
    end

    sheet = find("dialog[data-slot='sheet-content'][open]")

    assert_equal "right", sheet["data-side"]
    assert sheet["aria-labelledby"].present?

    sheet.evaluate_async_script(
      "const done = arguments[0]; Promise.all(this.getAnimations().map((a) => a.finished)).then(() => done(true))"
    )
    viewport_width = page.evaluate_script("document.documentElement.clientWidth")
    sheet_right = sheet.evaluate_script("this.getBoundingClientRect().right")

    assert_in_delta viewport_width, sheet_right, 2

    sheet.send_keys :escape

    assert_no_selector "dialog[open]"

    within "#example-sheet_sides" do
      click_button "Base"
    end

    bottom_sheet = find("dialog[data-slot='sheet-content'][open]")

    assert_equal "bottom", bottom_sheet["data-side"]

    within "dialog[open]" do
      find("[data-slot='sheet-close']").click
    end

    assert_no_selector "dialog[open]"
  end
end
