# frozen_string_literal: true

require "test_helper"

class SidebarComponentTest < ViewComponent::TestCase
  def test_renders_collapsible_panel_with_data_attributes
    render_inline(Ui::SidebarComponent.new) { "nav" }

    assert_selector "[data-slot='sidebar'][data-state='expanded'][data-side='left'][data-variant='sidebar'][data-mobile='closed']"
    assert_selector "[data-slot='sidebar'][data-collapsible=''][data-collapsible-mode='offcanvas']"
    assert_selector "[data-ui-sidebar-target='sidebar']"
    assert_selector "[data-slot='sidebar-inner']", text: "nav"
    assert_selector "[data-slot='sidebar-gap']", visible: :all
    assert_selector "[data-slot='sidebar-backdrop'][data-action='click->ui-sidebar#closeMobile']", visible: :all
  end

  def test_side_right_and_floating_variant
    render_inline(Ui::SidebarComponent.new(side: :right, variant: :floating))

    assert_selector "[data-slot='sidebar'][data-side='right'][data-variant='floating']"
  end

  def test_collapsible_none_renders_simple_panel
    render_inline(Ui::SidebarComponent.new(collapsible: :none)) { "content" }

    assert_selector "[data-slot='sidebar'].bg-sidebar.flex", text: "content"
    assert_no_selector "[data-slot='sidebar-backdrop']", visible: :all
  end

  def test_provider_hosts_controller_with_values_and_widths
    render_inline(Ui::Sidebar::ProviderComponent.new) { "x" }

    wrapper = page.find("[data-slot='sidebar-wrapper']", visible: :all)
    assert_equal "ui-sidebar", wrapper["data-controller"]
    assert_equal "true", wrapper["data-ui-sidebar-open-value"]
    assert_equal "sidebar_state", wrapper["data-ui-sidebar-cookie-name-value"]
    assert_includes wrapper["style"], "--sidebar-width"
  end

  def test_provider_default_open_false
    render_inline(Ui::Sidebar::ProviderComponent.new(default_open: false))

    assert_selector "[data-ui-sidebar-open-value='false']"
  end

  def test_trigger_toggles_sidebar
    render_inline(Ui::Sidebar::TriggerComponent.new)

    assert_selector "button[data-slot='sidebar-trigger'][data-action='click->ui-sidebar#toggle']"
    assert_selector "button .sr-only", text: "Toggle Sidebar", visible: :all
    assert_selector "button svg", visible: :all
  end

  def test_rail_toggles_sidebar
    render_inline(Ui::Sidebar::RailComponent.new)

    assert_selector "button[data-slot='sidebar-rail'][aria-label='Toggle Sidebar'][data-action='click->ui-sidebar#toggle']"
  end

  def test_inset_is_a_main_element
    render_inline(Ui::Sidebar::InsetComponent.new) { "page" }

    assert_selector "main[data-slot='sidebar-inset']", text: "page"
  end

  def test_structural_parts
    render_inline(Ui::Sidebar::ContentComponent.new) { "x" }
    assert_selector "[data-slot='sidebar-content']", text: "x"

    render_inline(Ui::Sidebar::GroupComponent.new) { "x" }
    assert_selector "[data-slot='sidebar-group']", text: "x"

    render_inline(Ui::Sidebar::GroupLabelComponent.new) { "App" }
    assert_selector "[data-slot='sidebar-group-label']", text: "App"

    render_inline(Ui::Sidebar::MenuComponent.new) { "x" }
    assert_selector "ul[data-slot='sidebar-menu']"

    render_inline(Ui::Sidebar::MenuItemComponent.new) { "x" }
    assert_selector "li[data-slot='sidebar-menu-item']"
  end

  def test_input_renders_an_input
    render_inline(Ui::Sidebar::InputComponent.new(placeholder: "Search"))

    assert_selector "input.h-8[placeholder='Search']"
  end

  def test_separator_is_decorative_to_the_sidebar
    render_inline(Ui::Sidebar::SeparatorComponent.new)

    assert_selector "[data-slot='sidebar-separator']", visible: :all
  end

  def test_menu_skeleton_with_icon
    render_inline(Ui::Sidebar::MenuSkeletonComponent.new(show_icon: true))

    assert_selector "[data-slot='sidebar-menu-skeleton']", visible: :all
    assert_selector "[data-slot='sidebar-menu-skeleton'] [data-slot='skeleton']", count: 2, visible: :all
  end
end
