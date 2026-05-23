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

  def button
    @examples = BUTTON_EXAMPLES
    @usage_helper = USAGE_HELPER
    @usage_component = USAGE_COMPONENT
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
