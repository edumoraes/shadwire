# frozen_string_literal: true

require "test_helper"

class DialogComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include Ui::DialogHelper

    def call
      ui_dialog(id: "profile-dialog") do
        ui_dialog_trigger(variant: :outline) { "Edit profile" } +
          ui_dialog_content do
            ui_dialog_header do
              ui_dialog_title { "Edit profile" } +
                ui_dialog_description { "Make changes to your profile here." }
            end +
              ui_dialog_footer do
                ui_dialog_close { "Cancel" }
              end
          end
      end
    end
  end

  def test_root_renders_stimulus_controller
    render_inline(Ui::DialogComponent.new) { "content" }

    assert_selector "[data-controller='ui-dialog'][data-slot='dialog']", text: "content"
  end

  def test_root_can_disable_backdrop_close
    render_inline(Ui::DialogComponent.new(close_on_backdrop: false)) { "x" }

    assert_selector "[data-ui-dialog-close-on-backdrop-value='false']"
  end

  def test_trigger_renders_button_with_open_action
    render_inline(Ui::Dialog::TriggerComponent.new) { "Open" }

    assert_selector "button[type='button'][aria-haspopup='dialog'][data-slot='dialog-trigger']", text: "Open"
    assert_selector "button[data-action='click->ui-dialog#open']"
  end

  def test_content_renders_native_dialog_with_actions_and_close_button
    render_inline(Ui::Dialog::ContentComponent.new) { "Corpo" }

    assert_selector "dialog[data-ui-dialog-target='dialog'][data-slot='dialog-content']", visible: :all, text: "Corpo"
    assert_selector "dialog[data-action='click->ui-dialog#backdropClick cancel->ui-dialog#cancel close->ui-dialog#closed']",
                    visible: :all
    assert_selector "dialog button[data-slot='dialog-close-x'][data-action='click->ui-dialog#close'] span.sr-only",
                    visible: :all, text: "Close"
  end

  def test_content_can_omit_close_button
    render_inline(Ui::Dialog::ContentComponent.new(show_close_button: false)) { "Corpo" }

    assert_no_selector "dialog [data-slot='dialog-close-x']", visible: :all
  end

  def test_header_title_description_and_footer
    view = vc_test_controller.view_context
    header = Ui::Dialog::HeaderComponent.new.render_in(view) do
      Ui::Dialog::TitleComponent.new.render_in(view) { "Title" } +
        Ui::Dialog::DescriptionComponent.new.render_in(view) { "Description" }
    end
    footer = Ui::Dialog::FooterComponent.new.render_in(view) { "actions" }

    render_inline(Ui::Dialog::ContentComponent.new) { header + footer }

    assert_selector "dialog [data-slot='dialog-header'] h2[data-slot='dialog-title']", visible: :all, text: "Title"
    assert_selector "dialog [data-slot='dialog-header'] p[data-slot='dialog-description']", visible: :all, text: "Description"
    assert_selector "dialog [data-slot='dialog-footer']", visible: :all, text: "actions"
  end

  def test_close_component_renders_button_with_close_action
    render_inline(Ui::Dialog::CloseComponent.new) { "Cancel" }

    assert_selector "button[type='button'][data-slot='dialog-close'][data-action='click->ui-dialog#close'].border",
                    text: "Cancel"
  end

  def test_helper_methods_render_dialog
    render_inline(HelperHarnessComponent.new)

    assert_selector "#profile-dialog[data-controller='ui-dialog']"
    assert_selector "button[aria-haspopup='dialog']", text: "Edit profile"
    assert_selector "dialog h2[data-slot='dialog-title']", visible: :all, text: "Edit profile"
    assert_selector "dialog [data-slot='dialog-footer'] button", visible: :all, text: "Cancel"
  end
end
