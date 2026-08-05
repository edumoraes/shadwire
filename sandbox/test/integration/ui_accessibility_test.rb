# frozen_string_literal: true

require "test_helper"

class UiAccessibilityTest < ActionDispatch::IntegrationTest
  test "landing page renders hero, navigation and live showcase" do
    get root_path

    assert_response :success
    assert_select "html[lang='en']"
    assert_select "main"
    assert_select "h1", count: 1
    assert_select "h1", text: /your code/

    # Header navigation links to the catalog and blocks; theme toggle is labelled.
    assert_select "nav[aria-label='Main'] a[href='#{components_path}']", text: "Components"
    assert_select "nav[aria-label='Main'] a[href='#{blocks_path}']", text: "Blocks"
    assert_select "button[aria-label='Toggle theme']"

    # The showcase renders a live, tabbed component preview.
    assert_select "[data-controller='ui-tabs']"
    assert_select "[role='tablist'] button[role='tab']"

    # The landing stays free of overlay controllers (no hidden dialogs/menus).
    assert_select "dialog", count: 0
    assert_select "[data-controller='ui-dialog']", count: 0
    assert_select "[data-controller='ui-popover']", count: 0
    assert_select "[data-controller='ui-dropdown-menu']", count: 0
    assert_select "[data-controller='ui-select']", count: 0
  end

  # The Portuguese tree is a separate template and a separate locale file, so
  # "it works in English" says nothing about it. This is also the guard that the
  # two trees stay linked: lose the switcher and the static crawl stops finding
  # /pt at all, silently publishing a monolingual site.
  test "the Portuguese landing page renders and links back to the English one" do
    get "/pt"

    assert_response :success
    assert_select "html[lang='pt-BR']"
    assert_select "h1", count: 1
    assert_select "h1", text: /código seu/
    assert_select "nav[aria-label='Principal'] a[href='#{components_path(locale: "pt")}']", text: "Componentes"
    assert_select "button[aria-label='Alternar tema']"

    assert_select "nav[aria-label='Idioma'] a[href='/']", text: /en/
  end

  test "the English landing page offers the Portuguese one" do
    get root_path

    assert_select "nav[aria-label='Language'] a[href='/pt']", text: /pt/
    assert_select "link[rel='alternate'][hreflang='pt-BR']"
    assert_select "link[rel='alternate'][hreflang='x-default']"
    assert_select "link[rel='canonical'][href='https://shadwire.edumoraes.dev.br/']"
  end

  test "components catalog lists the documented components" do
    get components_path

    assert_response :success
    assert_select "main"
    assert_select "h1", text: "Componentes"
    assert_select "nav[aria-label='Componentes']"

    assert_select "nav[aria-label='Componentes'] a[href='#{components_button_path}']", text: /Button/
    assert_select "nav[aria-label='Componentes'] a[href='#{components_dialog_path}']", text: /Dialog/
    assert_select "nav[aria-label='Componentes'] a[href='#{components_sidebar_path}']", text: /Sidebar/
  end
end
