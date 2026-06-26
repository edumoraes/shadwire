# frozen_string_literal: true

require "test_helper"

class CollapsibleComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_collapsible(open: true) do
        ui_collapsible_trigger(open: true) { "Detalhes" } +
          ui_collapsible_content(open: true) { "Conteúdo" }
      end
    end
  end

  def test_root_wires_controller_and_open_value
    render_inline(Ui::CollapsibleComponent.new(open: true)) { "x" }

    assert_selector "[data-controller='ui-collapsible'][data-slot='collapsible'][data-ui-collapsible-open-value='true'][data-state='open']", text: "x"
  end

  def test_trigger_toggles_via_action
    render_inline(Ui::Collapsible::TriggerComponent.new) { "Abrir" }

    assert_selector "button[type='button'][data-slot='collapsible-trigger'][data-ui-collapsible-target='trigger'][aria-expanded='false']", text: "Abrir"
    assert_selector "button[data-action='click->ui-collapsible#toggle']"
  end

  def test_content_hidden_when_closed
    render_inline(Ui::Collapsible::ContentComponent.new) { "Oculto" }

    assert_selector "div[hidden][data-slot='collapsible-content'][data-ui-collapsible-target='content'][data-state='closed']", visible: :all, text: "Oculto"
  end

  def test_helper_renders_open_collapsible
    render_inline(HelperHarnessComponent.new)

    assert_selector "[data-controller='ui-collapsible'][data-state='open']"
    assert_selector "button[aria-expanded='true'][data-state='open']", text: "Detalhes"
    assert_selector "[data-slot='collapsible-content'][data-state='open']", text: "Conteúdo"
  end
end
