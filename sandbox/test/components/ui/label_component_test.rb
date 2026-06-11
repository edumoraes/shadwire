# frozen_string_literal: true

require "test_helper"

class LabelComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_label(for: "email") { "Email" }
    end
  end

  def test_renders_label_with_for_attribute
    render_inline(Ui::LabelComponent.new(for: "email")) { "Email" }

    assert_selector "label[for='email'][data-slot='label']", text: "Email"
  end

  def test_renders_base_classes
    render_inline(Ui::LabelComponent.new) { "Email" }

    assert_selector "label.text-sm.font-medium.select-none", text: "Email"
  end

  def test_accepts_class_alias_and_html_attrs
    render_inline(Ui::LabelComponent.new(class: "sr-only", data: { testid: "field-label" })) { "Oculto" }

    assert_selector "label.sr-only[data-testid='field-label']", text: "Oculto"
  end

  def test_helper_renders_label
    render_inline(HelperHarnessComponent.new)

    assert_selector "label[for='email'][data-slot='label']", text: "Email"
  end
end
