# frozen_string_literal: true

require "test_helper"

class HoverCardComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_hover_card(open_delay: 200) do
        ui_hover_card_trigger(href: "#") { "@shadwire" } +
          ui_hover_card_content(side: :bottom) { "Perfil" }
      end
    end
  end

  def test_root_wires_controller_with_delays_and_actions
    render_inline(Ui::HoverCardComponent.new(open_delay: 500, close_delay: 100)) { "x" }

    assert_selector "[data-controller='ui-hover-card'][data-slot='hover-card'][data-ui-hover-card-open-delay-value='500'][data-ui-hover-card-close-delay-value='100']"
    assert_selector "[data-action='mouseenter->ui-hover-card#scheduleOpen mouseleave->ui-hover-card#scheduleClose " \
                    "focusin->ui-hover-card#scheduleOpen focusout->ui-hover-card#scheduleClose']"
  end

  def test_trigger_defaults_to_link
    render_inline(Ui::HoverCard::TriggerComponent.new(href: "/u/1")) { "perfil" }

    assert_selector "a[href='/u/1'][data-slot='hover-card-trigger'][data-ui-hover-card-target='trigger']", text: "perfil"
  end

  def test_content_hidden_with_side
    render_inline(Ui::HoverCard::ContentComponent.new(side: :right)) { "Card" }

    assert_selector "div[hidden][data-slot='hover-card-content'][data-ui-hover-card-target='content'].left-full", visible: :all, text: "Card"
  end

  def test_helper_renders_hover_card
    render_inline(HelperHarnessComponent.new)

    assert_selector "[data-controller='ui-hover-card'][data-ui-hover-card-open-delay-value='200']"
    assert_selector "a[data-ui-hover-card-target='trigger']", text: "@shadwire"
    assert_selector "[data-slot='hover-card-content'].top-full", visible: :all, text: "Perfil"
  end
end
