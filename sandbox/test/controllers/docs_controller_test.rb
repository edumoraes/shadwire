# frozen_string_literal: true

require "test_helper"

class DocsControllerTest < ActionDispatch::IntegrationTest
  # Every guide page, with a heading that must appear on it. Keeps a renamed or
  # emptied page from passing on a bare 200.
  PAGES = {
    "/docs" => "Introdução",
    "/docs/installation" => "Instalação",
    "/docs/configuration" => "shadwire.json",
    "/docs/theming" => "Theming",
    "/docs/dark-mode" => "Dark mode",
    "/docs/cli" => "CLI",
    "/docs/agent-skill" => "Agent skill",
    "/docs/registry" => "Registry",
    "/docs/llms-txt" => "llms.txt",
    "/docs/composition" => "Composição",
    "/docs/styling" => "Estilização",
    "/docs/forms" => "Formulários",
    "/docs/icons" => "Ícones",
    "/docs/accessibility" => "Acessibilidade"
  }.freeze

  PAGES.each do |path, heading|
    test "#{path} renders inside the documentation shell" do
      get path

      assert_response :success
      assert_select "h1", text: heading
      assert_select "nav[aria-label='Documentação']"
      assert_select "[data-controller='docs-toc']"
      assert_select "nav[aria-label='Documentação'] a[aria-current='page'][href='#{path}']"
    end
  end

  test "the sidebar groups the documentation by topic" do
    get docs_path

    assert_response :success
    %w[Começar Ferramentas Guias Blocks Componentes].each do |group|
      assert_select "nav[aria-label='Documentação'] ul[aria-label='#{group}'] li a"
    end
    # Group labels must not be headings: six of them would push the page's own
    # h1 down to seventh in the heading list.
    nav = "nav[aria-label='Documentação']"
    assert_select "#{nav} h1, #{nav} h2, #{nav} h3, #{nav} h4, #{nav} h5, #{nav} h6", count: 0
  end

  test "the CLI page documents every command and flag" do
    get docs_cli_path

    assert_response :success
    DocsController::COMMANDS.each do |command|
      assert_select "table td code", text: command[:signature]
    end
    DocsController::FLAGS.each do |flag|
      assert_select "table td code", text: flag[:flag]
    end
  end

  test "the CLI page shows the status payload agents rely on" do
    get docs_cli_path

    assert_select "pre.highlight", text: /"installed"/
    assert_select "pre.highlight", text: /"binstub"/
    assert_select "table td code", text: "installed[].helpers"
  end

  test "the agent skill page lists the files the skill ships" do
    get docs_agent_skill_path

    assert_response :success
    DocsController::SKILL_FILES.each do |file|
      assert_select "table td code", text: file[:path]
    end
    assert_select "pre.highlight", text: /npx skills add edumoraes\/shadwire/
  end

  test "the theming page documents every semantic token" do
    get docs_theming_path

    assert_response :success
    assert_select "table td code", text: "primary / primary-foreground"
    assert_select "table td code", text: "sidebar-ring"
    assert_select "table td code", count: DocsController::TOKENS.size, text: /./
  end

  test "guide pages render highlighted code with copy controls" do
    get docs_composition_path

    assert_select "pre.highlight span"
    assert_select "[data-controller='clipboard']"
    assert_select "[data-action='clipboard#copy']"
  end

  test "pages link to the previous and next entry in the sidebar" do
    get docs_installation_path

    assert_response :success
    assert_select "nav[aria-label='Páginas'] a[rel='prev'][href='#{docs_path}']"
    assert_select "nav[aria-label='Páginas'] a[rel='next'][href='#{docs_configuration_path}']"
  end

  test "the first page has no previous link" do
    get docs_path

    assert_select "nav[aria-label='Páginas'] a[rel='prev']", count: 0
    assert_select "nav[aria-label='Páginas'] a[rel='next'][href='#{docs_installation_path}']"
  end

  test "the breadcrumb names the topic the page belongs to" do
    get docs_cli_path

    assert_select "nav[aria-label='breadcrumb'] a[href='#{docs_path}']", text: "Docs"
    assert_select "nav[aria-label='breadcrumb']", text: /Ferramentas/
    assert_select "nav[aria-label='breadcrumb'] [data-slot='breadcrumb-page']", text: "CLI"
  end

  test "the documentation is reachable from the landing page and the footer" do
    get root_path

    assert_response :success
    assert_select "nav[aria-label='Principal'] a[href='#{docs_path}']", text: "Documentação"
    assert_select "nav[aria-label='Rodapé'] a[href='#{docs_path}']", text: "Documentação"
  end

  test "the search palette offers every page the sidebar lists" do
    get docs_path

    assert_select "[data-controller='docs-search'] [data-slot='command']"
    # The sidebar renders twice (sticky aside + mobile sheet); the palette once.
    sidebar_entries = css_select("nav[aria-label='Documentação'] a").size / 2
    assert_operator sidebar_entries, :>, 60
    assert_select "[data-slot='command-item']", count: sidebar_entries
    assert_select "[data-slot='command-item'][data-href='#{docs_cli_path}']", text: /CLI/
    assert_select "[data-slot='command-item'][data-href='/components/button']", text: /Button/
    # The palette is a dialog, so it needs a name even though the header is sr-only.
    assert_select "[data-controller='docs-search'] [data-slot='dialog-title']", text: "Buscar na documentação"
  end

  test "the search palette advertises its shortcut" do
    get docs_path

    assert_select "[data-controller='docs-search'] [data-docs-search-target='trigger'][aria-label='Buscar na documentação']"
    assert_select "[data-controller='docs-search'] [data-slot='kbd']", text: "K"
  end

  test "the landing page stays free of the palette and its dialog" do
    get root_path

    assert_select "[data-controller='docs-search']", count: 0
    assert_select "dialog", count: 0
  end

  test "small screens reach the sidebar through a labelled sheet" do
    get docs_path

    assert_select "[data-slot='sheet'] [data-slot='sheet-trigger'][aria-label='Abrir a navegação da documentação']"
    assert_select "[data-slot='sheet'] dialog[data-slot='sheet-content'][data-side='left']"
    # The nav is rendered twice, once in the sticky aside and once in the sheet,
    # from the same partial, so the two can never disagree.
    assert_select "nav[aria-label='Documentação']", count: 2
  end
end
