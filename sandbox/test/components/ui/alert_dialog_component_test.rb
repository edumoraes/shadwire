# frozen_string_literal: true

require "test_helper"

class AlertDialogComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_alert_dialog(id: "delete-dialog") do
        ui_alert_dialog_trigger(variant: :destructive) { "Excluir conta" } +
          ui_alert_dialog_content do
            ui_alert_dialog_header do
              ui_alert_dialog_title { "Tem certeza absoluta?" } +
                ui_alert_dialog_description { "Esta ação não pode ser desfeita." }
            end +
              ui_alert_dialog_footer do
                ui_alert_dialog_cancel { "Cancelar" } + ui_alert_dialog_action { "Continuar" }
              end
          end
      end
    end
  end

  def test_root_disables_backdrop_and_escape_close
    render_inline(Ui::AlertDialogComponent.new) { "x" }

    assert_selector "[data-controller='ui-dialog'][data-slot='alert-dialog']" \
                    "[data-ui-dialog-close-on-backdrop-value='false'][data-ui-dialog-close-on-escape-value='false']"
  end

  def test_trigger_renders_button_with_open_action
    render_inline(Ui::AlertDialog::TriggerComponent.new) { "Excluir" }

    assert_selector "button[type='button'][aria-haspopup='dialog'][data-slot='alert-dialog-trigger']" \
                    "[data-action='click->ui-dialog#open']", text: "Excluir"
  end

  def test_content_renders_alertdialog_role_without_close_button
    render_inline(Ui::AlertDialog::ContentComponent.new) { "Corpo" }

    assert_selector "dialog[role='alertdialog'][data-slot='alert-dialog-content'][data-ui-dialog-target='dialog']",
                    visible: :all, text: "Corpo"
    assert_no_selector "[data-slot='dialog-close-x']", visible: :all
  end

  def test_header_title_description_and_footer
    view = vc_test_controller.view_context
    header = Ui::AlertDialog::HeaderComponent.new.render_in(view) do
      Ui::AlertDialog::TitleComponent.new.render_in(view) { "Título" } +
        Ui::AlertDialog::DescriptionComponent.new.render_in(view) { "Descrição" }
    end
    footer = Ui::AlertDialog::FooterComponent.new.render_in(view) { "ações" }

    render_inline(Ui::AlertDialog::ContentComponent.new) { header + footer }

    assert_selector "dialog [data-slot='alert-dialog-header'] h2[data-slot='alert-dialog-title']",
                    visible: :all, text: "Título"
    assert_selector "dialog p[data-slot='alert-dialog-description']", visible: :all, text: "Descrição"
    assert_selector "dialog [data-slot='alert-dialog-footer']", visible: :all, text: "ações"
  end

  def test_action_and_cancel_close_the_dialog
    render_inline(Ui::AlertDialog::ActionComponent.new) { "Continuar" }

    assert_selector "button[data-slot='alert-dialog-action'][data-action='click->ui-dialog#close'].bg-primary",
                    text: "Continuar"

    render_inline(Ui::AlertDialog::CancelComponent.new) { "Cancelar" }

    assert_selector "button[data-slot='alert-dialog-cancel'][data-action='click->ui-dialog#close'].border",
                    text: "Cancelar"
  end

  def test_helper_methods_render_alert_dialog
    render_inline(HelperHarnessComponent.new)

    assert_selector "#delete-dialog[data-controller='ui-dialog'][data-ui-dialog-close-on-escape-value='false']"
    assert_selector "button.bg-destructive[aria-haspopup='dialog']", text: "Excluir conta"
    assert_selector "dialog[role='alertdialog'] h2", visible: :all, text: "Tem certeza absoluta?"
    assert_selector "dialog [data-slot='alert-dialog-footer'] button", visible: :all, count: 2
  end
end
