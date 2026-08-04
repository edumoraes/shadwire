# frozen_string_literal: true

# Serves the guide and reference pages of the documentation site. Components and
# blocks have their own controllers.
#
# Pages are plain views; only the ones that need repeated data (command tables,
# token tables) get it from a constant here, so the prose stays in the view.
class DocsController < ApplicationController
  layout "docs"

  # Code samples live in DocsSnippets because an ERB template cannot hold a
  # heredoc containing ERB tags. Every action gets its page's hash.
  before_action { @snippets = DocsSnippets.for(action_name) }

  # The CLI's command surface. Mirrors packages/cli/README.md, which is the
  # reference the CLI itself ships.
  COMMANDS = [
    { name: "init", signature: "shadwire init",
      summary: "Prepara o app: escreve o shadwire.json, instala os arquivos base compartilhados " \
               "(ui_component.rb, shadwire.css) e as gems base, adiciona o shadwire ao grupo " \
               "development, cria o binstub bin/shadwire e insere o @import do Tailwind.",
      flags: %w[--yes --registry --force --json] },
    { name: "add", signature: "bin/shadwire add NOME...",
      summary: "Instala um ou mais componentes com as dependências de registry deles, aplica gems " \
               "e pins de importmap, e registra tudo no shadwire.json.",
      flags: %w[--yes --overwrite --no-deps --registry --json] },
    { name: "list", signature: "bin/shadwire list",
      summary: "Lista todos os componentes do catálogo do registry.",
      flags: %w[--registry --json] },
    { name: "search", signature: "bin/shadwire search CONSULTA",
      summary: "Busca no catálogo por nome, título, descrição e pelo texto de quando usar, " \
               "então termos conceituais como form, modal ou loading funcionam.",
      flags: %w[--registry --json] },
    { name: "info", signature: "bin/shadwire info NOME",
      summary: "Mostra a API completa do componente: helpers, variantes, tamanhos, props, " \
               "arquivos, gems, pins e dependências de registry.",
      flags: %w[--registry --json] },
    { name: "diff", signature: "bin/shadwire diff [NOME...]",
      summary: "Compara os arquivos instalados com o registry e reporta unchanged, modified ou " \
               "missing, com o diff unificado dos modificados. Só leitura.",
      flags: %w[--registry --json --exit-code] },
    { name: "update", signature: "bin/shadwire update [NOME...]",
      summary: "Reaplica a versão do registry dos componentes instalados. Sobrescreve edições " \
               "locais, então rode o diff antes.",
      flags: %w[--yes --overwrite --no-deps --registry --json] },
    { name: "remove", signature: "bin/shadwire remove NOME...",
      summary: "Desinstala componentes apagando só os arquivos exclusivos deles, nunca a base " \
               "compartilhada nem um arquivo que outro componente instalado ainda usa.",
      flags: %w[--yes --registry --json] },
    { name: "status", signature: "bin/shadwire status",
      summary: "Descreve o app inteiro em uma chamada: stack detectada, componentes instalados com " \
               "os helpers que definem, e drift.",
      flags: %w[--registry --json] },
    { name: "version", signature: "bin/shadwire version",
      summary: "Imprime a versão instalada da CLI.",
      flags: [] }
  ].freeze

  # Flags shared by more than one command, documented once.
  FLAGS = [
    { flag: "--cwd DIR", commands: "todos",
      description: "Roda contra outro diretório de aplicação, em vez do diretório atual." },
    { flag: "--registry URL", commands: "todos",
      description: "Lê de outro registry. Aceita https:// e file://, que é como se testa um registry construído localmente." },
    { flag: "--json", commands: "todos, menos version",
      description: "Emite JSON legível por máquina em vez da saída humana. É o que agentes e CI usam." },
    { flag: "--yes, -y", commands: "init, add, update, remove",
      description: "Aplica mudanças de arquivo e de dependência sem perguntar." },
    { flag: "--overwrite", commands: "add, update",
      description: "Sobrescreve arquivos modificados localmente sem perguntar." },
    { flag: "--no-deps", commands: "add, update",
      description: "Pula as dependências transitivas de registry (ligadas por padrão)." },
    { flag: "--force", commands: "init",
      description: "Reescreve um shadwire.json existente e recria o binstub." },
    { flag: "--exit-code", commands: "diff",
      description: "Sai com código não-zero quando existe drift, para travar o CI." }
  ].freeze

  # The shadcn semantic tokens, as installed in vendor/shadwire/shadwire.css.
  TOKENS = [
    { token: "background / foreground", controls: "Fundo da aplicação e texto padrão",
      used_by: "Shell da página, seções, texto padrão" },
    { token: "card / card-foreground", controls: "Superfícies elevadas",
      used_by: "Card, painéis de dashboard e de configurações" },
    { token: "popover / popover-foreground", controls: "Superfícies flutuantes",
      used_by: "Popover, DropdownMenu, ContextMenu, overlays" },
    { token: "primary / primary-foreground", controls: "Ações de alta ênfase, marca",
      used_by: "Button padrão, estados selecionados, badges" },
    { token: "secondary / secondary-foreground", controls: "Ações preenchidas de menor ênfase",
      used_by: "Botões e badges secundários" },
    { token: "muted / muted-foreground", controls: "Superfícies sutis, conteúdo secundário",
      used_by: "Descrições, placeholders, estados vazios, textos de apoio" },
    { token: "accent / accent-foreground", controls: "Superfícies de hover, foco e ativo",
      used_by: "Botões ghost, destaque de menu, linhas sob o cursor" },
    { token: "destructive / destructive-foreground", controls: "Ações destrutivas, erros",
      used_by: "Botões destrutivos, estados inválidos" },
    { token: "border", controls: "Bordas e separadores",
      used_by: "Cards, menus, tabelas, divisores" },
    { token: "input", controls: "Bordas de controles de formulário",
      used_by: "Input, Textarea, Select, controles outline" },
    { token: "ring", controls: "Anéis de foco",
      used_by: "Botões, inputs, checkboxes, menus" },
    { token: "chart-1 … chart-5", controls: "Paleta de gráficos",
      used_by: "Charts e blocks orientados a gráfico" },
    { token: "sidebar / sidebar-foreground", controls: "Superfície e texto do sidebar",
      used_by: "Container do Sidebar" },
    { token: "sidebar-primary / -foreground", controls: "Ações de alta ênfase no sidebar",
      used_by: "Itens ativos, ladrilhos de ícone, CTAs" },
    { token: "sidebar-accent / -foreground", controls: "Hover e seleção no sidebar",
      used_by: "Hover de menu, itens abertos" },
    { token: "sidebar-border", controls: "Bordas do sidebar",
      used_by: "Headers, grupos e divisores do sidebar" },
    { token: "sidebar-ring", controls: "Anéis de foco do sidebar",
      used_by: "Controles focados no sidebar" },
    { token: "radius", controls: "Raio de canto base",
      used_by: "Cards, inputs, botões, popovers" }
  ].freeze

  # The files the agent skill ships, and what each one carries.
  SKILL_FILES = [
    { path: "SKILL.md", summary: "Princípios, regras críticas, tabela de seleção de componente e o " \
                                 "workflow. Injeta bin/shadwire status --json como contexto do projeto." },
    { path: "cli.md", summary: "Referência de cada comando e flag, o formato do payload JSON e como " \
                               "interpretar erros e códigos de saída." },
    { path: "theming.md", summary: "Onde ficam os tokens, dark mode por classe, como retematizar, " \
                                   "adicionar token e preservar edições entre updates." },
    { path: "rules/composition.md", summary: "Subcomponentes como helpers aninhados, itens dentro do " \
                                             "grupo, título obrigatório em overlays, Stimulus." },
    { path: "rules/styling.md", summary: "Tokens semânticos, precedência de classes, atributos HTML " \
                                         "livres, convenções de utilitários do Tailwind." },
    { path: "rules/forms.md", summary: "A família field, estado de validação, integração com " \
                                       "form_with e a escolha do controle." },
    { path: "rules/icons.md", summary: "lucide-rails, nomes kebab-case, tamanhos e quando o ícone " \
                                       "precisa de rótulo acessível." }
  ].freeze

  def index; end

  def installation; end

  def configuration; end

  def theming
    @tokens = TOKENS
  end

  def dark_mode; end

  def cli
    @commands = COMMANDS
    @flags = FLAGS
  end

  def agent_skill
    @skill_files = SKILL_FILES
  end

  def registry; end

  def llms_txt; end

  def composition; end

  def styling; end

  def forms; end

  def icons; end

  def accessibility; end
end
