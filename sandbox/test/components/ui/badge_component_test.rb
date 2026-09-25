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

  # A badge that links somewhere is an <a>, and only a link darkens on hover:
  # a static badge that reacts to the pointer promises a click that does nothing.
  def test_tag_renders_a_link_badge_that_alone_reacts_to_hover
    render_inline(Ui::BadgeComponent.new(tag: :a, href: "/changelog")) { "New" }

    link = page.find("a[data-slot='badge'][href='/changelog']", text: "New")
    assert_includes link[:class].split, "[a&]:hover:bg-primary/80"
    refute_includes link[:class].split, "hover:bg-primary/80"
  end

  def test_filled_variants_keep_a_transparent_border_so_all_badges_share_a_height
    %i[default secondary destructive].each do |variant|
      render_inline(Ui::BadgeComponent.new(variant: variant)) { "x" }

      assert_selector "span[data-slot='badge'].border.border-transparent", text: "x"
    end
  end
end
