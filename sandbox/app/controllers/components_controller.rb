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
end
