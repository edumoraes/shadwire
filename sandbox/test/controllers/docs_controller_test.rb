# frozen_string_literal: true

require "test_helper"

class DocsControllerTest < ActionDispatch::IntegrationTest
  # Every guide page, with the heading each language must show on it. Keeps a
  # renamed or emptied page from passing on a bare 200 — and, since each page is
  # two independent templates, keeps one of the pair from silently going missing.
  PAGES = {
    "/docs" => [ "Introduction", "Introdução" ],
    "/docs/installation" => [ "Installation", "Instalação" ],
    "/docs/configuration" => [ "shadwire.json", "shadwire.json" ],
    "/docs/theming" => [ "Theming", "Theming" ],
    "/docs/dark-mode" => [ "Dark mode", "Dark mode" ],
    "/docs/cli" => [ "CLI", "CLI" ],
    "/docs/agent-skill" => [ "Agent skill", "Agent skill" ],
    "/docs/registry" => [ "Registry", "Registry" ],
    "/docs/llms-txt" => [ "llms.txt", "llms.txt" ],
    "/docs/composition" => [ "Composition", "Composição" ],
    "/docs/styling" => [ "Styling", "Estilização" ],
    "/docs/forms" => [ "Forms", "Formulários" ],
    "/docs/icons" => [ "Icons", "Ícones" ],
    "/docs/accessibility" => [ "Accessibility", "Acessibilidade" ],
    "/docs/localisation" => [ "Localisation", "Localização" ]
  }.freeze

  PAGES.each do |path, (english, portuguese)|
    test "#{path} renders inside the documentation shell" do
      get path

      assert_response :success
      assert_select "html[lang='en']"
      assert_select "h1", text: english
      assert_select "nav[aria-label='Documentation']"
      assert_select "[data-controller='docs-toc']"
      assert_select "nav[aria-label='Documentation'] a[aria-current='page'][href='#{path}']"
    end

    test "/pt#{path} renders inside the documentation shell" do
      get "/pt#{path}"

      assert_response :success
      assert_select "html[lang='pt-BR']"
      assert_select "h1", text: portuguese
      assert_select "nav[aria-label='Documentação']"
      assert_select "nav[aria-label='Documentação'] a[aria-current='page'][href='/pt#{path}']"
    end
  end

  # PAGES is written by hand, so a page added to the sidebar could go live with
  # nobody ever fetching it here — which is how a broken template passes.
  test "every guide page in the sidebar is covered above" do
    guide_paths = DocsNavHelper::GUIDE_GROUPS.flat_map { |group| group[:routes] }
                                             .reject { |route| route == :blocks }
                                             .map { |route| Rails.application.routes.url_helpers.public_send(:"#{route}_path") }

    guide_paths.each do |path|
      assert_includes PAGES.keys, path, "#{path} is in the sidebar but no test fetches it"
    end
  end

  test "the sidebar groups the documentation by topic" do
    get docs_path

    assert_response :success
    [ "Get started", "Tools", "Guides", "Blocks", "Components" ].each do |group|
      assert_select "nav[aria-label='Documentation'] ul[aria-label='#{group}'] li a"
    end
    # Group labels must not be headings: six of them would push the page's own
    # h1 down to seventh in the heading list.
    nav = "nav[aria-label='Documentation']"
    assert_select "#{nav} h1, #{nav} h2, #{nav} h3, #{nav} h4, #{nav} h5, #{nav} h6", count: 0
  end

  test "the CLI page documents every command and flag" do
    get docs_cli_path

    assert_response :success
    I18n.t("docs.cli.commands").each do |command|
      assert_select "table td code", text: command[:signature]
    end
    I18n.t("docs.cli.flags").each do |flag|
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
    I18n.t("docs.agent_skill.files").each do |file|
      assert_select "table td code", text: file[:path]
    end
    assert_select "pre.highlight", text: /npx skills add edumoraes\/shadwire/
  end

  test "the theming page documents every semantic token" do
    get docs_theming_path

    assert_response :success
    assert_select "table td code", text: "primary / primary-foreground"
    assert_select "table td code", text: "sidebar-ring"
    assert_select "table td code", count: I18n.t("docs.theming.tokens").size, text: /./
  end

  # The reference tables come out of the locale files, so a table that is present
  # in English can be entirely absent in Portuguese without any page 500ing.
  test "the reference tables are translated, not just present" do
    I18n.available_locales.each do |locale|
      %w[docs.cli.commands docs.cli.flags docs.theming.tokens docs.agent_skill.files].each do |key|
        rows = I18n.t(key, locale: locale)

        assert_kind_of Array, rows, "#{key} is not a table in #{locale}"
        refute_empty rows, "#{key} is empty in #{locale}"
      end
    end

    # Portuguese must not be silently falling back to the English text.
    assert_equal "all", I18n.t("docs.cli.flags", locale: :en).first[:commands]
    assert_equal "todos", I18n.t("docs.cli.flags", locale: :pt).first[:commands]
  end

  # The key list is scanned out of the installed component source, so a component
  # that gains a string is documented without anyone editing the page. What can
  # break is the scan itself — a call written in a shape the regex misses would
  # drop a key silently. Grep independently and compare.
  test "the localisation page lists every key the installed components read" do
    keys = Dir[Rails.root.join("app/components/ui/**/*.{rb,erb}")]
           .flat_map { |file| File.read(file).scan(/I18n\.t\("(ui\.[a-z0-9_.]+)"/).flatten }
           .uniq

    get docs_localisation_path

    assert_response :success
    refute_empty keys
    keys.each do |key|
      assert_select "table td code", text: key, count: 1, message: "#{key} is not documented"
    end
  end

  # These four are written into data-*-value attributes and read by a Stimulus
  # controller. Someone translating them needs to know that, and one of them
  # carries placeholders that JavaScript — not I18n — substitutes.
  test "the localisation page marks the keys JavaScript reads" do
    get docs_localisation_path

    %w[ui.data_table.selection ui.calendar.month ui.calendar.year ui.sonner.close].each do |key|
      assert_select "table tr", html: /#{Regexp.escape(key)}.*>value</m,
                    message: "#{key} is not marked as a Stimulus value"
    end
    assert_select "pre.highlight", text: /%\{selected\}/
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
    assert_select "nav[aria-label='Pages'] a[rel='prev'][href='#{docs_path}']"
    assert_select "nav[aria-label='Pages'] a[rel='next'][href='#{docs_configuration_path}']"
  end

  test "the first page has no previous link" do
    get docs_path

    assert_select "nav[aria-label='Pages'] a[rel='prev']", count: 0
    assert_select "nav[aria-label='Pages'] a[rel='next'][href='#{docs_installation_path}']"
  end

  test "the breadcrumb names the topic the page belongs to" do
    get docs_cli_path

    assert_select "nav[aria-label='breadcrumb'] a[href='#{docs_path}']", text: "Docs"
    assert_select "nav[aria-label='breadcrumb']", text: /Tools/
    assert_select "nav[aria-label='breadcrumb'] [data-slot='breadcrumb-page']", text: "CLI"
  end

  test "the documentation is reachable from the landing page and the footer" do
    get root_path

    assert_response :success
    assert_select "nav[aria-label='Main'] a[href='#{docs_path}']", text: "Documentation"
    assert_select "nav[aria-label='Footer'] a[href='#{docs_path}']", text: "Documentation"
  end

  test "the search palette offers every page the sidebar lists" do
    get docs_path

    assert_select "[data-controller='docs-search'] [data-slot='command']"
    # The sidebar renders twice (sticky aside + mobile sheet); the palette once.
    sidebar_entries = css_select("nav[aria-label='Documentation'] a").size / 2
    assert_operator sidebar_entries, :>, 60
    assert_select "[data-slot='command-item']", count: sidebar_entries
    assert_select "[data-slot='command-item'][data-href='#{docs_cli_path}']", text: /CLI/
    assert_select "[data-slot='command-item'][data-href='/components/button']", text: /Button/
    # The palette is a dialog, so it needs a name even though the header is sr-only.
    assert_select "[data-controller='docs-search'] [data-slot='dialog-title']", text: "Search the documentation"
  end

  test "the search palette advertises its shortcut" do
    get docs_path

    assert_select "[data-controller='docs-search'] [data-docs-search-target='trigger'][aria-label='Search the documentation']"
    assert_select "[data-controller='docs-search'] [data-slot='kbd']", text: "K"
  end

  test "the landing page stays free of the palette and its dialog" do
    get root_path

    assert_select "[data-controller='docs-search']", count: 0
    assert_select "dialog", count: 0
  end

  test "small screens reach the sidebar through a labelled sheet" do
    get docs_path

    assert_select "[data-slot='sheet'] [data-slot='sheet-trigger'][aria-label='Open the documentation navigation']"
    assert_select "[data-slot='sheet'] dialog[data-slot='sheet-content'][data-side='left']"
    # The nav is rendered twice, once in the sticky aside and once in the sheet,
    # from the same partial, so the two can never disagree.
    assert_select "nav[aria-label='Documentation']", count: 2
  end
end
