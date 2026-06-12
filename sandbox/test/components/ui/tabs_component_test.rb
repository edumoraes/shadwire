# frozen_string_literal: true

require "test_helper"

class TabsComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_tabs(default_value: :account, id: "settings-tabs") do
        ui_tabs_list do
          ui_tabs_trigger(value: :account) { "Conta" } +
            ui_tabs_trigger(value: :password) { "Senha" }
        end +
          ui_tabs_content(value: :account) { "Painel da conta" } +
          ui_tabs_content(value: :password) { "Painel de senha" }
      end
    end
  end

  def test_renders_root_with_stimulus_controller_and_default_value
    render_inline(Ui::TabsComponent.new(default_value: :account)) { "conteúdo" }

    assert_selector "[data-controller='ui-tabs'][data-ui-tabs-default-value-value='account'][data-slot='tabs']", text: "conteúdo"
  end

  def test_root_appends_to_existing_controllers
    render_inline(Ui::TabsComponent.new(data: { controller: "analytics" })) { "x" }

    assert_selector "[data-controller='analytics ui-tabs']"
  end

  def test_list_renders_tablist_role
    render_inline(Ui::Tabs::ListComponent.new) { "triggers" }

    assert_selector "[role='tablist'][data-slot='tabs-list'].bg-muted", text: "triggers"
  end

  def test_trigger_renders_tab_role_value_and_actions
    render_inline(Ui::Tabs::TriggerComponent.new(value: :account)) { "Conta" }

    assert_selector "button[type='button'][role='tab'][data-ui-tabs-value='account'][data-slot='tabs-trigger']", text: "Conta"
    assert_selector "button[data-ui-tabs-target='trigger']"
    assert_selector "button[data-action='click->ui-tabs#select keydown->ui-tabs#navigate']"
  end

  def test_trigger_disabled_state
    render_inline(Ui::Tabs::TriggerComponent.new(value: :beta, disabled: true)) { "Beta" }

    assert_selector "button[disabled][data-disabled][aria-disabled='true']"
  end

  def test_content_renders_hidden_tabpanel
    render_inline(Ui::Tabs::ContentComponent.new(value: :account)) { "Painel" }

    assert_selector "div[role='tabpanel'][tabindex='0'][data-ui-tabs-target='panel'][data-ui-tabs-value='account'][hidden]",
                    visible: :all, text: "Painel"
  end

  def test_helper_methods_render_tabs
    render_inline(HelperHarnessComponent.new)

    assert_selector "#settings-tabs[data-controller='ui-tabs']"
    assert_selector "[role='tablist'] button[role='tab']", count: 2
    assert_selector "[role='tabpanel'][data-ui-tabs-value='password']", visible: :all
  end
end
