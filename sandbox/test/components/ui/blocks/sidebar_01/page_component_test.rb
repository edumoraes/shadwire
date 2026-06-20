# frozen_string_literal: true

require "test_helper"

class Sidebar01PageComponentTest < ViewComponent::TestCase
  def test_renders_provider_sidebar_and_inset
    render_inline(Ui::Blocks::Sidebar01::PageComponent.new)

    assert_selector "[data-slot='sidebar-wrapper'][data-controller='ui-sidebar']"
    assert_selector "[data-slot='sidebar'][data-side='left']"
    assert_selector "main[data-slot='sidebar-inset']"
    assert_selector "button[data-slot='sidebar-trigger']"
  end

  def test_renders_header_breadcrumb
    render_inline(Ui::Blocks::Sidebar01::PageComponent.new)

    assert_selector "nav[aria-label='breadcrumb']"
    assert_selector "[data-slot='breadcrumb-page']", text: "Data Fetching"
  end

  def test_renders_version_switcher_and_search
    render_inline(Ui::Blocks::Sidebar01::PageComponent.new)

    assert_selector "[data-controller='ui-dropdown-menu'] button[data-slot='sidebar-menu-button'][aria-haspopup='menu']"
    assert_selector "[data-slot='sidebar-menu-button']", text: /Documentation/
    assert_selector "form[role='search'] input[placeholder='Search the docs...']"
  end

  def test_renders_nav_groups_with_active_item
    render_inline(Ui::Blocks::Sidebar01::PageComponent.new)

    assert_selector "[data-slot='sidebar-group-label']", text: "Getting Started"
    assert_selector "[data-slot='sidebar-group-label']", text: "Building Your Application"
    assert_selector "a[data-slot='sidebar-menu-button'][data-active='true']", text: "Data Fetching"
  end
end
