# frozen_string_literal: true

# Spots Portuguese in text that is supposed to be English: the English component
# pages, the example partials they share with nobody, and the code snippets both
# trees show.
#
# Every word below has no English homograph, and most of them are here because
# they leaked: "diretamente", "encapsula", "Atributos HTML livres", "Submenu
# aninhado", "Carregando", "Componentes" all shipped on English pages before
# this list existed. Diacritics catch most of the rest; a bare "e" between two
# words catches the connective that the word list cannot.
module PortugueseText
  DIACRITICS = /[çãõáéíóúâêôà]/i

  WORDS = %w[
    você voce não nao então também são está estão isso isto porque
    uma umas uns para pelo pela pelos pelas com sem aos das dos numa
    seu sua seus suas cada ainda quando onde como mais
    depois antes entre após dentro fora aqui
    diretamente encapsula encapsulam atributos livres renderizada renderizado
    aninhado carregamento carregando destaca linha aceita aceito incluindo
    sempre injeta compartilha entrega anuncia ouve evento indicador decorativo
    itens recolhidos anos sentido inverso lista eixo cruzado largura altura
    emite bloco componentes componente correspondentes visitantes termos
    desabilitado foto cereja alinhado tarefas progresso envio plano dois
    abacaxi salvando direita esquerda topo lado baixar painel conta senha
    projeto mensagem mensagens atualizar nunca compartilhamos escolha
    selecione digite clique criar editar excluir salvar cancelar buscar
    entrar novo arquivo perfil nome inscrever ou gratuito desativados ajuda
    detalhes intervalo duas datas meses certeza tema escuro valores classe
    instalar encontrado nada corpo gerencie quem acesso larguras abre fecha
    alterna nativo chama descrito sucesso
  ].freeze

  # Not inside a URL, an email, a path or a hyphenated word: "example.com" is
  # not Portuguese.
  WORD_PATTERN = /(?<![\p{L}\p{N}_.@\/-])(#{WORDS.join("|")})(?![\p{L}\p{N}_-]|\.\p{L})/i

  # "O controller", "O helper": the article gives the sentence away even when
  # every other word is English.
  ARTICLE = /(?<![\p{L}])O (?:controller|helper|componente)\b/

  # The connective. Not "e.g.", not "e-mail", not a variable in code — prose only.
  CONNECTIVE = /(?<![\p{L}\p{N}_.'-])e(?![\p{L}\p{N}_.'-])/

  module_function

  # The Portuguese found in `text`, as a list of the offending words.
  def hits(text, connective: false)
    found = text.scan(DIACRITICS) + text.scan(WORD_PATTERN).flatten + text.scan(ARTICLE)
    found << "e" if connective && text.match?(CONNECTIVE)
    found.map(&:downcase).uniq
  end

  # The prose of an ERB page: no ERB, no inline code or keys, no markup.
  def prose(template)
    template.gsub(/<%.*?%>/m, " ")
            .gsub(%r{<(code|kbd|pre)\b[^>]*>.*?</\1>}m, " ")
            .gsub(/<[^>]+>/, " ")
            .gsub(%r{https?://\S+}, " ")
            .gsub(/&[a-z]+;/, " ")
  end
end
