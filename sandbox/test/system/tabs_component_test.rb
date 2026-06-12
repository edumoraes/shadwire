# frozen_string_literal: true

require "application_system_test_case"

class TabsComponentTest < ApplicationSystemTestCase
  test "tabs switch on click and arrow keys with aria wiring" do
    visit components_tabs_path

    within "#example-tabs_default" do
      active_tab = find("[role='tab'][aria-selected='true']", text: "Conta")

      assert_equal "0", active_tab["tabindex"]
      assert active_tab["aria-controls"].present?
      assert_selector "[role='tab'][aria-selected='false']", text: "Senha"
      assert_selector "[role='tabpanel'][data-state='active']", text: /perfil/
      assert_no_selector "[role='tabpanel']", text: /senha de acesso/

      find("[role='tab']", text: "Senha").click

      assert_selector "[role='tab'][aria-selected='true']", text: "Senha"
      assert_selector "[role='tabpanel'][data-state='active']", text: /senha de acesso/

      find("[role='tab']", text: "Senha").send_keys :arrow_left

      assert_selector "[role='tab'][aria-selected='true']", text: "Conta"
      assert_selector "[role='tabpanel'][data-state='active']", text: /perfil/

      find("[role='tab']", text: "Conta").send_keys :end

      assert_selector "[role='tab'][aria-selected='true']", text: "Senha"
    end
  end

  test "disabled triggers are skipped by keyboard navigation" do
    visit components_tabs_path

    within "#example-tabs_disabled" do
      assert_selector "[role='tab'][aria-selected='true']", text: "Visão geral"

      find("[role='tab']", text: "Visão geral").send_keys :arrow_right

      assert_selector "[role='tab'][aria-selected='true']", text: "Visão geral"
      assert_selector "[role='tab'][disabled]", text: "Analytics"
    end
  end
end
