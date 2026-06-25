# frozen_string_literal: true

require "test_helper"

class ContextMenuComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_context_menu do
        ui_context_menu_trigger(class: "h-24") { "Clique com o botão direito" } +
          ui_context_menu_content do
            ui_context_menu_label { "Ações" } +
              ui_context_menu_item { "Voltar" } +
              ui_context_menu_separator +
              ui_context_menu_item(variant: :destructive) { "Excluir" }
          end
      end
    end
  end

  def test_root_wires_controller
    render_inline(Ui::ContextMenuComponent.new) { "x" }

    assert_selector "[data-controller='ui-context-menu'][data-slot='context-menu'][data-action='click@window->ui-context-menu#outsideClick']", text: "x"
  end

  def test_trigger_opens_on_contextmenu
    render_inline(Ui::ContextMenu::TriggerComponent.new) { "alvo" }

    assert_selector "[data-slot='context-menu-trigger'][data-action='contextmenu->ui-context-menu#open']", text: "alvo"
  end

  def test_content_is_hidden_menu
    render_inline(Ui::ContextMenu::ContentComponent.new) { "itens" }

    assert_selector "div[role='menu'][hidden][data-slot='context-menu-content'][data-ui-context-menu-target='content']", visible: :all, text: "itens"
  end

  def test_item_wires_select
    render_inline(Ui::ContextMenu::ItemComponent.new(variant: :destructive)) { "Excluir" }

    assert_selector "button[role='menuitem'][data-variant='destructive'][data-ui-context-menu-target='item'][data-action='click->ui-context-menu#select']", text: "Excluir"
  end

  def test_helper_composes_menu
    render_inline(HelperHarnessComponent.new)

    assert_selector "[data-controller='ui-context-menu'] [role='menu']", visible: :all
    assert_selector "[data-slot='context-menu-label']", visible: :all, text: "Ações"
    assert_selector "[role='menuitem']", visible: :all, count: 2
    assert_selector "[data-slot='context-menu-separator']", visible: :all
  end
end
