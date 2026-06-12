# frozen_string_literal: true

require "application_system_test_case"

class SelectComponentTest < ApplicationSystemTestCase
  test "select opens, keeps focus on the trigger, and commits to the hidden input" do
    visit components_select_path

    root = find("#example-select_default [data-controller='ui-select']")
    trigger = root.find("button[role='combobox']")
    hidden = root.find("input[type='hidden']", visible: :all)

    assert_equal "false", trigger["aria-expanded"]
    assert_text "Selecione uma fruta"
    assert_equal "", hidden.value

    trigger.send_keys :enter

    assert_equal "true", trigger["aria-expanded"]
    assert_selector "#example-select_default [role='listbox']", visible: true
    assert_equal "combobox", page.evaluate_script("document.activeElement.getAttribute('role')"),
                 "focus should stay on the combobox while open"

    # ArrowDown highlights an option via aria-activedescendant, then Enter commits.
    send_active_key(:arrow_down)
    send_active_key(:arrow_down)
    highlighted_value = root.find("[role='option'][data-highlighted]", visible: :all)["data-value"]
    send_active_key(:enter)

    assert_no_selector "#example-select_default [role='listbox']", visible: true
    assert_equal highlighted_value, hidden.value
    assert_equal "combobox", page.evaluate_script("document.activeElement.getAttribute('role')")
  end

  test "clicking an option selects it and updates the value label" do
    visit components_select_path

    within "#example-select_default" do
      find("button[role='combobox']").click
      find("[role='option'][data-value='pineapple']").click
    end

    within "#example-select_default" do
      assert_no_selector "[role='listbox']", visible: true
      assert_equal "pineapple", find("input[type='hidden']", visible: :all).value
      assert_selector "[data-slot='select-value']", text: "Abacaxi"
      assert_selector "[role='option'][data-value='pineapple'][aria-selected='true']", visible: :all
    end
  end

  test "groups render preselected value and skip disabled options" do
    visit components_select_path

    within "#example-select_groups" do
      assert_selector "[data-slot='select-value']", text: /Leste/
      find("button[role='combobox']").send_keys :enter
    end

    # The preselected EST option is highlighted on open.
    assert_match(/Leste/, page.find("#example-select_groups [role='option'][data-highlighted]", visible: :all).text)
  end

  private

  def send_active_key(key)
    page.driver.browser.switch_to.active_element.send_keys(key)
  end
end
