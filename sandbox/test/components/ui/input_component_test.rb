# frozen_string_literal: true

require "test_helper"

class InputComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_input(type: :email, name: "user[email]", placeholder: "voce@exemplo.com")
    end
  end

  def test_renders_text_input_by_default
    render_inline(Ui::InputComponent.new)

    assert_selector "input[type='text'][data-slot='input']"
    assert_selector "input.border-input.rounded-md.w-full"
  end

  def test_renders_configurable_type_and_form_attrs
    render_inline(
      Ui::InputComponent.new(type: :email, name: "user[email]", id: "user_email", placeholder: "voce@exemplo.com")
    )

    assert_selector "input[type='email'][name='user[email]'][id='user_email'][placeholder='voce@exemplo.com']"
  end

  def test_accepts_class_alias_and_html_attrs
    render_inline(Ui::InputComponent.new(class: "w-64", data: { turbo: false }, aria: { invalid: "true" }))

    assert_selector "input.w-64[data-turbo='false'][aria-invalid='true'][data-slot='input']"
  end

  def test_renders_disabled_and_required_through_attrs
    render_inline(Ui::InputComponent.new(disabled: true, required: true))

    assert_selector "input[disabled][required]"
  end

  def test_helper_renders_input
    render_inline(HelperHarnessComponent.new)

    assert_selector "input[type='email'][name='user[email]'][data-slot='input']"
  end
end
