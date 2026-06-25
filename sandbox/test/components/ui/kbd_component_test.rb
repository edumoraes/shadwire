# frozen_string_literal: true

require "test_helper"

class KbdComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_kbd_group do
        ui_kbd { "⌘" } + ui_kbd { "K" }
      end
    end
  end

  def test_renders_single_key
    render_inline(Ui::KbdComponent.new) { "Esc" }

    assert_selector "kbd[data-slot='kbd'].bg-muted.text-muted-foreground", text: "Esc"
  end

  def test_group_lays_out_keys
    render_inline(Ui::Kbd::GroupComponent.new) { "ctrl" }

    assert_selector "kbd[data-slot='kbd-group'].inline-flex", text: "ctrl"
  end

  def test_helper_renders_group_of_keys
    render_inline(HelperHarnessComponent.new)

    assert_selector "kbd[data-slot='kbd-group'] kbd[data-slot='kbd']", count: 2
    assert_selector "kbd[data-slot='kbd-group']", text: "⌘K"
  end
end
