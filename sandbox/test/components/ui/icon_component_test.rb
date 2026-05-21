# frozen_string_literal: true

require "test_helper"

class IconComponentTest < ViewComponent::TestCase
  def test_renders_lucide_svg
    render_inline(Ui::IconComponent.new("check"))

    assert_selector "svg"
  end

  def test_applies_default_size_and_shrink_classes
    render_inline(Ui::IconComponent.new("check"))

    assert_selector "svg.size-4.shrink-0"
  end

  def test_applies_size_variant
    render_inline(Ui::IconComponent.new("check", size: :lg))

    assert_selector "svg.size-5"
  end

  def test_merges_class_alias_and_html_attrs
    render_inline(Ui::IconComponent.new("check", class: "text-destructive", data: { role: "status" }))

    assert_selector "svg.text-destructive.size-4[data-role='status']"
  end

  def test_decorative_by_default
    render_inline(Ui::IconComponent.new("check"))

    assert_selector "svg[aria-hidden='true']"
  end

  def test_labelled_icon_is_exposed_to_assistive_tech
    render_inline(Ui::IconComponent.new("check", label: "Concluído"))

    assert_selector "svg[role='img'][aria-label='Concluído']"
    refute_selector "svg[aria-hidden]"
  end
end
