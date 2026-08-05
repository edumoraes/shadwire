# frozen_string_literal: true

require "application_system_test_case"

class AlertDialogComponentTest < ApplicationSystemTestCase
  test "alert dialog ignores escape and backdrop, closing only by explicit choice" do
    visit components_alert_dialog_path

    assert_no_selector "dialog[data-slot='alert-dialog-content']"

    within "#example-alert_dialog_default" do
      click_button "Delete account"
    end

    dialog = find("dialog[role='alertdialog'][open]")

    assert dialog["aria-labelledby"].present?

    dialog.send_keys :escape

    assert_selector "dialog[role='alertdialog'][open]", text: "Are you absolutely sure?"

    dialog.execute_script(<<~JS)
      const rect = this.getBoundingClientRect()
      this.dispatchEvent(new MouseEvent("click", { bubbles: true, clientX: rect.left - 40, clientY: rect.top - 40 }))
    JS

    assert_selector "dialog[role='alertdialog'][open]"

    within "dialog[open]" do
      click_button "Cancel"
    end

    assert_no_selector "dialog[open]"
    assert_no_selector "dialog[data-slot='alert-dialog-content']"

    within "#example-alert_dialog_default" do
      click_button "Delete account"
    end

    within "dialog[open]" do
      click_button "Continue"
    end

    assert_no_selector "dialog[open]"
    assert_no_selector "dialog[data-slot='alert-dialog-content']"
  end
end
