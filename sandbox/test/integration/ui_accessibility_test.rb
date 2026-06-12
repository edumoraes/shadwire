# frozen_string_literal: true

require "test_helper"

class UiAccessibilityTest < ActionDispatch::IntegrationTest
  test "showcase renders component documentation listing" do
    get root_path

    assert_response :success
    assert_select "main"
    assert_select "h1", text: "Shadwire"
    assert_select "nav[aria-label='Component documentation']"
    assert_select "button[aria-label='Alternar tema']"

    assert_select "nav[aria-label='Component documentation'] a[href='#{components_button_path}']", text: /Button/
    assert_select "nav[aria-label='Component documentation'] a[href='#{components_dialog_path}']", text: /Dialog/
    assert_select "nav[aria-label='Component documentation'] a[href='#{components_sheet_path}']", text: /Sheet/

    assert_select "dialog", count: 0
    assert_select "[data-controller='ui-dialog']", count: 0
    assert_select "[data-controller='ui-popover']", count: 0
    assert_select "[data-controller='ui-dropdown-menu']", count: 0
    assert_select "[data-controller='ui-select']", count: 0
  end
end
