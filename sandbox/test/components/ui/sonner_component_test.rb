# frozen_string_literal: true

require "test_helper"

class SonnerComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include Ui::ButtonHelper
    include Ui::SonnerHelper

    def call
      ui_sonner(position: :"top-center") do
        ui_button(
          data: {
            action: "click->ui-sonner#toast",
            "ui-sonner-title-param": "Salvo",
            "ui-sonner-variant-param": "success"
          }
        ) { "Notificar" }
      end
    end
  end

  def test_root_is_a_sonner_controller
    render_inline(Ui::SonnerComponent.new)

    assert_selector "section[data-slot='sonner'][data-controller='ui-sonner'][data-ui-sonner-duration-value='4000']"
  end

  def test_list_is_a_polite_live_region
    render_inline(Ui::SonnerComponent.new)

    assert_selector "ol[data-ui-sonner-target='list'][role='region'][aria-live='polite'][aria-label='Notifications']"
  end

  def test_position_sets_placement_classes
    render_inline(Ui::SonnerComponent.new(position: :"top-left"))

    assert_selector "ol[data-ui-sonner-target='list'].top-0.left-0"
  end

  # Every other placement argument in the registry is an underscored symbol
  # (`align: :center`, `side: :inline_end`); `:top_left` used to fall back to
  # the default corner without a word.
  def test_position_reads_underscored_like_every_other_symbol
    render_inline(Ui::SonnerComponent.new(position: :top_left))
    assert_selector "ol[data-ui-sonner-target='list'].top-0.left-0"

    render_inline(Ui::SonnerComponent.new(position: :bottom_center))
    assert_selector "ol[data-ui-sonner-target='list'].bottom-0.left-1\\/2"
  end

  def test_block_content_renders_inside_the_region
    render_inline(Ui::SonnerComponent.new) { "trigger" }

    assert_selector "section[data-slot='sonner']", text: "trigger"
  end

  def test_helper_composes_a_toaster_with_a_trigger
    render_inline(HelperHarnessComponent.new)

    assert_selector "section[data-controller='ui-sonner'] ol[data-ui-sonner-target='list']"
    assert_selector "button[data-action='click->ui-sonner#toast'][data-ui-sonner-title-param='Salvo'][data-ui-sonner-variant-param='success']", text: "Notificar"
  end
end
