# frozen_string_literal: true

require "test_helper"

class SpinnerComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_spinner(class: "size-6")
    end
  end

  def test_renders_status_spinner_with_label
    render_inline(Ui::SpinnerComponent.new)

    assert_selector "svg[role='status'][aria-label='Carregando'][data-slot='spinner'].animate-spin"
  end

  def test_decorative_when_label_blank
    render_inline(Ui::SpinnerComponent.new(label: nil))

    assert_selector "svg[aria-hidden='true']"
    assert_no_selector "svg[aria-label]"
  end

  def test_helper_renders_spinner
    render_inline(HelperHarnessComponent.new)

    assert_selector "svg[data-slot='spinner'].size-6.animate-spin"
  end
end
