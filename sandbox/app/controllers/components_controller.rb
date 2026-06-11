# frozen_string_literal: true

# Serves the component documentation pages of the sandbox.
class ComponentsController < ApplicationController
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

  def breadcrumb
    @examples = BREADCRUMB_EXAMPLES
    @usage_helper = BREADCRUMB_USAGE_HELPER
    @usage_component = BREADCRUMB_USAGE_COMPONENT
    @composition = BREADCRUMB_COMPOSITION
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
end
