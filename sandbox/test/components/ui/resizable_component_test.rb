# frozen_string_literal: true

require "test_helper"

class ResizableComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_resizable_panel_group(direction: :horizontal, class: "h-40 rounded-lg border") do
        ui_resizable_panel(default_size: 60) { "Esquerda" } +
          ui_resizable_handle(with_handle: true) +
          ui_resizable_panel(default_size: 40) { "Direita" }
      end
    end
  end

  def test_group_wires_controller_and_direction
    render_inline(Ui::ResizablePanelGroupComponent.new(direction: :vertical)) { "x" }

    assert_selector "[data-controller='ui-resizable'][data-slot='resizable-panel-group'][data-direction='vertical'][data-ui-resizable-direction-value='vertical']", text: "x"
  end

  def test_panel_records_default_size
    render_inline(Ui::ResizablePanelComponent.new(default_size: 30)) { "Painel" }

    assert_selector "[data-slot='resizable-panel'][data-ui-resizable-target='panel'][data-default-size='30']", text: "Painel"
  end

  def test_handle_is_focusable_separator
    render_inline(Ui::ResizableHandleComponent.new(with_handle: true))

    assert_selector "[role='separator'][tabindex='0'][data-ui-resizable-target='handle'][data-action='pointerdown->ui-resizable#start keydown->ui-resizable#keydown'] svg"
  end

  def test_helper_composes_panels
    render_inline(HelperHarnessComponent.new)

    assert_selector "[data-controller='ui-resizable'] [data-slot='resizable-panel']", count: 2
    assert_selector "[data-slot='resizable-handle']", count: 1
  end
end
