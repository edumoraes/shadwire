# frozen_string_literal: true

require "test_helper"

class UiAccessibilityTest < ActionDispatch::IntegrationTest
  test "showcase renders semantic component markup" do
    get root_path

    assert_response :success
    assert_select "main"
    assert_select "button[type='button']", text: "Default"
    assert_select "[role='alert']", text: /Components render/
    assert_select "[role='separator'][aria-orientation='horizontal'][data-orientation='horizontal']"
    assert_select "[role='region'][data-slot='accordion'][data-controller='ui-accordion']"
    assert_select "h3[data-slot='accordion-header'] button[type='button'][data-slot='accordion-trigger']", text: "Accordion item"
    assert_select "[role='region'][data-slot='accordion-content'][hidden]", text: /semantic disclosure/
    assert_select "[data-slot='scroll-area'][data-controller='ui-scroll-area']"
    assert_select "[data-slot='scroll-area-viewport']"
    assert_select "[data-slot='scroll-area-scrollbar'][data-orientation='vertical']"
    assert_select "img[alt='Example user']"
    assert_select "span[aria-hidden='true']", text: "EU"
    assert_select "button svg[aria-hidden='true']"
    assert_select "svg[role='img'][aria-label='Adicionar item']"
    assert_select "button[aria-label='Alternar tema']"
    assert_select "label[for='showcase-email'][data-slot='label']", text: "Email"
    assert_select "input[type='email']#showcase-email[data-slot='input']"
    assert_select "label[for='showcase-message'][data-slot='label']", text: "Mensagem"
    assert_select "textarea#showcase-message[data-slot='textarea']"
  end
end
