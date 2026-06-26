# frozen_string_literal: true

require "test_helper"

class ToggleComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_toggle(variant: :outline, pressed: true) { "B" }
    end
  end

  def test_default_off_toggle
    render_inline(Ui::ToggleComponent.new) { "B" }

    assert_selector "button[type='button'][data-slot='toggle'][data-state='off'][aria-pressed='false'][data-controller='ui-toggle']", text: "B"
    assert_selector "button[data-action='click->ui-toggle#toggle'][data-ui-toggle-pressed-value='false']"
  end

  def test_pressed_outline_toggle
    render_inline(Ui::ToggleComponent.new(variant: :outline, size: :sm, pressed: true)) { "B" }

    assert_selector "button[data-state='on'][aria-pressed='true'].border.h-8", text: "B"
  end

  def test_disabled
    render_inline(Ui::ToggleComponent.new(disabled: true)) { "B" }

    assert_selector "button[disabled]"
  end

  def test_helper_renders_toggle
    render_inline(HelperHarnessComponent.new)

    assert_selector "button[data-slot='toggle'][data-state='on'][aria-pressed='true']", text: "B"
  end
end
