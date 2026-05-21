# frozen_string_literal: true

require "test_helper"

class BadgeComponentTest < ViewComponent::TestCase
  def test_renders_default_badge
    render_inline(Ui::BadgeComponent.new) { "Active" }

    assert_selector "span.bg-primary.text-primary-foreground", text: "Active"
  end

  def test_renders_outline_variant_and_attrs
    render_inline(Ui::BadgeComponent.new(variant: :outline, class: "uppercase", data: { state: "open" })) { "Beta" }

    assert_selector "span.border.uppercase[data-state='open']", text: "Beta"
  end
end
