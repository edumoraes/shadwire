# frozen_string_literal: true

require "test_helper"

class UiAccessibilityTest < ActionDispatch::IntegrationTest
  test "landing page renders hero, navigation and live showcase" do
    get root_path

    assert_response :success
    assert_select "main"
    assert_select "h1", count: 1
    assert_select "h1", text: /código seu/

    # Header navigation links to the catalog and blocks; theme toggle is labelled.
    assert_select "nav[aria-label='Principal'] a[href='#{components_path}']", text: "Componentes"
    assert_select "nav[aria-label='Principal'] a[href='#{blocks_path}']", text: "Blocks"
    assert_select "button[aria-label='Alternar tema']"

    # The showcase renders a live, tabbed component preview.
    assert_select "[data-controller='ui-tabs']"
    assert_select "[role='tablist'] button[role='tab']"

    # The landing stays free of overlay controllers (no hidden dialogs/menus).
    assert_select "dialog", count: 0
    assert_select "[data-controller='ui-dialog']", count: 0
    assert_select "[data-controller='ui-popover']", count: 0
    assert_select "[data-controller='ui-dropdown-menu']", count: 0
    assert_select "[data-controller='ui-select']", count: 0
  end

  test "components catalog lists the documented components" do
    get components_path

    assert_response :success
    assert_select "main"
    assert_select "h1", text: "Componentes"
    assert_select "nav[aria-label='Componentes']"

    assert_select "nav[aria-label='Componentes'] a[href='#{components_button_path}']", text: /Button/
    assert_select "nav[aria-label='Componentes'] a[href='#{components_dialog_path}']", text: /Dialog/
    assert_select "nav[aria-label='Componentes'] a[href='#{components_sidebar_path}']", text: /Sidebar/
  end
end
