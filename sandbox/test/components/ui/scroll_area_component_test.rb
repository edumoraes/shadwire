# frozen_string_literal: true

require "test_helper"

class ScrollAreaComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_scroll_area(scrollbars: [ :vertical, :horizontal ], class: "h-48 w-80") do
        tag.div("Scrollable helper content", class: "w-max")
      end
    end
  end

  def test_renders_root_viewport_content_scrollbars_and_corner
    render_inline(
      Ui::ScrollAreaComponent.new(
        scrollbars: [ :vertical, :horizontal ],
        class_name: "h-[200px] w-[350px] rounded-md border",
        data: { testid: "terms" },
        aria: { label: "Terms" }
      )
    ) { "Long terms" }

    assert_selector "[data-slot='scroll-area'][data-controller='ui-scroll-area'].relative.overflow-hidden.h-\\[200px\\].w-\\[350px\\][data-testid='terms'][aria-label='Terms']"
    assert_selector "[data-slot='scroll-area-viewport'][data-ui-scroll-area-target='viewport'].shadwire-scroll-area-viewport"
    assert_selector "[data-slot='scroll-area-content'].min-w-full", text: "Long terms"
    assert_selector "[data-slot='scroll-area-scrollbar'][data-orientation='vertical'][data-ui-scroll-area-target='scrollbar'][aria-hidden='true']"
    assert_selector "[data-slot='scroll-area-scrollbar'][data-orientation='horizontal'][data-ui-scroll-area-target='scrollbar'][aria-hidden='true']"
    assert_selector "[data-slot='scroll-area-thumb'][data-ui-scroll-area-target='thumb']", count: 2
    assert_selector "[data-slot='scroll-area-corner'][data-ui-scroll-area-target='corner'][aria-hidden='true']"
  end

  def test_renders_vertical_scrollbar_by_default
    render_inline(Ui::ScrollAreaComponent.new) { "Only vertical" }

    assert_selector "[data-slot='scroll-area-scrollbar'][data-orientation='vertical']", count: 1
    assert_no_selector "[data-slot='scroll-area-scrollbar'][data-orientation='horizontal']"
  end

  def test_accepts_class_alias_and_free_html_attributes
    render_inline(
      Ui::ScrollAreaComponent.new(
        class: "max-h-64",
        id: "release-notes",
        data: { turbo: false, controller: "custom" }
      )
    ) { "Release notes" }

    assert_selector "#release-notes[data-slot='scroll-area'][data-controller='custom ui-scroll-area'].max-h-64"
    assert_selector "[data-turbo='false']"
  end

  def test_scrollbar_component_accepts_horizontal_orientation_class_and_attrs
    render_inline(
      Ui::ScrollArea::ScrollbarComponent.new(
        orientation: :horizontal,
        class_name: "bg-muted",
        data: { testid: "xbar" },
        aria: { label: "Horizontal scroll" }
      )
    )

    assert_selector "[data-slot='scroll-area-scrollbar'][data-orientation='horizontal'].w-full.bg-muted[data-testid='xbar'][aria-label='Horizontal scroll']"
    assert_selector "[data-slot='scroll-area-thumb']"
  end

  def test_helper_methods_render_scroll_area_and_scrollbar_parts
    render_inline(HelperHarnessComponent.new)

    assert_selector "[data-controller='ui-scroll-area']"
    assert_selector "[data-slot='scroll-area-content']", text: "Scrollable helper content"
    assert_selector "[data-orientation='vertical']"
    assert_selector "[data-orientation='horizontal']"
  end
end
