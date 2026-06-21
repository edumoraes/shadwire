# frozen_string_literal: true

# Serves the component documentation pages of the sandbox.
class ComponentsController < ApplicationController
  # Catálogo e páginas de documentação compartilham o mesmo shell de navegação
  # (header e footer) definido pelo layout "home".
  layout "home"

  BUTTON_EXAMPLES = [
    { name: "default", title: "Padrão",
      description: "A variante padrão, usada para a ação primária da tela." },
    { name: "secondary", title: "Secundário",
      description: "Uma alternativa de menor ênfase para ações secundárias." },
    { name: "destructive", title: "Destrutivo",
      description: "Para ações destrutivas, como excluir um registro." },
    { name: "outline", title: "Contorno",
      description: "Apenas borda, sem preenchimento — boa para ações neutras." },
    { name: "ghost", title: "Ghost",
      description: "Sem fundo nem borda até o hover." },
    { name: "link", title: "Link",
      description: "Aparência de link de texto, mantendo a semântica de botão." },
    { name: "icon", title: "Ícone",
      description: "Botão quadrado só com ícone (size: :icon). Informe label: no ícone para leitores de tela." },
    { name: "with_icon", title: "Com ícone",
      description: "Componha ui_icon dentro do bloco; o botão dimensiona o SVG automaticamente." },
    { name: "sizes", title: "Tamanhos",
      description: "Os tamanhos :sm, :default e :lg lado a lado." },
    { name: "loading", title: "Carregando",
      description: "Estado de carregamento composto com um ícone giratório e disabled." },
    { name: "disabled", title: "Desabilitado",
      description: "Passe disabled: true como atributo HTML." },
    { name: "as_link", title: "Como link",
      description: "Renderize como <a> com tag: :a, mantendo o visual de botão." }
  ].freeze

  USAGE_HELPER = <<~ERB
    <%= ui_button { "Salvar" } %>
    <%= ui_button(variant: :outline, size: :sm) { "Cancelar" } %>
  ERB

  USAGE_COMPONENT = <<~ERB
    <%= render Ui::ButtonComponent.new(variant: :destructive) do %>
      Excluir
    <% end %>
  ERB

  BADGE_EXAMPLES = [
    { name: "badge_variants", title: "Variantes",
      description: "Use variantes para indicar prioridade, estado ou categorias." }
  ].freeze

  BADGE_USAGE_HELPER = <<~ERB
    <%= ui_badge { "Badge" } %>
    <%= ui_badge(variant: :secondary) { "Secondary" } %>
  ERB

  BADGE_USAGE_COMPONENT = <<~ERB
    <%= render Ui::BadgeComponent.new(variant: :outline) do %>
      Outline
    <% end %>
  ERB

  CARD_EXAMPLES = [
    { name: "card_default", title: "Padrão",
      description: "Componha header, title, description, content e footer dentro do card." }
  ].freeze

  CARD_USAGE_HELPER = <<~ERB
    <%= ui_card do %>
      <%= ui_card_header do %>
        <%= ui_card_title { "Criar projeto" } %>
        <%= ui_card_description { "Configure o novo workspace." } %>
      <% end %>
      <%= ui_card_content { "Conteúdo do card." } %>
    <% end %>
  ERB

  CARD_USAGE_COMPONENT = <<~ERB
    <%= render Ui::CardComponent.new do %>
      <%= render Ui::Card::HeaderComponent.new do %>
        <%= render Ui::Card::TitleComponent.new do %>
          Criar projeto
        <% end %>
      <% end %>
    <% end %>
  ERB

  CARD_COMPOSITION = <<~TEXT
    Card
    |-- Card::Header
    |   |-- Card::Title
    |   `-- Card::Description
    |-- Card::Content
    `-- Card::Footer
  TEXT

  ALERT_EXAMPLES = [
    { name: "alert_default", title: "Padrão",
      description: "Mensagem importante com role=\"alert\" por padrão." },
    { name: "alert_destructive", title: "Destrutivo",
      description: "Use para erros ou avisos de alta severidade." }
  ].freeze

  ALERT_USAGE_HELPER = <<~ERB
    <%= ui_alert do %>
      Heads up! Você pode adicionar componentes ao seu app.
    <% end %>
  ERB

  ALERT_USAGE_COMPONENT = <<~ERB
    <%= render Ui::AlertComponent.new(variant: :destructive) do %>
      Erro ao salvar alterações.
    <% end %>
  ERB

  SEPARATOR_EXAMPLES = [
    { name: "separator_default", title: "Orientações e decorativo",
      description: "Separadores semânticos expõem aria-orientation; decorativos ficam ocultos da tecnologia assistiva." }
  ].freeze

  SEPARATOR_USAGE_HELPER = <<~ERB
    <%= ui_separator %>
    <%= ui_separator(orientation: :vertical, class: "h-5") %>
  ERB

  SEPARATOR_USAGE_COMPONENT = <<~ERB
    <%= render Ui::SeparatorComponent.new(decorative: true) %>
  ERB

  AVATAR_EXAMPLES = [
    { name: "avatar_default", title: "Imagem, fallback e rótulo",
      description: "Renderize uma imagem com fallback ou um fallback isolado para usuários sem foto." }
  ].freeze

  AVATAR_USAGE_HELPER = <<~ERB
    <%= ui_avatar(src: "/avatar.png", alt: "Eduardo Moraes", fallback: "EM") %>
  ERB

  AVATAR_USAGE_COMPONENT = <<~ERB
    <%= render Ui::AvatarComponent.new(fallback: "EM", aria: { label: "Eduardo Moraes" }) %>
  ERB

  ICON_EXAMPLES = [
    { name: "icon_default", title: "Decorativo e rotulado",
      description: "Ícones são decorativos por padrão; passe label: quando o ícone carregar significado." }
  ].freeze

  ICON_USAGE_HELPER = <<~ERB
    <%= ui_icon("download") %>
    <%= ui_icon("bell", label: "Notificações") %>
  ERB

  ICON_USAGE_COMPONENT = <<~ERB
    <%= render Ui::IconComponent.new("download", size: :lg) %>
  ERB

  ACCORDION_EXAMPLES = [
    { name: "accordion_basic", title: "Basic",
      description: "Um accordion simples que exibe um item por vez. O primeiro item começa aberto." },
    { name: "accordion_multiple", title: "Multiple",
      description: "Use multiple: true para permitir que vários itens fiquem abertos ao mesmo tempo." },
    { name: "accordion_disabled", title: "Disabled",
      description: "Use disabled: true no item para bloquear um painel específico." },
    { name: "accordion_borders", title: "Borders",
      description: "Adicione border no accordion para destacar o contorno do grupo." },
    { name: "accordion_card", title: "Card",
      description: "Componha o Accordion dentro de Card quando ele fizer parte de uma superfície maior." }
  ].freeze

  ACCORDION_USAGE_HELPER = <<~ERB
    <%= ui_accordion(default_value: :item_1) do %>
      <%= ui_accordion_item(value: :item_1) do %>
        <%= ui_accordion_header do %>
          <%= ui_accordion_trigger { "É acessível?" } %>
        <% end %>
        <%= ui_accordion_content do %>
          Sim. Ele segue o padrão WAI-ARIA para accordions.
        <% end %>
      <% end %>
    <% end %>
  ERB

  ACCORDION_USAGE_COMPONENT = <<~ERB
    <%= render Ui::AccordionComponent.new(default_value: :item_1) do %>
      <%= render Ui::Accordion::ItemComponent.new(value: :item_1) do %>
        <%= render Ui::Accordion::HeaderComponent.new do %>
          <%= render Ui::Accordion::TriggerComponent.new do %>
            É acessível?
          <% end %>
        <% end %>
        <%= render Ui::Accordion::ContentComponent.new do %>
          Sim. Ele segue o padrão WAI-ARIA para accordions.
        <% end %>
      <% end %>
    <% end %>
  ERB

  ACCORDION_COMPOSITION = <<~ERB
    <%= ui_accordion do %>
      <%= ui_accordion_item do %>
        <%= ui_accordion_header do %>
          <%= ui_accordion_trigger { "Título" } %>
        <% end %>
        <%= ui_accordion_content { "Conteúdo" } %>
      <% end %>
    <% end %>
  ERB

  SCROLL_AREA_EXAMPLES = [
    { name: "scroll_area_vertical", title: "Preview",
      description: "A vertical Scroll Area keeps native scrolling while matching Shadwire styles." },
    { name: "scroll_area_horizontal", title: "Horizontal",
      description: "Use a horizontal scrollbar for galleries and wide content." },
    { name: "scroll_area_rtl", title: "RTL",
      description: "Use dir: \"rtl\" when rendering right-to-left content." }
  ].freeze

  SCROLL_AREA_INSTALL = <<~SH
    bin/sync_registry scroll-area
  SH

  SCROLL_AREA_USAGE_HELPER = <<~ERB
    <%= ui_scroll_area(class: "h-[200px] w-[350px] rounded-md border p-4") do %>
      Your scrollable content here.
    <% end %>
  ERB

  SCROLL_AREA_USAGE_COMPONENT = <<~ERB
    <%= render Ui::ScrollAreaComponent.new(class: "h-[200px] w-[350px] rounded-md border p-4") do %>
      Your scrollable content here.
    <% end %>
  ERB

  SCROLL_AREA_COMPOSITION = <<~TEXT
    ScrollArea
    `-- ScrollBar
  TEXT

  SCROLL_AREA_USAGE_HORIZONTAL = <<~ERB
    <%= ui_scroll_area(scrollbars: [ :horizontal ], class: "w-96 rounded-md border whitespace-nowrap") do %>
      <div class="flex w-max gap-4 p-4">...</div>
    <% end %>
  ERB

  SCROLL_AREA_RTL = <<~ERB
    <%= ui_scroll_area(dir: "rtl", class: "h-[200px] w-[350px] rounded-md border p-4") do %>
      المحتوى القابل للتمرير هنا.
    <% end %>
  ERB

  INPUT_EXAMPLES = [
    { name: "input_default", title: "Padrão",
      description: "Um campo de texto com o visual shadcn. Atributos HTML livres passam direto para o <input>." },
    { name: "input_with_label", title: "Com label",
      description: "Combine com ui_label usando for:/id: para associar o rótulo ao campo." },
    { name: "input_disabled", title: "Desabilitado",
      description: "Passe disabled: true como atributo HTML." },
    { name: "input_file", title: "Arquivo",
      description: "type: :file estiliza o seletor de arquivo nativo." },
    { name: "input_form", title: "Com form_with",
      description: "Use form.field_name/form.field_id para integrar com formulários Rails." }
  ].freeze

  INPUT_USAGE_HELPER = <<~ERB
    <%= ui_input(type: :email, placeholder: "voce@exemplo.com") %>
  ERB

  INPUT_USAGE_COMPONENT = <<~ERB
    <%= render Ui::InputComponent.new(type: :email, name: "user[email]") %>
  ERB

  LABEL_EXAMPLES = [
    { name: "label_default", title: "Padrão",
      description: "Associe o rótulo ao campo com for: apontando para o id do controle." },
    { name: "label_disabled", title: "Grupo desabilitado",
      description: "Dentro de um grupo com data-disabled, o rótulo reduz a opacidade automaticamente." }
  ].freeze

  LABEL_USAGE_HELPER = <<~ERB
    <%= ui_label(for: "email") { "Email" } %>
    <%= ui_input(type: :email, id: "email") %>
  ERB

  LABEL_USAGE_COMPONENT = <<~ERB
    <%= render Ui::LabelComponent.new(for: "email") do %>
      Email
    <% end %>
  ERB

  TEXTAREA_EXAMPLES = [
    { name: "textarea_default", title: "Padrão",
      description: "Uma área de texto com o visual shadcn; cresce com o conteúdo via field-sizing." },
    { name: "textarea_with_label", title: "Com label",
      description: "Combine com ui_label para formulários acessíveis." },
    { name: "textarea_disabled", title: "Desabilitado",
      description: "Passe disabled: true como atributo HTML." }
  ].freeze

  TEXTAREA_USAGE_HELPER = <<~ERB
    <%= ui_textarea(name: "post[body]", placeholder: "Digite sua mensagem") %>
  ERB

  TEXTAREA_USAGE_COMPONENT = <<~ERB
    <%= render Ui::TextareaComponent.new(placeholder: "Digite sua mensagem") do %>
      Conteúdo inicial
    <% end %>
  ERB

  CHECKBOX_EXAMPLES = [
    { name: "checkbox_default", title: "Padrão",
      description: "Um checkbox nativo estilizado, associado a um ui_label via for:/id:." },
    { name: "checkbox_checked", title: "Marcado",
      description: "Use checked: true para renderizar marcado; combine com textos auxiliares." },
    { name: "checkbox_disabled", title: "Desabilitado",
      description: "disabled: true desabilita o input nativo." },
    { name: "checkbox_form", title: "Com form_with",
      description: "Use form.field_name/form.field_id. Diferente de form.check_box, não há input hidden — trate a ausência do parâmetro como desmarcado." }
  ].freeze

  CHECKBOX_USAGE_HELPER = <<~ERB
    <%= ui_checkbox(id: "terms") %>
    <%= ui_label(for: "terms") { "Aceitar termos" } %>
  ERB

  CHECKBOX_USAGE_COMPONENT = <<~ERB
    <%= render Ui::CheckboxComponent.new(name: "user[terms]", checked: true) %>
  ERB

  def button
    @examples = BUTTON_EXAMPLES
    @usage_helper = USAGE_HELPER
    @usage_component = USAGE_COMPONENT
  end

  def badge
    @examples = BADGE_EXAMPLES
    @usage_helper = BADGE_USAGE_HELPER
    @usage_component = BADGE_USAGE_COMPONENT
  end

  def card
    @examples = CARD_EXAMPLES
    @usage_helper = CARD_USAGE_HELPER
    @usage_component = CARD_USAGE_COMPONENT
    @composition = CARD_COMPOSITION
  end

  def alert
    @examples = ALERT_EXAMPLES
    @usage_helper = ALERT_USAGE_HELPER
    @usage_component = ALERT_USAGE_COMPONENT
  end

  def separator
    @examples = SEPARATOR_EXAMPLES
    @usage_helper = SEPARATOR_USAGE_HELPER
    @usage_component = SEPARATOR_USAGE_COMPONENT
  end

  def avatar
    @examples = AVATAR_EXAMPLES
    @usage_helper = AVATAR_USAGE_HELPER
    @usage_component = AVATAR_USAGE_COMPONENT
  end

  def icon
    @examples = ICON_EXAMPLES
    @usage_helper = ICON_USAGE_HELPER
    @usage_component = ICON_USAGE_COMPONENT
  end

  RADIO_GROUP_EXAMPLES = [
    { name: "radio_group_default", title: "Padrão",
      description: "Radios nativos compartilhando o mesmo name: — a navegação por setas vem do navegador." },
    { name: "radio_group_disabled", title: "Item desabilitado",
      description: "disabled: true desabilita um item específico sem afetar o grupo." },
    { name: "radio_group_form", title: "Com form_with",
      description: "Use form.field_name para o name compartilhado e form.field_id(attr, valor) para cada id." }
  ].freeze

  RADIO_GROUP_USAGE_HELPER = <<~ERB
    <%= ui_radio_group(aria: { label: "Plano" }) do %>
      <div class="flex items-center gap-2">
        <%= ui_radio_group_item(name: "plan", value: "free", id: "plan-free", checked: true) %>
        <%= ui_label(for: "plan-free") { "Gratuito" } %>
      </div>
    <% end %>
  ERB

  RADIO_GROUP_USAGE_COMPONENT = <<~ERB
    <%= render Ui::RadioGroupComponent.new do %>
      <%= render Ui::RadioGroup::ItemComponent.new(name: "plan", value: "free") %>
    <% end %>
  ERB

  RADIO_GROUP_COMPOSITION = <<~TEXT
    RadioGroup
    `-- RadioGroup::Item (um por opção, mesmo name:)
  TEXT

  def checkbox
    @examples = CHECKBOX_EXAMPLES
    @usage_helper = CHECKBOX_USAGE_HELPER
    @usage_component = CHECKBOX_USAGE_COMPONENT
  end

  SWITCH_EXAMPLES = [
    { name: "switch_default", title: "Padrão",
      description: "Um checkbox nativo com role=\"switch\" — semântica de alternância para leitores de tela." },
    { name: "switch_checked", title: "Ligado",
      description: "Use checked: true para iniciar ligado; combine com textos auxiliares." },
    { name: "switch_disabled", title: "Desabilitado",
      description: "disabled: true desabilita o input nativo." },
    { name: "switch_form", title: "Com form_with",
      description: "Use form.field_name/form.field_id. Sem input hidden — trate a ausência do parâmetro como desligado." }
  ].freeze

  SWITCH_USAGE_HELPER = <<~ERB
    <%= ui_switch(id: "airplane-mode") %>
    <%= ui_label(for: "airplane-mode") { "Modo avião" } %>
  ERB

  SWITCH_USAGE_COMPONENT = <<~ERB
    <%= render Ui::SwitchComponent.new(name: "settings[airplane]", checked: true) %>
  ERB

  def radio_group
    @examples = RADIO_GROUP_EXAMPLES
    @usage_helper = RADIO_GROUP_USAGE_HELPER
    @usage_component = RADIO_GROUP_USAGE_COMPONENT
    @composition = RADIO_GROUP_COMPOSITION
  end

  SKELETON_EXAMPLES = [
    { name: "skeleton_default", title: "Padrão",
      description: "Combine formas para esboçar o conteúdo que está carregando." },
    { name: "skeleton_card", title: "Card",
      description: "Um placeholder para cards de mídia com linhas de texto." }
  ].freeze

  SKELETON_USAGE_HELPER = <<~ERB
    <%= ui_skeleton(class: "h-4 w-48") %>
  ERB

  SKELETON_USAGE_COMPONENT = <<~ERB
    <%= render Ui::SkeletonComponent.new(class: "size-10 rounded-full") %>
  ERB

  def switch
    @examples = SWITCH_EXAMPLES
    @usage_helper = SWITCH_USAGE_HELPER
    @usage_component = SWITCH_USAGE_COMPONENT
  end

  PROGRESS_EXAMPLES = [
    { name: "progress_default", title: "Padrão",
      description: "O valor é renderizado no servidor e exposto via aria-valuenow." },
    { name: "progress_values", title: "Valores",
      description: "Barras em diferentes estágios de conclusão." },
    { name: "progress_custom", title: "Máximo e altura customizados",
      description: "Use max: para escalas próprias e classes para ajustar a altura." }
  ].freeze

  PROGRESS_USAGE_HELPER = <<~ERB
    <%= ui_progress(value: 60, aria: { label: "Progresso do envio" }) %>
  ERB

  PROGRESS_USAGE_COMPONENT = <<~ERB
    <%= render Ui::ProgressComponent.new(value: 8, max: 12) %>
  ERB

  def skeleton
    @examples = SKELETON_EXAMPLES
    @usage_helper = SKELETON_USAGE_HELPER
    @usage_component = SKELETON_USAGE_COMPONENT
  end

  TABLE_EXAMPLES = [
    { name: "table_demo", title: "Faturas",
      description: "A anatomia completa: caption, header, body e footer com células alinhadas." },
    { name: "table_selected", title: "Linha selecionada",
      description: "Use data: { state: \"selected\" } para destacar uma linha." }
  ].freeze

  TABLE_USAGE_HELPER = <<~ERB
    <%= ui_table do %>
      <%= ui_table_header do %>
        <%= ui_table_row do %>
          <%= ui_table_head(scope: "col") { "Fatura" } %>
        <% end %>
      <% end %>
      <%= ui_table_body do %>
        <%= ui_table_row do %>
          <%= ui_table_cell { "INV001" } %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  TABLE_USAGE_COMPONENT = <<~ERB
    <%= render Ui::TableComponent.new do %>
      <%= render Ui::Table::BodyComponent.new do %>
        <%= render Ui::Table::RowComponent.new do %>
          <%= render Ui::Table::CellComponent.new do %>
            INV001
          <% end %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  TABLE_COMPOSITION = <<~TEXT
    Table (container com overflow + <table>)
    |-- Table::Caption
    |-- Table::Header
    |   `-- Table::Row > Table::Head (th)
    |-- Table::Body
    |   `-- Table::Row > Table::Cell (td)
    `-- Table::Footer
        `-- Table::Row > Table::Cell
  TEXT

  def progress
    @examples = PROGRESS_EXAMPLES
    @usage_helper = PROGRESS_USAGE_HELPER
    @usage_component = PROGRESS_USAGE_COMPONENT
  end

  BREADCRUMB_EXAMPLES = [
    { name: "breadcrumb_default", title: "Padrão",
      description: "Trilha com links e a página atual marcada com aria-current=\"page\"." },
    { name: "breadcrumb_ellipsis", title: "Recolhido",
      description: "Use ui_breadcrumb_ellipsis para trilhas longas." },
    { name: "breadcrumb_custom_separator", title: "Separador custom",
      description: "Passe um bloco ao separador para trocar o chevron padrão." }
  ].freeze

  BREADCRUMB_USAGE_HELPER = <<~ERB
    <%= ui_breadcrumb do %>
      <%= ui_breadcrumb_list do %>
        <%= ui_breadcrumb_item do %>
          <%= ui_breadcrumb_link(href: "/") { "Início" } %>
        <% end %>
        <%= ui_breadcrumb_separator %>
        <%= ui_breadcrumb_item do %>
          <%= ui_breadcrumb_page { "Página atual" } %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  BREADCRUMB_USAGE_COMPONENT = <<~ERB
    <%= render Ui::BreadcrumbComponent.new do %>
      <%= render Ui::Breadcrumb::ListComponent.new do %>
        <%= render Ui::Breadcrumb::ItemComponent.new do %>
          <%= render Ui::Breadcrumb::PageComponent.new do %>
            Página atual
          <% end %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  BREADCRUMB_COMPOSITION = <<~TEXT
    Breadcrumb (nav aria-label="breadcrumb")
    `-- Breadcrumb::List (ol)
        |-- Breadcrumb::Item (li) > Breadcrumb::Link (a) ou Breadcrumb::Page (span)
        |-- Breadcrumb::Separator (li decorativo)
        `-- Breadcrumb::Ellipsis (span decorativo)
  TEXT

  def table
    @examples = TABLE_EXAMPLES
    @usage_helper = TABLE_USAGE_HELPER
    @usage_component = TABLE_USAGE_COMPONENT
    @composition = TABLE_COMPOSITION
  end

  PAGINATION_EXAMPLES = [
    { name: "pagination_default", title: "Padrão",
      description: "Anterior/Próxima com rótulos acessíveis, página ativa com aria-current=\"page\" e ellipsis decorativo." }
  ].freeze

  PAGINATION_USAGE_HELPER = <<~ERB
    <%= ui_pagination do %>
      <%= ui_pagination_content do %>
        <%= ui_pagination_item do %>
          <%= ui_pagination_previous(href: "?page=1") %>
        <% end %>
        <%= ui_pagination_item do %>
          <%= ui_pagination_link(href: "?page=2", active: true) { "2" } %>
        <% end %>
        <%= ui_pagination_item do %>
          <%= ui_pagination_next(href: "?page=3") %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  PAGINATION_USAGE_COMPONENT = <<~ERB
    <%= render Ui::Pagination::LinkComponent.new(href: "?page=2", active: true) do %>
      2
    <% end %>
  ERB

  PAGINATION_COMPOSITION = <<~TEXT
    Pagination (nav role="navigation" aria-label="pagination")
    `-- Pagination::Content (ul)
        |-- Pagination::Item (li) > Pagination::Previous / Pagination::Link / Pagination::Next
        `-- Pagination::Item (li) > Pagination::Ellipsis
  TEXT

  def breadcrumb
    @examples = BREADCRUMB_EXAMPLES
    @usage_helper = BREADCRUMB_USAGE_HELPER
    @usage_component = BREADCRUMB_USAGE_COMPONENT
    @composition = BREADCRUMB_COMPOSITION
  end

  TABS_EXAMPLES = [
    { name: "tabs_default", title: "Padrão",
      description: "Dois painéis com cards; o painel ativo é controlado pelo controller ui-tabs." },
    { name: "tabs_disabled", title: "Trigger desabilitado",
      description: "disabled: true tira o trigger do fluxo de teclado e da ativação." }
  ].freeze

  TABS_USAGE_HELPER = <<~ERB
    <%= ui_tabs(default_value: :account) do %>
      <%= ui_tabs_list do %>
        <%= ui_tabs_trigger(value: :account) { "Conta" } %>
        <%= ui_tabs_trigger(value: :password) { "Senha" } %>
      <% end %>
      <%= ui_tabs_content(value: :account) { "Painel da conta" } %>
      <%= ui_tabs_content(value: :password) { "Painel de senha" } %>
    <% end %>
  ERB

  TABS_USAGE_COMPONENT = <<~ERB
    <%= render Ui::TabsComponent.new(default_value: :account) do %>
      <%= render Ui::Tabs::ListComponent.new do %>
        <%= render Ui::Tabs::TriggerComponent.new(value: :account) do %>
          Conta
        <% end %>
      <% end %>
      <%= render Ui::Tabs::ContentComponent.new(value: :account) do %>
        Painel da conta
      <% end %>
    <% end %>
  ERB

  TABS_COMPOSITION = <<~TEXT
    Tabs (data-controller="ui-tabs")
    |-- Tabs::List (role="tablist")
    |   `-- Tabs::Trigger (role="tab", um por painel)
    `-- Tabs::Content (role="tabpanel", um por value)
  TEXT

  def pagination
    @examples = PAGINATION_EXAMPLES
    @usage_helper = PAGINATION_USAGE_HELPER
    @usage_component = PAGINATION_USAGE_COMPONENT
    @composition = PAGINATION_COMPOSITION
  end

  DIALOG_EXAMPLES = [
    { name: "dialog_default", title: "Padrão",
      description: "Formulário de perfil em um <dialog> nativo: focus trap, Esc e restauração de foco vêm do navegador." },
    { name: "dialog_no_backdrop_close", title: "Sem fechar pelo backdrop",
      description: "close_on_backdrop: false ignora cliques fora do painel." },
    { name: "dialog_custom_close", title: "Footer custom",
      description: "show_close_button: false remove o X; componha seus próprios botões com ui_dialog_close." }
  ].freeze

  DIALOG_USAGE_HELPER = <<~ERB
    <%= ui_dialog do %>
      <%= ui_dialog_trigger(variant: :outline) { "Abrir" } %>
      <%= ui_dialog_content do %>
        <%= ui_dialog_header do %>
          <%= ui_dialog_title { "Título" } %>
          <%= ui_dialog_description { "Descrição do diálogo." } %>
        <% end %>
        <%= ui_dialog_footer do %>
          <%= ui_dialog_close { "Cancelar" } %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  DIALOG_USAGE_COMPONENT = <<~ERB
    <%= render Ui::DialogComponent.new do %>
      <%= render Ui::Dialog::TriggerComponent.new do %>
        Abrir
      <% end %>
      <%= render Ui::Dialog::ContentComponent.new do %>
        <%= render Ui::Dialog::TitleComponent.new do %>
          Título
        <% end %>
      <% end %>
    <% end %>
  ERB

  DIALOG_COMPOSITION = <<~TEXT
    Dialog (data-controller="ui-dialog")
    |-- Dialog::Trigger (Button que chama showModal)
    `-- Dialog::Content (<dialog> nativo)
        |-- Dialog::Header > Dialog::Title + Dialog::Description
        `-- Dialog::Footer > Dialog::Close (Button)
  TEXT

  def tabs
    @examples = TABS_EXAMPLES
    @usage_helper = TABS_USAGE_HELPER
    @usage_component = TABS_USAGE_COMPONENT
    @composition = TABS_COMPOSITION
  end

  ALERT_DIALOG_EXAMPLES = [
    { name: "alert_dialog_default", title: "Confirmação de exclusão",
      description: "Backdrop e Esc não fecham — a pessoa precisa escolher Cancelar ou Continuar." }
  ].freeze

  ALERT_DIALOG_USAGE_HELPER = <<~ERB
    <%= ui_alert_dialog do %>
      <%= ui_alert_dialog_trigger(variant: :destructive) { "Excluir" } %>
      <%= ui_alert_dialog_content do %>
        <%= ui_alert_dialog_header do %>
          <%= ui_alert_dialog_title { "Tem certeza?" } %>
          <%= ui_alert_dialog_description { "Esta ação não pode ser desfeita." } %>
        <% end %>
        <%= ui_alert_dialog_footer do %>
          <%= ui_alert_dialog_cancel { "Cancelar" } %>
          <%= ui_alert_dialog_action { "Continuar" } %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  ALERT_DIALOG_USAGE_COMPONENT = <<~ERB
    <%= render Ui::AlertDialogComponent.new do %>
      <%= render Ui::AlertDialog::TriggerComponent.new do %>
        Excluir
      <% end %>
      <%= render Ui::AlertDialog::ContentComponent.new do %>
        <%= render Ui::AlertDialog::TitleComponent.new do %>
          Tem certeza?
        <% end %>
      <% end %>
    <% end %>
  ERB

  ALERT_DIALOG_COMPOSITION = <<~TEXT
    AlertDialog (ui-dialog com backdrop/Esc desativados)
    |-- AlertDialog::Trigger (Button)
    `-- AlertDialog::Content (<dialog role="alertdialog">, sem X)
        |-- AlertDialog::Header > AlertDialog::Title + AlertDialog::Description
        `-- AlertDialog::Footer > AlertDialog::Cancel + AlertDialog::Action
  TEXT

  def dialog
    @examples = DIALOG_EXAMPLES
    @usage_helper = DIALOG_USAGE_HELPER
    @usage_component = DIALOG_USAGE_COMPONENT
    @composition = DIALOG_COMPOSITION
  end

  SHEET_EXAMPLES = [
    { name: "sheet_default", title: "Padrão",
      description: "Um painel que desliza da direita, com formulário e footer." },
    { name: "sheet_sides", title: "Os quatro lados",
      description: "side: :right, :left, :top ou :bottom controla a borda de origem e a animação." }
  ].freeze

  SHEET_USAGE_HELPER = <<~ERB
    <%= ui_sheet do %>
      <%= ui_sheet_trigger(variant: :outline) { "Abrir" } %>
      <%= ui_sheet_content(side: :right) do %>
        <%= ui_sheet_header do %>
          <%= ui_sheet_title { "Título" } %>
          <%= ui_sheet_description { "Descrição do painel." } %>
        <% end %>
        <%= ui_sheet_footer do %>
          <%= ui_sheet_close { "Fechar" } %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  SHEET_USAGE_COMPONENT = <<~ERB
    <%= render Ui::SheetComponent.new do %>
      <%= render Ui::Sheet::TriggerComponent.new do %>
        Abrir
      <% end %>
      <%= render Ui::Sheet::ContentComponent.new(side: :left) do %>
        <%= render Ui::Sheet::TitleComponent.new do %>
          Título
        <% end %>
      <% end %>
    <% end %>
  ERB

  SHEET_COMPOSITION = <<~TEXT
    Sheet (ui-dialog)
    |-- Sheet::Trigger (Button)
    `-- Sheet::Content (<dialog> ancorado em uma borda, side:)
        |-- Sheet::Header > Sheet::Title + Sheet::Description
        `-- Sheet::Footer > Sheet::Close (Button)
  TEXT

  def alert_dialog
    @examples = ALERT_DIALOG_EXAMPLES
    @usage_helper = ALERT_DIALOG_USAGE_HELPER
    @usage_component = ALERT_DIALOG_USAGE_COMPONENT
    @composition = ALERT_DIALOG_COMPOSITION
  end

  def sheet
    @examples = SHEET_EXAMPLES
    @usage_helper = SHEET_USAGE_HELPER
    @usage_component = SHEET_USAGE_COMPONENT
    @composition = SHEET_COMPOSITION
  end

  TOOLTIP_EXAMPLES = [
    { name: "tooltip_default", title: "Padrão",
      description: "Abre no hover e no foco depois de um pequeno atraso; Esc fecha sem mover o foco." },
    { name: "tooltip_sides", title: "Lados",
      description: "side: :top, :right, :bottom ou :left posiciona o balão." }
  ].freeze

  TOOLTIP_USAGE_HELPER = <<~ERB
    <%= ui_tooltip do %>
      <%= ui_tooltip_trigger(variant: :outline) { "Passe o mouse" } %>
      <%= ui_tooltip_content { "Adicionar à biblioteca" } %>
    <% end %>
  ERB

  TOOLTIP_USAGE_COMPONENT = <<~ERB
    <%= render Ui::TooltipComponent.new(open_delay: 150) do %>
      <%= render Ui::Tooltip::TriggerComponent.new do %>
        Ajuda
      <% end %>
      <%= render Ui::Tooltip::ContentComponent.new(side: :right) do %>
        Mais detalhes
      <% end %>
    <% end %>
  ERB

  TOOLTIP_COMPOSITION = <<~TEXT
    Tooltip (data-controller="ui-tooltip", relative)
    |-- Tooltip::Trigger (Button descrito via aria-describedby)
    `-- Tooltip::Content (role="tooltip", absolute, side:)
  TEXT

  def tooltip
    @examples = TOOLTIP_EXAMPLES
    @usage_helper = TOOLTIP_USAGE_HELPER
    @usage_component = TOOLTIP_USAGE_COMPONENT
    @composition = TOOLTIP_COMPOSITION
  end

  POPOVER_EXAMPLES = [
    { name: "popover_default", title: "Padrão",
      description: "Painel não-modal: abre no clique, foca o conteúdo e fecha por clique fora ou Esc." },
    { name: "popover_align", title: "Alinhamento",
      description: "align: :start, :center ou :end desloca o painel no eixo cruzado." }
  ].freeze

  POPOVER_USAGE_HELPER = <<~ERB
    <%= ui_popover do %>
      <%= ui_popover_trigger(variant: :outline) { "Abrir" } %>
      <%= ui_popover_content do %>
        Conteúdo do popover.
      <% end %>
    <% end %>
  ERB

  POPOVER_USAGE_COMPONENT = <<~ERB
    <%= render Ui::PopoverComponent.new do %>
      <%= render Ui::Popover::TriggerComponent.new do %>
        Abrir
      <% end %>
      <%= render Ui::Popover::ContentComponent.new(side: :bottom, align: :start) do %>
        Conteúdo
      <% end %>
    <% end %>
  ERB

  POPOVER_COMPOSITION = <<~TEXT
    Popover (data-controller="ui-popover", relative)
    |-- Popover::Trigger (Button, aria-expanded)
    `-- Popover::Content (absolute, side: + align:)
  TEXT

  def popover
    @examples = POPOVER_EXAMPLES
    @usage_helper = POPOVER_USAGE_HELPER
    @usage_component = POPOVER_USAGE_COMPONENT
    @composition = POPOVER_COMPOSITION
  end

  DROPDOWN_MENU_EXAMPLES = [
    { name: "dropdown_menu_default", title: "Padrão",
      description: "Label, grupos, itens com atalhos. Setas navegam, typeahead busca por prefixo, Esc fecha." },
    { name: "dropdown_menu_variants", title: "Inset, links e destrutivo",
      description: "inset: alinha com itens que têm ícone; tag: :a vira link; variant: :destructive destaca ações perigosas." }
  ].freeze

  DROPDOWN_MENU_USAGE_HELPER = <<~ERB
    <%= ui_dropdown_menu do %>
      <%= ui_dropdown_menu_trigger(variant: :outline) { "Abrir" } %>
      <%= ui_dropdown_menu_content do %>
        <%= ui_dropdown_menu_label { "Minha conta" } %>
        <%= ui_dropdown_menu_separator %>
        <%= ui_dropdown_menu_item do %>
          Perfil
          <%= ui_dropdown_menu_shortcut { "⇧⌘P" } %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  DROPDOWN_MENU_USAGE_COMPONENT = <<~ERB
    <%= render Ui::DropdownMenuComponent.new do %>
      <%= render Ui::DropdownMenu::TriggerComponent.new do %>
        Abrir
      <% end %>
      <%= render Ui::DropdownMenu::ContentComponent.new do %>
        <%= render Ui::DropdownMenu::ItemComponent.new(variant: :destructive) do %>
          Excluir
        <% end %>
      <% end %>
    <% end %>
  ERB

  DROPDOWN_MENU_COMPOSITION = <<~TEXT
    DropdownMenu (data-controller="ui-dropdown-menu")
    |-- DropdownMenu::Trigger (Button, aria-haspopup="menu")
    `-- DropdownMenu::Content (role="menu")
        |-- DropdownMenu::Label
        |-- DropdownMenu::Separator
        |-- DropdownMenu::Group
        |   `-- DropdownMenu::Item (button/link) > DropdownMenu::Shortcut
        `-- DropdownMenu::Item (variant: :destructive)

    CheckboxItem, RadioItem e submenus ficam de fora desta versão.
  TEXT

  def dropdown_menu
    @examples = DROPDOWN_MENU_EXAMPLES
    @usage_helper = DROPDOWN_MENU_USAGE_HELPER
    @usage_component = DROPDOWN_MENU_USAGE_COMPONENT
    @composition = DROPDOWN_MENU_COMPOSITION
  end

  SELECT_EXAMPLES = [
    { name: "select_default", title: "Padrão",
      description: "Combobox APG: o foco fica no gatilho, setas/typeahead navegam e a opção ativa usa aria-activedescendant." },
    { name: "select_groups", title: "Grupos",
      description: "Agrupe opções com label e separador; itens podem ser desabilitados." },
    { name: "select_form", title: "Com form_with",
      description: "O valor vai num input hidden (name:). O required nativo não se aplica — valide no servidor." }
  ].freeze

  SELECT_USAGE_HELPER = <<~ERB
    <%= ui_select(name: "fruit", placeholder: "Selecione") do %>
      <%= ui_select_trigger { ui_select_value } %>
      <%= ui_select_content do %>
        <%= ui_select_item(value: "apple") { "Maçã" } %>
        <%= ui_select_item(value: "banana") { "Banana" } %>
      <% end %>
    <% end %>
  ERB

  SELECT_USAGE_COMPONENT = <<~ERB
    <%= render Ui::SelectComponent.new(name: "fruit", value: "banana") do %>
      <%= render Ui::Select::TriggerComponent.new do %>
        <%= render Ui::Select::ValueComponent.new %>
      <% end %>
      <%= render Ui::Select::ContentComponent.new do %>
        <%= render Ui::Select::ItemComponent.new(value: "banana") do %>
          Banana
        <% end %>
      <% end %>
    <% end %>
  ERB

  SELECT_COMPOSITION = <<~TEXT
    Select (data-controller="ui-select", hidden input)
    |-- Select::Trigger (role="combobox") > Select::Value + chevron
    `-- Select::Content (role="listbox")
        `-- Select::Group > Select::Label + Select::Item (role="option")
            Select::Separator
  TEXT

  def select
    @examples = SELECT_EXAMPLES
    @usage_helper = SELECT_USAGE_HELPER
    @usage_component = SELECT_USAGE_COMPONENT
    @composition = SELECT_COMPOSITION
  end

  def input
    @examples = INPUT_EXAMPLES
    @usage_helper = INPUT_USAGE_HELPER
    @usage_component = INPUT_USAGE_COMPONENT
  end

  def label
    @examples = LABEL_EXAMPLES
    @usage_helper = LABEL_USAGE_HELPER
    @usage_component = LABEL_USAGE_COMPONENT
  end

  def textarea
    @examples = TEXTAREA_EXAMPLES
    @usage_helper = TEXTAREA_USAGE_HELPER
    @usage_component = TEXTAREA_USAGE_COMPONENT
  end

  def accordion
    @examples = ACCORDION_EXAMPLES
    @usage_helper = ACCORDION_USAGE_HELPER
    @usage_component = ACCORDION_USAGE_COMPONENT
    @composition = ACCORDION_COMPOSITION
  end

  def scroll_area
    @examples = SCROLL_AREA_EXAMPLES
    @install_command = SCROLL_AREA_INSTALL
    @usage_helper = SCROLL_AREA_USAGE_HELPER
    @usage_component = SCROLL_AREA_USAGE_COMPONENT
    @composition = SCROLL_AREA_COMPOSITION
    @usage_horizontal = SCROLL_AREA_USAGE_HORIZONTAL
    @rtl_usage = SCROLL_AREA_RTL
  end

  SIDEBAR_EXAMPLES = [
    { name: "sidebar_basic", title: "Preview",
      description: "Um sidebar contido (collapsible: :none) com header, grupos e menu. " \
                   "O bloco completo, com colapso e drawer mobile, está em /blocks/sidebar-01." }
  ].freeze

  SIDEBAR_USAGE_HELPER = <<~ERB
    <%= ui_sidebar_provider do %>
      <%= ui_sidebar do %>
        <%= ui_sidebar_content do %>
          <%= ui_sidebar_group do %>
            <%= ui_sidebar_group_label { "Aplicação" } %>
            <%= ui_sidebar_group_content do %>
              <%= ui_sidebar_menu do %>
                <%= ui_sidebar_menu_item do %>
                  <%= ui_sidebar_menu_button(tag: :a, href: "#", is_active: true) { "Início" } %>
                <% end %>
              <% end %>
            <% end %>
          <% end %>
        <% end %>
        <%= ui_sidebar_rail %>
      <% end %>
      <%= ui_sidebar_inset do %>
        <%= ui_sidebar_trigger %>
      <% end %>
    <% end %>
  ERB

  SIDEBAR_USAGE_COMPONENT = <<~ERB
    <%= render Ui::Sidebar::ProviderComponent.new do %>
      <%= render Ui::SidebarComponent.new(collapsible: :icon) do %>
        <%= render Ui::Sidebar::ContentComponent.new do %>
          <%= render Ui::Sidebar::MenuComponent.new do %>
            <%= render Ui::Sidebar::MenuItemComponent.new do %>
              <%= render Ui::Sidebar::MenuButtonComponent.new(tooltip: "Início") { "Início" } %>
            <% end %>
          <% end %>
        <% end %>
      <% end %>
      <%= render Ui::Sidebar::InsetComponent.new do %>
        <%= render Ui::Sidebar::TriggerComponent.new %>
      <% end %>
    <% end %>
  ERB

  SIDEBAR_COMPOSITION = <<~TEXT
    Sidebar::Provider (data-controller="ui-sidebar"; define as larguras via CSS vars)
    |-- Sidebar (peer/group; data-state/collapsible/side/variant/mobile)
    |   |-- Sidebar::Header  (ex.: switcher + Sidebar::Input)
    |   |-- Sidebar::Content
    |   |   `-- Sidebar::Group > Sidebar::GroupLabel + Sidebar::GroupContent
    |   |       `-- Sidebar::Menu > Sidebar::MenuItem
    |   |           > Sidebar::MenuButton (+ MenuAction / MenuBadge / MenuSub)
    |   |-- Sidebar::Footer
    |   `-- Sidebar::Rail
    `-- Sidebar::Inset (Sidebar::Trigger abre/fecha; Cmd/Ctrl+B alterna)
  TEXT

  def sidebar
    @examples = SIDEBAR_EXAMPLES
    @usage_helper = SIDEBAR_USAGE_HELPER
    @usage_component = SIDEBAR_USAGE_COMPONENT
    @composition = SIDEBAR_COMPOSITION
  end
end
