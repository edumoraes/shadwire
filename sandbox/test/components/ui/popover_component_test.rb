# frozen_string_literal: true

require "test_helper"

class PopoverComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_popover(id: "dims-popover") do
        ui_popover_trigger(variant: :outline) { "Abrir" } +
          ui_popover_content(side: :bottom, align: :start) { "Conteúdo do popover" }
      end
    end
  end

  def test_root_renders_controller_with_outside_and_escape_listeners
    render_inline(Ui::PopoverComponent.new) { "x" }

    assert_selector "[data-controller='ui-popover'][data-slot='popover'].relative"
    assert_selector "[data-action='click@window->ui-popover#outsideClick keydown.esc@window->ui-popover#closeOnEscape']"
  end

  def test_trigger_renders_button_with_toggle_and_expanded_state
    render_inline(Ui::Popover::TriggerComponent.new) { "Abrir" }

    assert_selector "button[type='button'][aria-haspopup='dialog'][aria-expanded='false']" \
                    "[data-slot='popover-trigger'][data-ui-popover-target='trigger']" \
                    "[data-action='click->ui-popover#toggle']", text: "Abrir"
  end

  def test_content_renders_hidden_focusable_panel_with_side_and_align
    render_inline(Ui::Popover::ContentComponent.new(side: :top, align: :end)) { "Dica" }

    assert_selector "div[hidden][tabindex='-1'][data-slot='popover-content'][data-ui-popover-target='content']" \
                    ".bottom-full.right-0.bg-popover", visible: :all, text: "Dica"
  end

  def test_content_defaults_to_bottom_center
    render_inline(Ui::Popover::ContentComponent.new) { "Dica" }

    assert_selector "div[role='dialog'].top-full.left-1\\/2", visible: :all
  end

  def test_helper_methods_render_popover
    render_inline(HelperHarnessComponent.new)

    assert_selector "#dims-popover[data-controller='ui-popover']"
    assert_selector "button[data-ui-popover-target='trigger'][aria-expanded='false']", text: "Abrir"
    assert_selector "[data-ui-popover-target='content'].top-full.left-0", visible: :all, text: "Conteúdo do popover"
  end
end
