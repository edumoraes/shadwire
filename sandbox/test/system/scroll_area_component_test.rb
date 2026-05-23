# frozen_string_literal: true

require "application_system_test_case"

class ScrollAreaComponentTest < ApplicationSystemTestCase
  test "custom scrollbars reflect overflow and control the viewport" do
    visit components_scroll_area_path

    horizontal_area = find("[data-testid='scroll-area-horizontal']")
    horizontal_viewport = horizontal_area.find("[data-slot='scroll-area-viewport']")
    horizontal_track = horizontal_area.find("[data-orientation='horizontal']", visible: :all)

    assert_equal "true", horizontal_area["data-has-overflow-x"]
    assert_equal "false", horizontal_area["data-has-overflow-y"]
    assert_no_selector "[data-testid='scroll-area-horizontal'] [data-orientation='vertical']", visible: :all
    assert horizontal_track.evaluate_script("this.getBoundingClientRect().width") >=
           horizontal_viewport.evaluate_script("this.getBoundingClientRect().width - 2")

    horizontal_viewport.execute_script("this.scrollLeft = 40; this.dispatchEvent(new Event('scroll'))")
    before_click = horizontal_viewport.evaluate_script("this.scrollLeft")
    horizontal_track.execute_script(<<~JS)
      const rect = this.getBoundingClientRect()
      this.dispatchEvent(new MouseEvent("click", { bubbles: true, clientX: rect.right - 2, clientY: rect.top + rect.height / 2 }))
    JS

    assert horizontal_viewport.evaluate_script("this.scrollLeft") > before_click

    vertical_area = find("[data-testid='scroll-area-vertical']")
    vertical_viewport = vertical_area.find("[data-slot='scroll-area-viewport']")
    vertical_thumb = vertical_area.find("[data-orientation='vertical'] [data-slot='scroll-area-thumb']", visible: :all)

    assert_equal "true", vertical_area["data-has-overflow-y"]
    assert_equal "true", vertical_area["data-overflow-y-start"]
    assert vertical_thumb.evaluate_script("parseFloat(getComputedStyle(this).height)") > 0

    vertical_viewport.execute_script("this.scrollTop = 20; this.dispatchEvent(new Event('scroll'))")

    assert vertical_viewport.evaluate_script("this.scrollTop") > 0
    assert_equal "true", vertical_area["data-scrolling"]

    before_drag = vertical_viewport.evaluate_script("this.scrollTop")
    vertical_thumb.execute_script(<<~JS)
      const rect = this.getBoundingClientRect()
      this.dispatchEvent(new PointerEvent("pointerdown", { bubbles: true, clientX: rect.left + rect.width / 2, clientY: rect.top + rect.height / 2, pointerId: 1 }))
      window.dispatchEvent(new PointerEvent("pointermove", { bubbles: true, clientX: rect.left + rect.width / 2, clientY: rect.top + rect.height / 2 + 50, pointerId: 1 }))
      window.dispatchEvent(new PointerEvent("pointerup", { bubbles: true, pointerId: 1 }))
    JS
    assert vertical_viewport.evaluate_script("this.scrollTop") > before_drag

    rtl_area = find("[data-testid='scroll-area-rtl']")
    rtl_scrollbar = rtl_area.find("[data-orientation='vertical']", visible: :all)
    rtl_area_left = rtl_area.evaluate_script("this.getBoundingClientRect().left")
    rtl_scrollbar_left = rtl_scrollbar.evaluate_script("this.getBoundingClientRect().left")

    assert_in_delta rtl_area_left, rtl_scrollbar_left, 2
  end

  test "long documentation code blocks expand into a scroll area" do
    visit components_scroll_area_path

    example = find("#example-scroll_area_horizontal")
    code_block = example.find("[data-controller~='code-block']")

    assert_equal "false", code_block["data-code-block-expanded-value"]
    collapsed_scroll_area = code_block.find("[data-code-block-target='collapsed'][data-slot='scroll-area']", visible: :visible)

    collapsed_scroll_area.assert_selector "[data-orientation='horizontal']", visible: :all
    collapsed_scroll_area.assert_no_selector "[data-orientation='vertical']", visible: :all

    code_block.click_button "Expandir"

    assert_equal "true", code_block["data-code-block-expanded-value"]
    expanded_scroll_area = code_block.find("[data-slot='scroll-area']", visible: :visible)
    collapsed_background = code_block.find("[data-code-block-target='collapsed']", visible: :all)
                                     .evaluate_script("getComputedStyle(this).backgroundColor")
    expanded_background = expanded_scroll_area.evaluate_script("getComputedStyle(this).backgroundColor")

    assert_equal collapsed_background, expanded_background
    code_block.assert_selector "button", text: "Recolher"

    code_block.click_button "Recolher"

    assert_equal "false", code_block["data-code-block-expanded-value"]
    code_block.assert_selector "[data-code-block-target='collapsed'][data-slot='scroll-area']", visible: :visible
    code_block.assert_no_selector "[data-code-block-target='expanded'][data-slot='scroll-area']", visible: :visible
    code_block.assert_selector "button", text: "Expandir"
  end
end
