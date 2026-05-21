# frozen_string_literal: true

require "test_helper"

class AlertComponentTest < ViewComponent::TestCase
  def test_renders_default_alert
    render_inline(Ui::AlertComponent.new) { "Heads up" }

    assert_selector "div[role='alert'].border.bg-background", text: "Heads up"
  end

  def test_renders_destructive_alert
    render_inline(Ui::AlertComponent.new(variant: :destructive, class: "mb-4")) { "Error" }

    assert_selector "div.text-destructive.mb-4[class*='border-destructive']", text: "Error"
  end
end
