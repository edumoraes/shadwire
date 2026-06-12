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
    assert_select "input[type='checkbox']#showcase-terms[data-slot='checkbox']"
    assert_select "label[for='showcase-terms']", text: "Aceito os termos"
    assert_select "[role='radiogroup'][aria-label='Tema preferido']"
    assert_select "[role='radiogroup'] input[type='radio'][name='showcase-theme']", count: 2
    assert_select "label[for='showcase-theme-light']", text: "Claro"
    assert_select "input[type='checkbox'][role='switch']#showcase-notifications[data-slot='switch']"
    assert_select "label[for='showcase-notifications']", text: "Notificações"
    assert_select "[data-slot='skeleton'][aria-hidden='true']"
    assert_select "[role='progressbar'][aria-valuemin='0'][aria-valuemax='100'][aria-valuenow='60'][aria-label='Progresso de exemplo']"
    assert_select "table[data-slot='table'] caption", text: "Faturas do mês"
    assert_select "table thead th[scope='col']", text: "Fatura"
    assert_select "table tbody td", text: "INV001"
    assert_select "nav[aria-label='breadcrumb'] ol li a[data-slot='breadcrumb-link']", text: "Início"
    assert_select "nav[aria-label='breadcrumb'] li[role='presentation'][aria-hidden='true']"
    assert_select "nav[aria-label='breadcrumb'] span[aria-current='page']", text: "Showcase"
    assert_select "nav[role='navigation'][aria-label='pagination'] ul li a[aria-current='page']", text: "1"
    assert_select "nav[aria-label='pagination'] a[aria-label='Ir para a página anterior']"
    assert_select "nav[aria-label='pagination'] a[aria-label='Ir para a próxima página']"
    assert_select "[data-slot='tabs'][data-controller='ui-tabs'][data-ui-tabs-default-value-value='preview']"
    assert_select "[role='tablist'] button[type='button'][role='tab'][data-ui-tabs-value='preview']", text: "Preview"
    assert_select "[role='tabpanel'][tabindex='0'][hidden][data-ui-tabs-value='code']"
    assert_select "[data-slot='dialog'][data-controller='ui-dialog']"
    assert_select "button[aria-haspopup='dialog'][data-slot='dialog-trigger']", text: "Abrir diálogo"
    assert_select "dialog[data-slot='dialog-content'][data-ui-dialog-target='dialog'] h2[data-slot='dialog-title']"
    assert_select "[data-slot='alert-dialog'][data-ui-dialog-close-on-escape-value='false']"
    assert_select "dialog[role='alertdialog'][data-slot='alert-dialog-content'] h2[data-slot='alert-dialog-title']"
    assert_select "[data-slot='sheet'][data-controller='ui-dialog']"
    assert_select "dialog[data-slot='sheet-content'][data-side='right'] h2[data-slot='sheet-title']"
    assert_select "[data-slot='tooltip'][data-controller='ui-tooltip']"
    assert_select "button[data-slot='tooltip-trigger'][data-ui-tooltip-target='trigger']", text: "Hover"
    assert_select "[role='tooltip'][hidden][data-ui-tooltip-target='content']", text: "Tooltip de exemplo"
  end
end
