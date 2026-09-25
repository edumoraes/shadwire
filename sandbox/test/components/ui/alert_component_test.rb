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

  # The title and description were bare divs the caller styled by hand, so no
  # two alerts on the site looked alike; upstream has named parts.
  def test_title_and_description_are_named_parts
    view = vc_test_controller.view_context
    title = Ui::Alert::TitleComponent.new.render_in(view) { "Heads up" }
    description = Ui::Alert::DescriptionComponent.new.render_in(view) { "You can add components." }

    render_inline(Ui::AlertComponent.new) { title + description }

    assert_selector "div[data-slot='alert'] div[data-slot='alert-title'].font-medium", text: "Heads up"
    assert_selector "div[data-slot='alert'] div[data-slot='alert-description'].text-muted-foreground", text: "You can add components."
  end

  # An icon takes the first column and everything else moves to the second;
  # without one, nothing is pushed aside for an empty column.
  def test_only_an_icon_opens_the_second_column
    render_inline(Ui::AlertComponent.new) { "Text" }

    classes = page.find("div[data-slot='alert']")[:class].split
    assert_includes classes, "has-[>svg]:grid-cols-[calc(var(--spacing)*4)_1fr]"
    assert_includes classes, "[&:has(>svg)>:not(svg)]:col-start-2"
    refute_includes classes, "*:col-start-2"
  end

  def test_destructive_tints_the_description
    render_inline(Ui::AlertComponent.new(variant: :destructive)) { "Error" }

    assert_includes page.find("div[data-slot='alert']")[:class].split, "*:data-[slot=alert-description]:text-destructive/90"
  end

  def test_role_can_be_changed_for_a_non_urgent_message
    render_inline(Ui::AlertComponent.new(role: "status")) { "Saved" }

    assert_selector "div[role='status'][data-slot='alert']", text: "Saved"
  end
end
