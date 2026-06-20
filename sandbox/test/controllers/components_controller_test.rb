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

  test "short code examples render copy controls without expand controls" do
    get components_button_path

    assert_select "section#example-default [data-controller='clipboard']"
    assert_select "section#example-default [data-action='clipboard#copy']"
    assert_select "section#example-default [data-action='code-block#toggle']", count: 0
    assert_select "section#example-default [data-controller='ui-scroll-area']"
    assert_select "section#example-default [data-orientation='horizontal']"
    assert_select "section#example-default [data-orientation='vertical']", count: 0
  end

  test "button docs page documents the component api" do
    get components_button_path

    assert_select "table td code", text: "variant"
    assert_select "table td code", text: "size"
    assert_select "table td code", text: "tag"
  end

  test "badge docs page renders examples and api" do
    get components_badge_path

    assert_response :success
    assert_select "h1", text: "Badge"
    assert_select "span.bg-primary.text-primary-foreground", text: "Badge"
    assert_select "span.bg-secondary", text: "Secondary"
    assert_select "span.bg-destructive", text: "Destructive"
    assert_select "span.border.border-input", text: "Outline"
    assert_select "table td code", text: "variant"
  end

  test "card docs page renders examples and api" do
    get components_card_path

    assert_response :success
    assert_select "h1", text: "Card"
    assert_select "[data-slot='card'].bg-card"
    assert_select "[data-slot='card-title']", text: "Criar projeto"
    assert_select "[data-slot='card-footer'] button", text: "Criar"
    assert_select "table td code", text: "ui_card_header"
  end

  test "alert docs page renders examples and api" do
    get components_alert_path

    assert_response :success
    assert_select "h1", text: "Alert"
    assert_select "div[role='alert'].bg-background", text: /Heads up/
    assert_select "div[role='alert'].text-destructive", text: /Erro ao salvar/
    assert_select "table td code", text: "variant"
  end

  test "separator docs page renders examples and api" do
    get components_separator_path

    assert_response :success
    assert_select "h1", text: "Separator"
    assert_select "div[role='separator'][aria-orientation='horizontal'][data-orientation='horizontal']"
    assert_select "div[role='separator'][aria-orientation='vertical'][data-orientation='vertical']"
    assert_select "div[role='none'][aria-hidden='true'][data-orientation='horizontal']"
    assert_select "table td code", text: "decorative"
  end

  test "avatar docs page renders examples and api" do
    get components_avatar_path

    assert_response :success
    assert_select "h1", text: "Avatar"
    assert_select "span.relative.flex img[alt='Eduardo Moraes']"
    assert_select "span.relative.flex span", text: "EM"
    assert_select "span[aria-label='Usuário anônimo'] span", text: "?"
    assert_select "table td code", text: "fallback"
  end

  test "icon docs page renders examples and api" do
    get components_icon_path

    assert_response :success
    assert_select "h1", text: "Icon"
    assert_select "section#example-icon_default svg[aria-hidden='true']"
    assert_select "svg[role='img'][aria-label='Notificações']"
    assert_select "table td code", text: "label"
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

  test "scroll area docs page renders examples and api" do
    get components_scroll_area_path

    assert_response :success
    assert_select "h1", text: "Scroll Area"
    assert_select "p", text: /Augments native scroll functionality/
    assert_select "h2", text: "Installation"
    assert_select "h2", text: "Usage"
    assert_select "h2", text: "Composition"
    assert_select "h2", text: "Examples"
    assert_select "h3", text: "Horizontal"
    assert_select "h2", text: "RTL"
    assert_select "section#example-scroll_area_rtl", text: /التمرير/
    assert_select "section#example-scroll_area_rtl [data-controller~='clipboard']"
    assert_select "h2", text: "API Reference"
    assert_select "[data-controller='ui-scroll-area']"
    assert_select "[data-slot='scroll-area'][dir='rtl']", text: /التمرير/
    assert_select "[data-slot='scroll-area-scrollbar'][data-orientation='vertical']"
    assert_select "[data-slot='scroll-area-scrollbar'][data-orientation='horizontal']"
    assert_select "code", text: "ui_scroll_area"
    assert_select "code", text: "ui_scroll_bar"
    assert_select "code", text: "scrollbars"
    assert_select "code", text: "ScrollArea"
    assert_select "code", text: "ScrollBar"
  end

  test "input docs page renders examples and api" do
    get components_input_path

    assert_response :success
    assert_select "h1", text: "Input"
    assert_select "p", text: /se parece com um campo de texto/
    assert_select "input[type='email'][data-slot='input']"
    assert_select "input[type='file'][data-slot='input']"
    assert_select "input[disabled][data-slot='input']"
    assert_select "input[name='newsletter[email]'][id='newsletter_email']"
    assert_select "table td code", text: "type"
  end

  test "label docs page renders examples and api" do
    get components_label_path

    assert_response :success
    assert_select "h1", text: "Label"
    assert_select "label[for='label-demo-username'][data-slot='label']", text: "Nome de usuário"
    assert_select "[data-disabled='true'] label[for='label-demo-disabled']"
    assert_select "table td code", text: "**attrs"
  end

  test "textarea docs page renders examples and api" do
    get components_textarea_path

    assert_response :success
    assert_select "h1", text: "Textarea"
    assert_select "textarea[data-slot='textarea'][placeholder='Digite sua mensagem aqui.']"
    assert_select "textarea[disabled][data-slot='textarea']"
    assert_select "label[for='textarea-message']", text: "Sua mensagem"
    assert_select "table td code", text: "&block"
  end

  test "checkbox docs page renders examples and api" do
    get components_checkbox_path

    assert_response :success
    assert_select "h1", text: "Checkbox"
    assert_select "input[type='checkbox'][data-slot='checkbox']"
    assert_select "input[type='checkbox'][checked]#checkbox-newsletter"
    assert_select "input[type='checkbox'][disabled]#checkbox-disabled"
    assert_select "input[type='checkbox'][name='signup[terms]'][id='signup_terms']"
    assert_select "table td code", text: "checked"
  end

  test "radio group docs page renders examples and api" do
    get components_radio_group_path

    assert_response :success
    assert_select "h1", text: "Radio Group"
    assert_select "[role='radiogroup'][aria-label='Densidade da interface']"
    assert_select "input[type='radio'][name='density'][checked]#density-default"
    assert_select "input[type='radio'][disabled]#plan-enterprise"
    assert_select "input[type='radio'][name='subscription[cycle]'][id='subscription_cycle_monthly']"
    assert_select "table td code", text: "value:"
  end

  test "switch docs page renders examples and api" do
    get components_switch_path

    assert_response :success
    assert_select "h1", text: "Switch"
    assert_select "input[role='switch'][data-slot='switch']"
    assert_select "input[role='switch'][checked]#switch-notifications"
    assert_select "input[role='switch'][disabled]#switch-disabled"
    assert_select "input[role='switch'][name='settings[marketing]']"
    assert_select "table td code", text: "checked"
  end

  test "skeleton docs page renders examples and api" do
    get components_skeleton_path

    assert_response :success
    assert_select "h1", text: "Skeleton"
    assert_select "[data-slot='skeleton'][aria-hidden='true'].rounded-full"
    assert_select "table td code", text: "**attrs"
  end

  test "progress docs page renders examples and api" do
    get components_progress_path

    assert_response :success
    assert_select "h1", text: "Progress"
    assert_select "[role='progressbar'][aria-valuenow='60']"
    assert_select "[role='progressbar'][aria-valuemax='12'][aria-valuenow='8']"
    assert_select "table td code", text: "max"
  end

  test "table docs page renders examples and api" do
    get components_table_path

    assert_response :success
    assert_select "h1", text: "Table"
    assert_select "[data-slot='table-container'] table caption", text: /faturas recentes/
    assert_select "table thead th[scope='col']", text: "Status"
    assert_select "table tfoot td[colspan='3']", text: "Total"
    assert_select "tr[data-state='selected']"
    assert_select "table td code", text: "ui_table_caption"
  end

  test "breadcrumb docs page renders examples and api" do
    get components_breadcrumb_path

    assert_response :success
    assert_select "h1", text: "Breadcrumb"
    assert_select "nav[aria-label='breadcrumb'] a[data-slot='breadcrumb-link']", text: "Início"
    assert_select "span[aria-current='page'][data-slot='breadcrumb-page']", text: "Breadcrumb"
    assert_select "[data-slot='breadcrumb-ellipsis']"
    assert_select "table td code", text: "ui_breadcrumb_page"
  end

  test "pagination docs page renders examples and api" do
    get components_pagination_path

    assert_response :success
    assert_select "h1", text: "Pagination"
    assert_select "nav[aria-label='pagination'] a[aria-current='page'][data-active]", text: "2"
    assert_select "a[aria-label='Ir para a página anterior'] svg"
    assert_select "[data-slot='pagination-ellipsis'] span.sr-only", text: "Mais páginas"
    assert_select "table td code", text: "active: false"
  end

  test "tabs docs page renders examples and api" do
    get components_tabs_path

    assert_response :success
    assert_select "h1", text: "Tabs"
    assert_select "[data-controller='ui-tabs'][data-ui-tabs-default-value-value='account']"
    assert_select "[role='tablist'] button[role='tab'][data-ui-tabs-value='password']", text: "Senha"
    assert_select "button[role='tab'][disabled][data-disabled]", text: "Analytics"
    assert_select "[role='tabpanel'][data-ui-tabs-value='account'][hidden]"
    assert_select "table td code", text: "default_value"
  end

  test "dialog docs page renders examples and api" do
    get components_dialog_path

    assert_response :success
    assert_select "h1", text: "Dialog"
    assert_select "[data-controller='ui-dialog'] button[aria-haspopup='dialog']", text: "Editar perfil"
    assert_select "dialog[data-slot='dialog-content'] h2[data-slot='dialog-title']", text: "Editar perfil"
    assert_select "[data-ui-dialog-close-on-backdrop-value='false']"
    assert_select "dialog [data-slot='dialog-close-x'] span.sr-only", text: "Fechar"
    assert_select "table td code", text: "close_on_backdrop"
  end

  test "alert dialog docs page renders examples and api" do
    get components_alert_dialog_path

    assert_response :success
    assert_select "h1", text: "Alert Dialog"
    assert_select "[data-ui-dialog-close-on-backdrop-value='false'][data-ui-dialog-close-on-escape-value='false']"
    assert_select "dialog[role='alertdialog'] h2[data-slot='alert-dialog-title']", text: "Tem certeza absoluta?"
    assert_select "[data-slot='alert-dialog-cancel']", text: "Cancelar"
    assert_select "[data-slot='alert-dialog-action']", text: "Continuar"
    assert_select "table td code", text: "AlertDialog::Cancel"
  end

  test "sheet docs page renders examples and api" do
    get components_sheet_path

    assert_response :success
    assert_select "h1", text: "Sheet"
    assert_select "dialog[data-slot='sheet-content'][data-side='right'] h2[data-slot='sheet-title']", text: "Editar perfil"
    assert_select "dialog[data-side='top']"
    assert_select "dialog[data-side='bottom']"
    assert_select "dialog[data-side='left']"
    assert_select "table td code", text: "side"
  end

  test "tooltip docs page renders examples and api" do
    get components_tooltip_path

    assert_response :success
    assert_select "h1", text: "Tooltip"
    assert_select "[data-controller='ui-tooltip'] button[data-slot='tooltip-trigger']", text: "Passe o mouse"
    assert_select "[role='tooltip'][data-ui-tooltip-target='content']", text: "Adicionar à biblioteca"
    assert_select "[role='tooltip'].left-full" # right side example
    assert_select "table td code", text: "open_delay"
  end

  test "popover docs page renders examples and api" do
    get components_popover_path

    assert_response :success
    assert_select "h1", text: "Popover"
    assert_select "[data-controller='ui-popover'] button[data-slot='popover-trigger']", text: "Abrir dimensões"
    assert_select "[role='dialog'][data-ui-popover-target='content'][hidden]"
    assert_select "[data-slot='popover-content'].left-0" # align: :start example
    assert_select "table td code", text: "align"
  end

  test "dropdown menu docs page renders examples and api" do
    get components_dropdown_menu_path

    assert_response :success
    assert_select "h1", text: "Dropdown Menu"
    assert_select "[data-controller='ui-dropdown-menu'] button[aria-haspopup='menu']", text: "Abrir"
    assert_select "[role='menu'] [data-slot='dropdown-menu-label']", text: "Minha conta"
    assert_select "[role='menu'] button[role='menuitem'][data-disabled]", text: "Indisponível"
    assert_select "[role='menu'] a[role='menuitem'][href='#docs']", text: "Documentação"
    assert_select "[role='menu'] button[data-variant='destructive']", text: /Excluir/
    assert_select "table td code", text: "inset"
  end

  test "select docs page renders examples and api" do
    get components_select_path

    assert_response :success
    assert_select "h1", text: "Select"
    assert_select "[data-controller='ui-select'] button[role='combobox'][data-slot='select-trigger']"
    assert_select "input[type='hidden'][name='fruit']"
    assert_select "[role='listbox'] [role='option'][data-value='banana']", text: "Banana"
    assert_select "[role='listbox'] [role='group'] [data-slot='select-label']", text: "América do Norte"
    assert_select "[role='listbox'] [role='option'][data-disabled][data-value='cet']", text: /CET/
    assert_select "table td code", text: "placeholder"
  end

  test "sidebar docs page renders preview usage and api" do
    get components_sidebar_path

    assert_response :success
    assert_select "h1", text: "Sidebar"
    assert_select "section#example-sidebar_basic [data-slot='sidebar'].bg-sidebar"
    assert_select "section#example-sidebar_basic [data-slot='sidebar-menu-button'][data-active='true']"
    assert_select "a[href='#{blocks_sidebar_01_path}']"
    assert_select "code", text: "ui_sidebar_provider"
    assert_select "table td code", text: "ui_sidebar_menu_button"
  end

  test "showcase links every component docs page" do
    get root_path

    assert_response :success
    assert_select "nav[aria-label='Component documentation']"

    [
      [ "Accordion", components_accordion_path ],
      [ "Alert", components_alert_path ],
      [ "Alert Dialog", components_alert_dialog_path ],
      [ "Avatar", components_avatar_path ],
      [ "Badge", components_badge_path ],
      [ "Breadcrumb", components_breadcrumb_path ],
      [ "Button", components_button_path ],
      [ "Card", components_card_path ],
      [ "Checkbox", components_checkbox_path ],
      [ "Dialog", components_dialog_path ],
      [ "Dropdown Menu", components_dropdown_menu_path ],
      [ "Icon", components_icon_path ],
      [ "Input", components_input_path ],
      [ "Label", components_label_path ],
      [ "Pagination", components_pagination_path ],
      [ "Popover", components_popover_path ],
      [ "Progress", components_progress_path ],
      [ "Radio Group", components_radio_group_path ],
      [ "Scroll Area", components_scroll_area_path ],
      [ "Select", components_select_path ],
      [ "Separator", components_separator_path ],
      [ "Sheet", components_sheet_path ],
      [ "Skeleton", components_skeleton_path ],
      [ "Switch", components_switch_path ],
      [ "Table", components_table_path ],
      [ "Tabs", components_tabs_path ],
      [ "Textarea", components_textarea_path ],
      [ "Tooltip", components_tooltip_path ]
    ].each do |label, path|
      assert_select "a[href='#{path}']", text: /#{Regexp.escape(label)}/
    end
  end

  test "long code examples are collapsible and keep copy controls" do
    get components_scroll_area_path

    assert_select "section#example-scroll_area_horizontal [data-controller~='code-block']"
    assert_select "section#example-scroll_area_horizontal [data-code-block-expanded-value='false']"
    assert_select "section#example-scroll_area_horizontal [data-code-block-target='collapsed'][data-slot='scroll-area']"
    assert_select "section#example-scroll_area_horizontal [data-code-block-target='collapsed'] [data-orientation='horizontal']"
    assert_select "section#example-scroll_area_horizontal [data-code-block-target='collapsed'] [data-orientation='vertical']", count: 0
    assert_select "section#example-scroll_area_horizontal [data-action='code-block#toggle']", text: "Expandir"
    assert_select "section#example-scroll_area_horizontal [data-action='clipboard#copy']", text: "Copiar"
    assert_select "section#example-scroll_area_horizontal [data-controller~='code-block']" do |blocks|
      assert_includes blocks.first["data-clipboard-source-value"], "Vladimir Malyavko"
    end
  end
end
