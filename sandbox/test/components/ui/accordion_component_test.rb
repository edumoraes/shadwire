# frozen_string_literal: true

require "test_helper"

class AccordionComponentTest < ViewComponent::TestCase
  class HelperHarnessComponent < ViewComponent::Base
    include UiHelper

    def call
      ui_accordion(default_value: :details) do
        ui_accordion_item(value: :details) do
          ui_accordion_header do
            ui_accordion_trigger { "Details" }
          end + ui_accordion_panel { "More information" }
        end
      end
    end
  end

  def test_renders_root_with_controller_values
    render_inline(
      Ui::AccordionComponent.new(
        multiple: true,
        default_value: [ :first, "second" ],
        orientation: :horizontal,
        loop_focus: false,
        class_name: "w-full",
        data: { testid: "faq" }
      )
    ) { "Items" }

    assert_selector "div[role='region'][data-slot='accordion'][data-controller='ui-accordion'].w-full",
                    text: "Items"
    assert_selector "div[data-orientation='horizontal'][data-testid='faq']"
    assert_selector "div[data-ui-accordion-multiple-value='true']"
    assert_selector "div[data-ui-accordion-loop-focus-value='false']"
    assert_selector "div[data-ui-accordion-disabled-value='false']"
    assert_includes rendered_content, "data-ui-accordion-default-value-value=\"[&quot;first&quot;,&quot;second&quot;]\""
  end

  def test_renders_item_header_trigger_and_content
    view = vc_test_controller.view_context

    trigger = Ui::Accordion::TriggerComponent.new.render_in(view) { "Shipping" }
    header = Ui::Accordion::HeaderComponent.new.render_in(view) { trigger }
    content = Ui::Accordion::ContentComponent.new.render_in(view) { "Ships tomorrow" }
    item = Ui::Accordion::ItemComponent.new(value: :shipping).render_in(view) { header + content }

    render_inline(Ui::AccordionComponent.new(default_value: :shipping)) { item }

    assert_selector "[data-slot='accordion-item'][data-ui-accordion-target='item'][data-ui-accordion-value='shipping'].border-b"
    assert_selector "h3[data-slot='accordion-header'].flex"
    assert_selector "button[type='button'][data-slot='accordion-trigger'][data-ui-accordion-target='trigger']",
                    text: "Shipping"
    assert_selector "button[data-action*='click->ui-accordion#toggle'][data-action*='keydown->ui-accordion#navigate']"
    assert_selector "button svg[aria-hidden='true']"
    assert_selector "div[role='region'][hidden][data-slot='accordion-content'][data-ui-accordion-target='content']",
                    text: "Ships tomorrow",
                    visible: :all
    assert_selector "div.pt-0.pb-4", text: "Ships tomorrow", visible: :all
  end

  def test_accepts_class_alias_html_attrs_and_custom_header_tag
    view = vc_test_controller.view_context

    trigger = Ui::Accordion::TriggerComponent.new(class: "text-left", aria: { describedby: "hint" }).render_in(view) { "Billing" }
    header = Ui::Accordion::HeaderComponent.new(tag: :h2, class_name: "tracking-tight").render_in(view) { trigger }
    item = Ui::Accordion::ItemComponent.new(class: "px-2", data: { turbo: false }).render_in(view) { header }

    render_inline(Ui::AccordionComponent.new(class: "divide-y")) { item }

    assert_selector "[data-slot='accordion'].divide-y"
    assert_selector "[data-slot='accordion-item'].px-2[data-turbo='false']"
    assert_selector "h2[data-slot='accordion-header'].tracking-tight"
    assert_selector "button.text-left[aria-describedby='hint']", text: "Billing"
  end

  def test_renders_disabled_state
    view = vc_test_controller.view_context

    trigger = Ui::Accordion::TriggerComponent.new(disabled: true).render_in(view) { "Locked" }
    item = Ui::Accordion::ItemComponent.new(disabled: true).render_in(view) { trigger }

    render_inline(Ui::AccordionComponent.new(disabled: true)) { item }

    assert_selector "[data-slot='accordion'][data-disabled][aria-disabled='true']"
    assert_selector "[data-slot='accordion-item'][data-disabled][aria-disabled='true']"
    assert_selector "button[disabled][aria-disabled='true'][data-disabled]", text: "Locked"
  end

  def test_renders_panel_alias
    render_inline(Ui::Accordion::PanelComponent.new(class_name: "text-muted-foreground")) { "Panel body" }

    assert_selector "[data-slot='accordion-content'].text-muted-foreground", text: "Panel body", visible: :all
  end

  def test_helper_methods_render_accordion_parts
    render_inline(HelperHarnessComponent.new)

    assert_selector "[data-controller='ui-accordion']"
    assert_selector "button", text: "Details"
    assert_selector "[data-slot='accordion-content']", text: "More information", visible: :all
  end
end
