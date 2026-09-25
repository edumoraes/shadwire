# frozen_string_literal: true

require "test_helper"

class ToggleGroupComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include Ui::ToggleGroupHelper

    def call
      ui_toggle_group(type: :multiple, variant: :outline) do
        ui_toggle_group_item(value: "bold", pressed: true) { "B" } +
          ui_toggle_group_item(value: "italic") { "I" }
      end
    end
  end

  def test_root_wires_controller_and_type
    render_inline(Ui::ToggleGroupComponent.new(type: :multiple)) { "x" }

    assert_selector "div[role='group'][data-slot='toggle-group'][data-controller='ui-toggle-group'][data-ui-toggle-group-type-value='multiple']", text: "x"
  end

  def test_item_wires_target_and_actions
    render_inline(Ui::ToggleGroup::ItemComponent.new(value: "bold", pressed: true)) { "B" }

    assert_selector "button[data-slot='toggle-group-item'][data-value='bold'][data-state='on'][aria-pressed='true'][data-ui-toggle-group-target='item']", text: "B"
    assert_selector "button[data-action='click->ui-toggle-group#select keydown->ui-toggle-group#keydown']"
  end

  def test_helper_renders_group_with_items
    render_inline(HelperHarnessComponent.new)

    assert_selector "div[data-controller='ui-toggle-group'][data-variant='outline'] button[data-slot='toggle-group-item']", count: 2
    assert_selector "button[data-value='bold'][data-state='on']", text: "B"
    assert_selector "button[data-value='italic'][data-state='off']", text: "I"
  end

  # The items are one segmented control: square inner corners, rounded ends,
  # and a single border between neighbours. Each item used to be a rounded
  # button with its own border, so an outline group showed doubled lines.
  def test_items_join_into_one_segmented_control
    render_inline(Ui::ToggleGroup::ItemComponent.new(value: "a", variant: :outline)) { "A" }
    classes = page.find("button[data-slot='toggle-group-item']")[:class].split

    %w[
      rounded-none
      group-data-[orientation=horizontal]/toggle-group:first:rounded-l-md
      group-data-[orientation=horizontal]/toggle-group:last:rounded-r-md
      group-data-[orientation=horizontal]/toggle-group:border-l-0
      group-data-[orientation=horizontal]/toggle-group:first:border-l
      group-data-[orientation=vertical]/toggle-group:border-t-0
      focus-visible:z-10
    ].each { |utility| assert_includes classes, utility }
    refute_includes classes, "rounded-md"
  end
end
