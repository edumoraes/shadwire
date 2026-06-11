# frozen_string_literal: true

require "test_helper"

class CheckboxComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_checkbox(name: "user[terms]", id: "user_terms")
    end
  end

  def test_renders_checkbox_input
    render_inline(Ui::CheckboxComponent.new)

    assert_selector "input[type='checkbox'][data-slot='checkbox']"
    assert_selector "input.shadwire-checkbox.appearance-none"
  end

  def test_renders_checked_state
    render_inline(Ui::CheckboxComponent.new(checked: true))

    assert_selector "input[type='checkbox'][checked]"
  end

  def test_renders_disabled_state
    render_inline(Ui::CheckboxComponent.new(disabled: true))

    assert_selector "input[type='checkbox'][disabled]"
  end

  def test_renders_form_attrs_and_custom_class
    render_inline(Ui::CheckboxComponent.new(name: "user[terms]", id: "user_terms", value: "1", class: "mt-1"))

    assert_selector "input[name='user[terms]'][id='user_terms'][value='1'].mt-1"
  end

  def test_merges_aria_and_data_attrs
    render_inline(Ui::CheckboxComponent.new(aria: { invalid: "true" }, data: { turbo: false }))

    assert_selector "input[aria-invalid='true'][data-turbo='false'][data-slot='checkbox']"
  end

  def test_helper_renders_checkbox
    render_inline(HelperHarnessComponent.new)

    assert_selector "input[type='checkbox'][name='user[terms]'][data-slot='checkbox']"
  end
end
