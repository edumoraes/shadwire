# frozen_string_literal: true

require "test_helper"

class DropdownMenuComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_dropdown_menu(id: "account-menu") do
        ui_dropdown_menu_trigger(variant: :outline) { "Abrir menu" } +
          ui_dropdown_menu_content do
            ui_dropdown_menu_label { "Minha conta" } +
              ui_dropdown_menu_separator +
              ui_dropdown_menu_group do
                ui_dropdown_menu_item do
                  safe_join([ "Perfil", ui_dropdown_menu_shortcut { "⇧⌘P" } ])
                end +
                  ui_dropdown_menu_item(tag: :a, href: "/settings") { "Configurações" }
              end +
              ui_dropdown_menu_item(variant: :destructive) { "Sair" }
          end
      end
    end
  end

  def test_root_renders_controller_with_outside_listener
    render_inline(Ui::DropdownMenuComponent.new) { "x" }

    assert_selector "[data-controller='ui-dropdown-menu'][data-slot='dropdown-menu'].relative"
    assert_selector "[data-action='click@window->ui-dropdown-menu#outsideClick']"
  end

  def test_trigger_renders_button_with_menu_semantics
    render_inline(Ui::DropdownMenu::TriggerComponent.new) { "Abrir" }

    assert_selector "button[type='button'][aria-haspopup='menu'][aria-expanded='false']" \
                    "[data-slot='dropdown-menu-trigger'][data-ui-dropdown-menu-target='trigger']" \
                    "[data-action='click->ui-dropdown-menu#toggle keydown->ui-dropdown-menu#triggerKeydown']", text: "Abrir"
  end

  def test_content_renders_hidden_menu
    render_inline(Ui::DropdownMenu::ContentComponent.new) { "itens" }

    assert_selector "div[role='menu'][hidden][tabindex='-1'][data-slot='dropdown-menu-content']" \
                    "[data-ui-dropdown-menu-target='content'][data-action='keydown->ui-dropdown-menu#keydown']" \
                    ".min-w-\\[8rem\\]", visible: :all, text: "itens"
  end

  def test_item_default_variant
    render_inline(Ui::DropdownMenu::ItemComponent.new) { "Perfil" }

    assert_selector "button[type='button'][role='menuitem'][tabindex='-1']" \
                    "[data-slot='dropdown-menu-item'][data-ui-dropdown-menu-target='item']" \
                    "[data-action='click->ui-dropdown-menu#select']", text: "Perfil"
  end

  def test_item_inset_destructive_and_disabled_states
    render_inline(Ui::DropdownMenu::ItemComponent.new(inset: true, variant: :destructive, disabled: true)) { "Excluir" }

    assert_selector "button[role='menuitem'][data-inset][data-variant='destructive'][data-disabled][aria-disabled='true']",
                    text: "Excluir"
  end

  def test_item_renders_as_link
    render_inline(Ui::DropdownMenu::ItemComponent.new(tag: :a, href: "/settings")) { "Config" }

    assert_selector "a[href='/settings'][role='menuitem'][data-slot='dropdown-menu-item']", text: "Config"
    assert_no_selector "a[type]"
  end

  def test_label_separator_group_and_shortcut
    render_inline(Ui::DropdownMenu::LabelComponent.new(inset: true)) { "Conta" }
    assert_selector "div[data-slot='dropdown-menu-label'][data-inset]", text: "Conta"

    render_inline(Ui::DropdownMenu::SeparatorComponent.new)
    assert_selector "div[role='separator'][data-slot='dropdown-menu-separator']"

    render_inline(Ui::DropdownMenu::GroupComponent.new) { "g" }
    assert_selector "div[role='group'][data-slot='dropdown-menu-group']", text: "g"

    render_inline(Ui::DropdownMenu::ShortcutComponent.new) { "⌘K" }
    assert_selector "span[data-slot='dropdown-menu-shortcut'].ml-auto", text: "⌘K"
  end

  def test_helper_methods_render_dropdown_menu
    render_inline(HelperHarnessComponent.new)

    assert_selector "#account-menu[data-controller='ui-dropdown-menu']"
    assert_selector "button[data-ui-dropdown-menu-target='trigger']", text: "Abrir menu"
    assert_selector "[role='menu'] [data-slot='dropdown-menu-label']", visible: :all, text: "Minha conta"
    assert_selector "[role='menu'] [role='group'] button[role='menuitem']", visible: :all, text: /Perfil/
    assert_selector "[role='menu'] a[role='menuitem'][href='/settings']", visible: :all, text: "Configurações"
    assert_selector "[role='menu'] button[role='menuitem'][data-variant='destructive']", visible: :all, text: "Sair"
  end
end
