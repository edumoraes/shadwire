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

  def button
    @examples = BUTTON_EXAMPLES
    @usage_helper = USAGE_HELPER
    @usage_component = USAGE_COMPONENT
  end
end
