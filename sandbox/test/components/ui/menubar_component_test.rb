# frozen_string_literal: true

require "test_helper"

class MenubarComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_menubar do
        ui_menubar_menu do
          ui_menubar_trigger { "Arquivo" } +
            ui_menubar_content do
              ui_menubar_item { "Novo" } + ui_menubar_item { "Abrir" }
            end
        end
      end
    end
  end

  def test_root_is_menubar
    render_inline(Ui::MenubarComponent.new) { "x" }

    assert_selector "div[role='menubar'][data-slot='menubar'][data-controller='ui-menubar'][data-action='click@window->ui-menubar#outsideClick']", text: "x"
  end

  def test_trigger_wires_menubar_actions
    render_inline(Ui::Menubar::TriggerComponent.new) { "Arquivo" }

    assert_selector "button[role='menuitem'][aria-haspopup='menu'][data-ui-menubar-target='trigger']", text: "Arquivo"
    assert_selector "button[data-action='click->ui-menubar#toggle pointerenter->ui-menubar#triggerEnter keydown->ui-menubar#triggerKeydown']"
  end

  def test_content_is_hidden_menu_with_keydown
    render_inline(Ui::Menubar::ContentComponent.new) { "itens" }

    assert_selector "div[role='menu'][hidden][data-ui-menubar-target='content'][data-action='keydown->ui-menubar#contentKeydown']", visible: :all, text: "itens"
  end

  def test_helper_composes_menubar
    render_inline(HelperHarnessComponent.new)

    assert_selector "[role='menubar'] [data-slot='menubar-menu'] button[data-ui-menubar-target='trigger']", text: "Arquivo"
    assert_selector "[data-ui-menubar-target='content'] [data-slot='menubar-item']", visible: :all, count: 2
  end
end
