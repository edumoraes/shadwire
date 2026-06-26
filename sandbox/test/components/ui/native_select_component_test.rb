# frozen_string_literal: true

require "test_helper"

class NativeSelectComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_native_select(name: "fruit", id: "fruit") do
        tag.option("Apple", value: "apple") + tag.option("Banana", value: "banana")
      end
    end
  end

  def test_renders_native_select_with_chevron
    render_inline(Ui::NativeSelectComponent.new(name: "color"))

    assert_selector "div.relative select[data-slot='native-select'][name='color'].appearance-none"
    assert_selector "div.relative svg[aria-hidden='true']"
  end

  def test_passes_through_disabled_and_options
    render_inline(Ui::NativeSelectComponent.new(disabled: true)) do
      "<option>One</option>".html_safe
    end

    assert_selector "select[data-slot='native-select'][disabled]"
    assert_selector "select option", text: "One"
  end

  def test_helper_renders_select_with_options
    render_inline(HelperHarnessComponent.new)

    assert_selector "select[data-slot='native-select'][name='fruit'][id='fruit']"
    assert_selector "select option[value='apple']", text: "Apple"
    assert_selector "select option[value='banana']", text: "Banana"
  end
end
