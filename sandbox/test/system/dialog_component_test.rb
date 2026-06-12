# frozen_string_literal: true

require "application_system_test_case"

class DialogComponentTest < ApplicationSystemTestCase
  test "dialog opens as a modal, wires aria, and closes by escape, backdrop, and buttons" do
    visit components_dialog_path

    assert_no_selector "dialog[data-slot='dialog-content']"

    within "#example-dialog_default" do
      click_button "Editar perfil"
    end

    dialog = find("dialog[data-slot='dialog-content'][open]")

    assert_equal "open", dialog["data-state"]
    assert dialog["aria-labelledby"].present?
    assert dialog["aria-describedby"].present?
    assert_selector "dialog[open] h2", text: "Editar perfil"

    dialog.send_keys :escape

    assert_no_selector "dialog[open]"
    assert_no_selector "dialog[data-slot='dialog-content']"

    within "#example-dialog_default" do
      assert_equal "Editar perfil", page.evaluate_script("document.activeElement.textContent").strip
      click_button "Editar perfil"
    end

    dialog = find("dialog[data-slot='dialog-content'][open]")
    dialog.execute_script(<<~JS)
      const rect = this.getBoundingClientRect()
      this.dispatchEvent(new MouseEvent("click", { bubbles: true, clientX: rect.left - 40, clientY: rect.top - 40 }))
    JS

    assert_no_selector "dialog[open]"
    assert_no_selector "dialog[data-slot='dialog-content']"

    within "#example-dialog_default" do
      click_button "Editar perfil"
    end

    within "dialog[open]" do
      click_button "Cancelar"
    end

    assert_no_selector "dialog[open]"
    assert_no_selector "dialog[data-slot='dialog-content']"
  end

  test "dialog with close_on_backdrop false ignores outside clicks" do
    visit components_dialog_path

    within "#example-dialog_no_backdrop_close" do
      click_button "Sem fechar pelo backdrop"
    end

    dialog = find("dialog[data-slot='dialog-content'][open]")
    dialog.execute_script(<<~JS)
      const rect = this.getBoundingClientRect()
      this.dispatchEvent(new MouseEvent("click", { bubbles: true, clientX: rect.left - 40, clientY: rect.top - 40 }))
    JS

    assert_selector "dialog[open]", text: "Atenção"

    within "dialog[open]" do
      click_button "Entendi"
    end

    assert_no_selector "dialog[open]"
    assert_no_selector "dialog[data-slot='dialog-content']"
  end
end
