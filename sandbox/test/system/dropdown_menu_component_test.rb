# frozen_string_literal: true

require "application_system_test_case"

class DropdownMenuComponentTest < ApplicationSystemTestCase
  test "menu opens with the keyboard, roves focus, typeaheads, and dismisses" do
    visit components_dropdown_menu_path

    trigger = find("#example-dropdown_menu_default button", text: "Abrir")

    assert_equal "false", trigger["aria-expanded"]
    assert_no_selector "#example-dropdown_menu_default [role='menu']", visible: true

    # ArrowDown opens and focuses the first item.
    trigger.send_keys :arrow_down

    assert_selector "#example-dropdown_menu_default [role='menu'][data-state='open']", visible: true
    assert_equal "true", trigger["aria-expanded"]
    assert_equal "Perfil", focused_item_text

    # ArrowDown roves to the next item; wrapping back to the top.
    send_active_key(:arrow_down)
    assert_match(/Configurações/, focused_item_text)

    send_active_key(:arrow_down)
    assert_equal "Perfil", focused_item_text

    # Typeahead jumps to the item starting with "c".
    send_active_key("c")
    assert_match(/Configurações/, focused_item_text)

    # Escape closes and returns focus to the trigger.
    send_active_key(:escape)
    assert_no_selector "#example-dropdown_menu_default [role='menu']", visible: true
    assert_equal "Abrir", page.evaluate_script("document.activeElement.textContent").strip
  end

  test "disabled items are skipped during keyboard navigation" do
    visit components_dropdown_menu_path

    find("#example-dropdown_menu_variants button", text: "Ações").send_keys :arrow_down

    assert_equal "Duplicar", focused_item_text

    send_active_key(:arrow_down)

    refute_equal "Indisponível", focused_item_text, "disabled item should be skipped"
    assert_match(/Documentação/, focused_item_text)
  end

  private

  # The first non-empty line of the focused item, ignoring nested shortcut text.
  def focused_item_text
    page.evaluate_script("document.activeElement.textContent")
        .split("\n").map(&:strip).reject(&:empty?).first.to_s
  end

  def send_active_key(key)
    page.driver.browser.switch_to.active_element.send_keys(key)
  end
end
