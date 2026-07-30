# frozen_string_literal: true

require "test_helper"

class SwitchComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include Ui::SwitchHelper

    def call
      ui_switch(id: "airplane-mode", name: "settings[airplane]", checked: true)
    end
  end

  def test_renders_native_checkbox_with_switch_role
    render_inline(Ui::SwitchComponent.new)

    assert_selector "input[type='checkbox'][role='switch'][data-slot='switch'].shadwire-switch"
    assert_selector "input.rounded-full.appearance-none"
  end

  def test_renders_checked_and_disabled_states
    render_inline(Ui::SwitchComponent.new(checked: true, disabled: true))

    assert_selector "input[role='switch'][checked][disabled]"
  end

  # `checked:bg-primary` and `dark:bg-input/80` have the same specificity, and
  # Tailwind emits the dark variant later — so without this companion the track
  # reads as off in dark mode no matter the state.
  def test_the_on_state_survives_dark_mode
    render_inline(Ui::SwitchComponent.new)

    classes = page.find("input[role='switch']", visible: :all)[:class].split
    assert_includes classes, "checked:bg-primary"
    assert_includes classes, "dark:checked:bg-primary"
  end

  def test_renders_form_attrs_and_custom_class
    render_inline(Ui::SwitchComponent.new(name: "settings[beta]", id: "beta", value: "on", class: "ml-2"))

    assert_selector "input[role='switch'][name='settings[beta]']#beta[value='on'].ml-2"
  end

  def test_merges_aria_and_data_attrs
    render_inline(Ui::SwitchComponent.new(aria: { describedby: "hint" }, data: { turbo: false }))

    assert_selector "input[role='switch'][aria-describedby='hint'][data-turbo='false'][data-slot='switch']"
  end

  def test_helper_renders_switch
    render_inline(HelperHarnessComponent.new)

    assert_selector "input[role='switch'][name='settings[airplane]'][checked]#airplane-mode"
  end
end
