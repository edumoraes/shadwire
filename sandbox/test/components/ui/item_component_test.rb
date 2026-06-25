# frozen_string_literal: true

require "test_helper"

class ItemComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_item_group do
        ui_item(variant: :outline) do
          ui_item_media(variant: :icon) { "I" } +
            ui_item_content do
              ui_item_title { "Invoice" } + ui_item_description { "Paid on May 1" }
            end +
            ui_item_actions { "act" }
        end +
          ui_item_separator
      end
    end
  end

  def test_root_defaults_to_div_with_variant_and_size
    render_inline(Ui::ItemComponent.new) { "row" }

    assert_selector "div[data-slot='item'][data-variant='default'][data-size='default']", text: "row"
  end

  def test_renders_as_link_with_outline_variant
    render_inline(Ui::ItemComponent.new(tag: :a, variant: :outline, size: :sm, href: "/x")) { "row" }

    assert_selector "a[data-slot='item'][data-variant='outline'][data-size='sm'][href='/x'].border-border", text: "row"
  end

  def test_helper_composes_item_with_separator
    render_inline(HelperHarnessComponent.new)

    assert_selector "div[data-slot='item-group'][role='list']"
    assert_selector "div[data-slot='item'] div[data-slot='item-media'][data-variant='icon']"
    assert_selector "div[data-slot='item-title']", text: "Invoice"
    assert_selector "p[data-slot='item-description']", text: /Paid on May 1/
    assert_selector "div[data-slot='item-actions']", text: "act"
    assert_selector "div[data-slot='item-separator'][role='separator']"
  end
end
