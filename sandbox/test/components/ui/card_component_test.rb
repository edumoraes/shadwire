# frozen_string_literal: true

require "test_helper"

class CardComponentTest < ViewComponent::TestCase
  def test_renders_card_root
    render_inline(Ui::CardComponent.new(class_name: "max-w-sm")) { "Body" }

    assert_selector "div.rounded-xl.border.bg-card.text-card-foreground.shadow.max-w-sm", text: "Body"
  end

  def test_renders_card_subcomponents
    view = vc_test_controller.view_context

    title = Ui::Card::TitleComponent.new.render_in(view) { "Project" }
    description = Ui::Card::DescriptionComponent.new.render_in(view) { "Status" }
    header = Ui::Card::HeaderComponent.new.render_in(view) { title + description }
    body = Ui::Card::ContentComponent.new.render_in(view) { "Content" }
    footer = Ui::Card::FooterComponent.new(class: "justify-end").render_in(view) { "Footer" }

    render_inline(Ui::CardComponent.new) { header + body + footer }

    assert_selector ".flex.flex-col.p-6", text: "Project"
    assert_selector ".text-2xl", text: "Project"
    assert_selector ".text-muted-foreground", text: "Status"
    assert_selector ".p-6", text: "Content"
    assert_selector ".flex.items-center.justify-end", text: "Footer"
  end

  def test_every_part_names_its_slot
    {
      Ui::CardComponent => "card", Ui::Card::HeaderComponent => "card-header", Ui::Card::TitleComponent => "card-title",
      Ui::Card::DescriptionComponent => "card-description", Ui::Card::ContentComponent => "card-content",
      Ui::Card::FooterComponent => "card-footer"
    }.each do |component, slot|
      render_inline(component.new) { "x" }

      assert_selector "[data-slot='#{slot}']", text: "x"
    end
  end

  # `tag:` like every other component; `tag_name:`, the old spelling, still works.
  def test_title_takes_its_heading_level_from_tag
    render_inline(Ui::Card::TitleComponent.new) { "Project" }
    assert_selector "h3[data-slot='card-title']", text: "Project"

    render_inline(Ui::Card::TitleComponent.new(tag: :h2)) { "Project" }
    assert_selector "h2[data-slot='card-title']", text: "Project"

    render_inline(Ui::Card::TitleComponent.new(tag_name: :h4)) { "Project" }
    assert_selector "h4[data-slot='card-title']", text: "Project"
  end
end
