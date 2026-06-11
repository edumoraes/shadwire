# frozen_string_literal: true

require "test_helper"

class RadioGroupComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_radio_group(aria: { label: "Plano" }) do
        safe_join(
          [
            ui_radio_group_item(name: "plan", value: "free", id: "plan-free", checked: true),
            ui_radio_group_item(name: "plan", value: "pro", id: "plan-pro")
          ]
        )
      end
    end
  end

  def test_renders_radiogroup_role
    render_inline(Ui::RadioGroupComponent.new) { "items" }

    assert_selector "[role='radiogroup'][data-slot='radio-group'].grid", text: "items"
  end

  def test_renders_item_as_native_radio
    view = vc_test_controller.view_context
    item = Ui::RadioGroup::ItemComponent.new(name: "plan", value: "free", id: "plan-free").render_in(view)

    render_inline(Ui::RadioGroupComponent.new) { item }

    assert_selector "[role='radiogroup'] input[type='radio'][name='plan'][value='free']#plan-free[data-slot='radio-group-item']"
  end

  def test_item_renders_checked_and_disabled_states
    render_inline(Ui::RadioGroup::ItemComponent.new(name: "plan", value: "pro", checked: true, disabled: true))

    assert_selector "input[type='radio'][checked][disabled].shadwire-radio"
  end

  def test_item_accepts_class_alias_and_html_attrs
    render_inline(
      Ui::RadioGroup::ItemComponent.new(name: "plan", value: "free", class: "mt-1", data: { turbo: false })
    )

    assert_selector "input[type='radio'].mt-1[data-turbo='false']"
  end

  def test_group_merges_aria_label
    render_inline(Ui::RadioGroupComponent.new(aria: { label: "Plano" })) { "items" }

    assert_selector "[role='radiogroup'][aria-label='Plano']"
  end

  def test_helper_methods_render_radio_group
    render_inline(HelperHarnessComponent.new)

    assert_selector "[role='radiogroup'][aria-label='Plano']"
    assert_selector "input[type='radio'][name='plan'][checked]#plan-free"
    assert_selector "input[type='radio'][name='plan']#plan-pro"
  end
end
