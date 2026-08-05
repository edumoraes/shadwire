# frozen_string_literal: true

require "application_system_test_case"

class TabsComponentTest < ApplicationSystemTestCase
  test "tabs switch on click and arrow keys with aria wiring" do
    visit components_tabs_path

    within "#example-tabs_default" do
      active_tab = find("[role='tab'][aria-selected='true']", text: "Account")

      assert_equal "0", active_tab["tabindex"]
      assert active_tab["aria-controls"].present?
      assert_selector "[role='tab'][aria-selected='false']", text: "Password"
      assert_selector "[role='tabpanel'][data-state='active']", text: /profile/
      assert_no_selector "[role='tabpanel']", text: /sign-in password/

      find("[role='tab']", text: "Password").click

      assert_selector "[role='tab'][aria-selected='true']", text: "Password"
      assert_selector "[role='tabpanel'][data-state='active']", text: /sign-in password/

      find("[role='tab']", text: "Password").send_keys :arrow_left

      assert_selector "[role='tab'][aria-selected='true']", text: "Account"
      assert_selector "[role='tabpanel'][data-state='active']", text: /profile/

      find("[role='tab']", text: "Account").send_keys :end

      assert_selector "[role='tab'][aria-selected='true']", text: "Password"
    end
  end

  test "disabled triggers are skipped by keyboard navigation" do
    visit components_tabs_path

    within "#example-tabs_disabled" do
      assert_selector "[role='tab'][aria-selected='true']", text: "Overview"

      find("[role='tab']", text: "Overview").send_keys :arrow_right

      assert_selector "[role='tab'][aria-selected='true']", text: "Overview"
      assert_selector "[role='tab'][disabled]", text: "Analytics"
    end
  end
end
