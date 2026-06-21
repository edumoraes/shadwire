# frozen_string_literal: true

require "test_helper"

class SidebarMenuButtonComponentTest < ViewComponent::TestCase
  def test_renders_default_button
    render_inline(Ui::Sidebar::MenuButtonComponent.new) { "Início" }

    assert_selector "button[type='button'][data-slot='sidebar-menu-button'][data-size='default']", text: "Início"
  end

  def test_renders_active_link
    render_inline(Ui::Sidebar::MenuButtonComponent.new(tag: :a, href: "/posts", is_active: true)) { "Posts" }

    assert_selector "a[href='/posts'][data-slot='sidebar-menu-button'][data-active='true']", text: "Posts"
  end

  def test_size_variant
    render_inline(Ui::Sidebar::MenuButtonComponent.new(size: :lg)) { "x" }

    assert_selector "button[data-size='lg'].h-12"
  end

  def test_tooltip_wraps_button_with_controller
    render_inline(Ui::Sidebar::MenuButtonComponent.new(tooltip: "Início")) { "Início" }

    assert_selector "[data-controller='ui-tooltip'] button[data-ui-tooltip-target='trigger']", text: "Início"
    assert_selector "[data-slot='sidebar-menu-button-tooltip-content'][role='tooltip'][data-ui-tooltip-target='content']",
                    text: "Início", visible: :all
  end

  def test_menu_sub_button_renders_anchor
    render_inline(Ui::Sidebar::MenuSubButtonComponent.new(href: "#", is_active: true)) { "Sub" }

    assert_selector "a[data-slot='sidebar-menu-sub-button'][data-active='true']", text: "Sub"
  end
end
