# frozen_string_literal: true

require "test_helper"

class DrawerComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_drawer do
        ui_drawer_trigger { "Abrir" } +
          ui_drawer_content do
            ui_drawer_header do
              ui_drawer_title { "Título" } + ui_drawer_description { "Descrição" }
            end +
              ui_drawer_footer { ui_drawer_close { "Fechar" } }
          end
      end
    end
  end

  def test_root_wires_drawer_controller
    render_inline(Ui::DrawerComponent.new(close_on_backdrop: false)) { "x" }

    assert_selector "[data-controller='ui-drawer'][data-slot='drawer'][data-ui-drawer-close-on-backdrop-value='false']", text: "x"
  end

  def test_trigger_opens_drawer
    render_inline(Ui::Drawer::TriggerComponent.new) { "Abrir" }

    assert_selector "button[aria-haspopup='dialog'][data-slot='drawer-trigger'][data-action='click->ui-drawer#open']", text: "Abrir"
  end

  def test_content_is_native_dialog_with_handle
    render_inline(Ui::Drawer::ContentComponent.new(side: :bottom)) { "Corpo" }

    assert_selector "dialog[data-slot='drawer-content'][data-side='bottom'][data-ui-drawer-target='dialog']", visible: :all, text: "Corpo"
    assert_selector "dialog[data-action='click->ui-drawer#backdropClick cancel->ui-drawer#cancel close->ui-drawer#closed']", visible: :all
    assert_selector "dialog [data-slot='drawer-handle'][data-action='pointerdown->ui-drawer#dragStart']", visible: :all
  end

  def test_helper_composes_drawer
    render_inline(HelperHarnessComponent.new)

    assert_selector "[data-controller='ui-drawer'] button[data-slot='drawer-trigger']", text: "Abrir"
    assert_selector "dialog h2[data-slot='drawer-title']", visible: :all, text: "Título"
    assert_selector "dialog [data-slot='drawer-footer'] button[data-slot='drawer-close']", visible: :all, text: "Fechar"
  end
end
