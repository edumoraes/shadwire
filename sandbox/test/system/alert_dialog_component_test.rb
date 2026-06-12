# frozen_string_literal: true

require "application_system_test_case"

class AlertDialogComponentTest < ApplicationSystemTestCase
  test "alert dialog ignores escape and backdrop, closing only by explicit choice" do
    visit components_alert_dialog_path

    assert_no_selector "dialog[data-slot='alert-dialog-content']"

    within "#example-alert_dialog_default" do
      click_button "Excluir conta"
    end

    dialog = find("dialog[role='alertdialog'][open]")

    assert dialog["aria-labelledby"].present?

    dialog.send_keys :escape

    assert_selector "dialog[role='alertdialog'][open]", text: "Tem certeza absoluta?"

    dialog.execute_script(<<~JS)
      const rect = this.getBoundingClientRect()
      this.dispatchEvent(new MouseEvent("click", { bubbles: true, clientX: rect.left - 40, clientY: rect.top - 40 }))
    JS

    assert_selector "dialog[role='alertdialog'][open]"

    within "dialog[open]" do
      click_button "Cancelar"
    end

    assert_no_selector "dialog[open]"
    assert_no_selector "dialog[data-slot='alert-dialog-content']"

    within "#example-alert_dialog_default" do
      click_button "Excluir conta"
    end

    within "dialog[open]" do
      click_button "Continuar"
    end

    assert_no_selector "dialog[open]"
    assert_no_selector "dialog[data-slot='alert-dialog-content']"
  end
end
