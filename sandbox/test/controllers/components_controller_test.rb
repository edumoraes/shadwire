# frozen_string_literal: true

require "test_helper"

class ComponentsControllerTest < ActionDispatch::IntegrationTest
  test "button docs page renders with heading and description" do
    get components_button_path

    assert_response :success
    assert_select "h1", text: "Button"
    assert_select "p", text: /se parece com um botão/
  end

  test "button docs page shows a live preview for every variant" do
    get components_button_path

    assert_select "button.bg-primary.text-primary-foreground"      # default
    assert_select "button.bg-secondary"                            # secondary
    assert_select "button.bg-destructive"                          # destructive
    assert_select "button.border.bg-background"                    # outline
    assert_select "button.text-primary.underline-offset-4"         # link
    assert_select "button[disabled]"                               # disabled / loading
    assert_select "a.border.bg-background[href='#']"               # as link
  end

  test "button docs page renders highlighted code blocks with copy controls" do
    get components_button_path

    assert_select "pre.highlight span"                             # rouge tokens
    assert_select "[data-controller='clipboard']"
    assert_select "[data-action='clipboard#copy']"
  end

  test "button docs page documents the component api" do
    get components_button_path

    assert_select "table td code", text: "variant"
    assert_select "table td code", text: "size"
    assert_select "table td code", text: "tag"
  end

  test "accordion docs page renders with heading and description" do
    get components_accordion_path

    assert_response :success
    assert_select "h1", text: "Accordion"
    assert_select "p", text: /conjunto vertical de cabeçalhos interativos/
  end

  test "accordion docs page shows live examples from the shadcn reference" do
    get components_accordion_path

    assert_select "[data-controller='ui-accordion']"
    assert_select "[data-slot='accordion-trigger']", text: "Como faço para redefinir minha senha?"
    assert_select "[data-ui-accordion-multiple-value='true']"
    assert_select "[data-slot='accordion-item'][data-disabled]"
    assert_select ".border [data-slot='accordion-item'].border-b"
    assert_select ".bg-card [data-slot='accordion']"
  end

  test "accordion docs page renders usage composition and api" do
    get components_accordion_path

    assert_select "pre.highlight span"
    assert_select "code", text: "ui_accordion"
    assert_select "code", text: "ui_accordion_item"
    assert_select "code", text: "ui_accordion_trigger"
    assert_select "table td code", text: "multiple"
    assert_select "table td code", text: "default_value"
    assert_select "table td code", text: "loop_focus"
  end
end
