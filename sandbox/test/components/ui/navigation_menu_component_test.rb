# frozen_string_literal: true

require "test_helper"

class NavigationMenuComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_navigation_menu do
        ui_navigation_menu_list do
          ui_navigation_menu_item do
            ui_navigation_menu_trigger { "Produtos" } +
              ui_navigation_menu_content do
                ui_navigation_menu_link(href: "/a", active: true) { "Item A" }
              end
          end
        end
      end
    end
  end

  def test_root_wires_controller
    render_inline(Ui::NavigationMenuComponent.new) { "x" }

    assert_selector "nav[data-slot='navigation-menu'][data-controller='ui-navigation-menu']", text: "x"
  end

  def test_trigger_wires_open_actions
    render_inline(Ui::NavigationMenu::TriggerComponent.new) { "Menu" }

    assert_selector "button[data-ui-navigation-menu-target='trigger'][aria-expanded='false']", text: "Menu"
    assert_selector "button[data-action='click->ui-navigation-menu#toggle pointerenter->ui-navigation-menu#openOn'] svg"
  end

  def test_content_hidden_panel
    render_inline(Ui::NavigationMenu::ContentComponent.new) { "painel" }

    assert_selector "div[hidden][data-slot='navigation-menu-content'][data-ui-navigation-menu-target='content']", visible: :all, text: "painel"
  end

  def test_link_marks_active
    render_inline(Ui::NavigationMenu::LinkComponent.new(href: "/x", active: true)) { "Item" }

    assert_selector "a[href='/x'][aria-current='page'][data-active][data-slot='navigation-menu-link']", text: "Item"
  end

  def test_helper_composes_navigation_menu
    render_inline(HelperHarnessComponent.new)

    assert_selector "nav[data-controller='ui-navigation-menu'] ul[data-slot='navigation-menu-list'] li[data-slot='navigation-menu-item']"
    assert_selector "button[data-ui-navigation-menu-target='trigger']", text: "Produtos"
    assert_selector "[data-ui-navigation-menu-target='content'] a[aria-current='page']", visible: :all, text: "Item A"
  end
end
