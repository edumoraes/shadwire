# frozen_string_literal: true

require "test_helper"

class TooltipComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_tooltip(id: "save-tooltip", open_delay: 150) do
        ui_tooltip_trigger(variant: :outline) { "Passe o mouse" } +
          ui_tooltip_content(side: :bottom) { "Salvar alterações" }
      end
    end
  end

  def test_root_renders_controller_with_open_delay_and_hover_actions
    render_inline(Ui::TooltipComponent.new(open_delay: 500)) { "x" }

    assert_selector "[data-controller='ui-tooltip'][data-slot='tooltip'][data-ui-tooltip-open-delay-value='500'].relative"
    assert_selector "[data-action='mouseenter->ui-tooltip#scheduleShow mouseleave->ui-tooltip#hide " \
                    "focusin->ui-tooltip#show focusout->ui-tooltip#hide keydown.esc->ui-tooltip#hide']"
  end

  def test_trigger_renders_button_target
    render_inline(Ui::Tooltip::TriggerComponent.new) { "Ajuda" }

    assert_selector "button[type='button'][data-slot='tooltip-trigger'][data-ui-tooltip-target='trigger']", text: "Ajuda"
  end

  def test_content_renders_hidden_tooltip_role_with_side
    render_inline(Ui::Tooltip::ContentComponent.new(side: :right)) { "Dica" }

    assert_selector "div[role='tooltip'][hidden][data-slot='tooltip-content'][data-ui-tooltip-target='content'].left-full",
                    visible: :all, text: "Dica"
    assert_selector "div.bg-primary.text-primary-foreground", visible: :all
  end

  def test_content_defaults_to_top_side
    render_inline(Ui::Tooltip::ContentComponent.new) { "Dica" }

    assert_selector "div[role='tooltip'].bottom-full", visible: :all
  end

  def test_helper_methods_render_tooltip
    render_inline(HelperHarnessComponent.new)

    assert_selector "#save-tooltip[data-controller='ui-tooltip'][data-ui-tooltip-open-delay-value='150']"
    assert_selector "button[data-ui-tooltip-target='trigger']", text: "Passe o mouse"
    assert_selector "[role='tooltip'][data-ui-tooltip-target='content'].top-full", visible: :all, text: "Salvar alterações"
  end
end
