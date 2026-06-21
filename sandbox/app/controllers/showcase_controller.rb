# frozen_string_literal: true

# Serves the documentation landing page (the root "/").
class ShowcaseController < ApplicationController
  layout "home"

  # Componentes em destaque na home: cada item reaproveita um partial de exemplo
  # em app/views/components/examples/, exibindo preview ao vivo + código.
  SHOWCASE_EXAMPLES = [
    { name: "with_icon", title: "Botão",
      description: "Componha um ui_icon dentro do bloco; o botão dimensiona o SVG automaticamente." },
    { name: "card_default", title: "Card",
      description: "Uma superfície com cabeçalho, conteúdo e rodapé para agrupar ações relacionadas." },
    { name: "input_with_label", title: "Formulário",
      description: "Controles de formulário acessíveis, ligados por label e id." },
    { name: "alert_default", title: "Alerta",
      description: "Destaque uma mensagem importante com semântica de alerta." }
  ].freeze

  def index
    @showcase = SHOWCASE_EXAMPLES
  end
end
