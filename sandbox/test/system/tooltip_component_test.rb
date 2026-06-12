# frozen_string_literal: true

require "application_system_test_case"

class TooltipComponentTest < ApplicationSystemTestCase
  test "tooltip opens on focus, links aria-describedby, and dismisses with escape" do
    visit components_tooltip_path

    trigger = find("#example-tooltip_default button", text: "Passe o mouse")
    content = find("#example-tooltip_default [role='tooltip']", visible: :all)

    assert_equal content["id"], trigger["aria-describedby"]
    assert_no_selector "#example-tooltip_default [role='tooltip']", visible: true

    trigger.execute_script("this.focus()")

    assert_selector "#example-tooltip_default [role='tooltip'][data-state='open']", visible: true

    trigger.send_keys :escape

    assert_no_selector "#example-tooltip_default [role='tooltip'][data-state='open']", visible: :all
    assert_no_selector "#example-tooltip_default [role='tooltip']", visible: true
    assert_equal "Passe o mouse", page.evaluate_script("document.activeElement.textContent").strip,
                 "focus should stay on the trigger after Escape"
  end
end
