# frozen_string_literal: true

require "test_helper"

class CarouselComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_carousel(class: "w-64") do
        ui_carousel_content do
          ui_carousel_item { "1" } + ui_carousel_item { "2" } + ui_carousel_item { "3" }
        end +
          ui_carousel_previous +
          ui_carousel_next
      end
    end
  end

  def test_root_is_a_carousel_region
    render_inline(Ui::CarouselComponent.new) { "x" }

    assert_selector "div[role='region'][aria-roledescription='carousel'][data-slot='carousel'][data-controller='ui-carousel'][data-action='keydown->ui-carousel#keydown']", text: "x"
  end

  def test_content_wraps_track
    render_inline(Ui::Carousel::ContentComponent.new) { "slides" }

    assert_selector "div[data-slot='carousel-content'] > div[data-slot='carousel-track'][data-ui-carousel-target='track'].flex", text: "slides"
  end

  def test_item_is_a_slide
    render_inline(Ui::Carousel::ItemComponent.new) { "slide" }

    assert_selector "div[role='group'][aria-roledescription='slide'][data-ui-carousel-target='slide'].basis-full", text: "slide"
  end

  def test_controls_wire_actions
    render_inline(Ui::Carousel::PreviousComponent.new)
    assert_selector "button[data-ui-carousel-target='previous'][data-action='click->ui-carousel#previous'] span.sr-only", text: "Slide anterior"
  end

  def test_helper_composes_carousel
    render_inline(HelperHarnessComponent.new)

    assert_selector "[data-controller='ui-carousel'] [data-ui-carousel-target='slide']", count: 3
    assert_selector "button[data-ui-carousel-target='previous']"
    assert_selector "button[data-ui-carousel-target='next']"
  end
end
