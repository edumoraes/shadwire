# frozen_string_literal: true

require "test_helper"

class TextareaComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_textarea(name: "post[body]", placeholder: "Digite sua mensagem") { "Rascunho" }
    end
  end

  def test_renders_textarea_with_content
    render_inline(Ui::TextareaComponent.new) { "Olá mundo" }

    assert_selector "textarea[data-slot='textarea']", text: "Olá mundo"
    assert_selector "textarea.border-input.rounded-md.w-full"
  end

  def test_renders_form_attrs
    render_inline(Ui::TextareaComponent.new(name: "post[body]", rows: 6, placeholder: "Digite aqui"))

    assert_selector "textarea[name='post[body]'][rows='6'][placeholder='Digite aqui']"
  end

  def test_accepts_class_alias_and_html_attrs
    render_inline(Ui::TextareaComponent.new(class: "min-h-32", data: { turbo: false }, aria: { invalid: "true" }))

    assert_selector "textarea.min-h-32[data-turbo='false'][aria-invalid='true']"
  end

  def test_renders_disabled_through_attrs
    render_inline(Ui::TextareaComponent.new(disabled: true))

    assert_selector "textarea[disabled]"
  end

  def test_helper_renders_textarea
    render_inline(HelperHarnessComponent.new)

    assert_selector "textarea[name='post[body]'][placeholder='Digite sua mensagem']", text: "Rascunho"
  end
end
