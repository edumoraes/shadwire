# frozen_string_literal: true

require "test_helper"

class ButtonComponentTest < ViewComponent::TestCase
  def test_renders_default_button
    render_inline(Ui::ButtonComponent.new) { "Save" }

    assert_selector "button[type='button']", text: "Save"
    assert_selector "button.bg-primary.text-primary-foreground"
  end

  def test_renders_variant_size_and_custom_class
    render_inline(Ui::ButtonComponent.new(variant: :outline, size: :sm, class_name: "w-full")) { "Save" }

    assert_selector "button.border.bg-background.h-8.w-full", text: "Save"
  end

  def test_accepts_class_alias_and_html_attrs
    render_inline(Ui::ButtonComponent.new(class: "justify-start", data: { turbo: false })) { "Save" }

    assert_selector "button.justify-start[data-turbo='false']", text: "Save"
  end

  def test_renders_native_disabled_button
    render_inline(Ui::ButtonComponent.new(disabled: true)) { "Save" }

    assert_selector "button[disabled][data-disabled]", text: "Save"
  end

  def test_renders_focusable_disabled_button
    render_inline(Ui::ButtonComponent.new(disabled: true, focusable_when_disabled: true)) { "Save" }

    assert_selector "button[aria-disabled='true'][tabindex='0'][data-disabled]", text: "Save"
    assert_no_selector "button[disabled]"
  end

  def test_renders_configurable_tag
    render_inline(Ui::ButtonComponent.new(tag: :a, href: "/demo")) { "Open" }

    assert_selector "a[href='/demo']", text: "Open"
    assert_no_selector "a[role='button']"
    assert_no_selector "a[type]"
  end

  def test_merges_data_and_aria_attrs_with_disabled_attrs
    render_inline(
      Ui::ButtonComponent.new(
        disabled: true,
        focusable_when_disabled: true,
        data: { turbo: false },
        aria: { describedby: "hint" }
      )
    ) { "Save" }

    assert_selector "button[data-turbo='false'][data-disabled][aria-describedby='hint'][aria-disabled='true']",
                    text: "Save"
  end
end
