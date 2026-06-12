# frozen_string_literal: true

require "application_system_test_case"

class PopoverComponentTest < ApplicationSystemTestCase
  test "popover toggles, moves focus in, and closes on outside click and escape" do
    visit components_popover_path

    trigger = find("#example-popover_default button", text: "Abrir dimensões")

    assert_equal "false", trigger["aria-expanded"]
    assert_no_selector "#example-popover_default [data-slot='popover-content']", visible: true

    trigger.click

    assert_selector "#example-popover_default [data-slot='popover-content'][data-state='open']", visible: true
    assert_equal "true", trigger["aria-expanded"]
    assert_equal "popover-content",
                 page.evaluate_script("document.activeElement.getAttribute('data-slot')"),
                 "focus should move into the popover content on open"

    find("h1", text: "Popover").click

    assert_no_selector "#example-popover_default [data-slot='popover-content']", visible: true
    assert_equal "false", trigger["aria-expanded"]

    trigger.click

    assert_selector "#example-popover_default [data-slot='popover-content']", visible: true

    trigger.send_keys :escape

    assert_no_selector "#example-popover_default [data-slot='popover-content']", visible: true
    assert_equal "Abrir dimensões", page.evaluate_script("document.activeElement.textContent").strip,
                 "focus should return to the trigger after Escape"
  end
end
