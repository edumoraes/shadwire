# frozen_string_literal: true

require "test_helper"

class BlocksControllerTest < ActionDispatch::IntegrationTest
  test "blocks index lists blocks with iframe previews" do
    get blocks_path

    assert_response :success
    assert_select "h1", text: "Blocks"
    assert_select "a[href='#{blocks_sidebar_01_path}']"
    assert_select "iframe[src='#{blocks_sidebar_01_path}']"
  end

  test "sidebar-01 block renders standalone with its parts" do
    get blocks_sidebar_01_path

    assert_response :success
    assert_select "[data-slot='sidebar-wrapper'][data-controller='ui-sidebar']"
    assert_select "main[data-slot='sidebar-inset']"
    assert_select "nav[aria-label='breadcrumb'] [data-slot='breadcrumb-page']", text: "Data Fetching"
    assert_select "[data-controller='ui-dropdown-menu'] button[aria-haspopup='menu']"
    assert_select "form[role='search'] input[placeholder='Search the docs...']"
    assert_select "a[data-slot='sidebar-menu-button'][data-active='true']", text: "Data Fetching"
  end

  test "blocks index is linked from the landing page" do
    get root_path

    assert_response :success
    assert_select "nav[aria-label='Principal'] a[href='#{blocks_path}']", text: "Blocks"
  end
end
