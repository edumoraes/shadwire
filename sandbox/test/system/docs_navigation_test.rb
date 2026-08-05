# frozen_string_literal: true

require "application_system_test_case"

# The documentation shell only fully exists in a browser: the "Nesta página"
# rail is built client-side from the headings, and the mobile sidebar is a sheet.
class DocsNavigationTest < ApplicationSystemTestCase
  SCREEN_SIZE = [ 1400, 1000 ].freeze

  # Capybara reuses one browser across the file, so a test that shrinks the
  # window would hide the xl-only table of contents for whatever runs next.
  teardown { resize_window_to(*SCREEN_SIZE) }

  test "the table of contents is built from the page headings" do
    visit docs_cli_path

    within "nav[aria-label='Nesta página']" do
      assert_selector "a", text: "Comandos"
      assert_selector "a", text: "Flags"
      assert_selector "a", text: "Erros e código de saída"
    end

    # Anchors resolve because the controller gives every heading an id.
    assert_equal "flags", find("h2", text: "Flags")[:id]
    assert find("nav[aria-label='Nesta página'] a", text: "Flags")[:href].end_with?("#flags")
  end

  test "the table of contents follows the section being read" do
    visit docs_cli_path

    assert_selector "nav[aria-label='Nesta página'] a", text: "Erros e código de saída"
    find("h2", text: "Erros e código de saída").execute_script("this.scrollIntoView()")

    assert_selector "nav[aria-label='Nesta página'] a[data-active='true']", text: "Erros e código de saída"
  end

  # A section taller than the observation band used to leave the whole rail
  # unhighlighted, which was most of the scroll range on a long page.
  test "exactly one entry is highlighted at any scroll position" do
    visit docs_cli_path

    assert_selector "nav[aria-label='Nesta página'] a"
    height = page.evaluate_script("document.documentElement.scrollHeight")

    (0..height).step(300) do |offset|
      page.execute_script("window.scrollTo(0, #{offset})")
      assert_selector "nav[aria-label='Nesta página'] a[data-active='true']", count: 1,
                      wait: 2
    end
  end

  # A live example renders headings of its own, and on the overlay pages they sit
  # inside a closed <dialog>, where the anchor cannot resolve.
  test "the table of contents leaves live previews out" do
    visit "/components/accordion"

    entries = all("nav[aria-label='Nesta página'] a").map(&:text)

    assert_includes entries, "Exemplos"
    assert_includes entries, "Basic"
    refute_includes entries, "Como faço para redefinir minha senha?"

    visit "/components/sheet"

    assert_empty all("nav[aria-label='Nesta página'] a").map(&:text).grep(/\ASheet: /)
  end

  test "the sidebar marks the current page and moves between pages" do
    visit docs_theming_path

    assert_selector "nav[aria-label='Documentation'] a[aria-current='page']", text: "Theming"

    within "nav[aria-label='Pages']" do
      click_link "Dark mode"
    end

    assert_selector "h1", text: "Dark mode"
    assert_selector "nav[aria-label='Documentation'] a[aria-current='page']", text: "Dark mode"
  end

  test "the palette opens with the keyboard, filters and navigates" do
    visit docs_path

    assert_no_selector "dialog[data-slot='dialog-content'][open]"

    find("body").send_keys([ :control, "k" ])

    palette = find("dialog[data-slot='dialog-content'][open]")
    assert palette["aria-labelledby"].present?

    within palette do
      fill_in_command "date picker"

      assert_selector "[data-slot='command-item']:not([hidden])", text: "Date Picker"
      find("[data-slot='command-item']", text: "Date Picker", match: :first).click
    end

    assert_selector "h1", text: "Date Picker"
  end

  # Turbo caches the outgoing page. A snapshot taken with the palette still open
  # used to restore as a non-modal dialog that no key or click could dismiss.
  test "going back does not restore a stuck overlay" do
    visit docs_path

    find("body").send_keys([ :control, "k" ])
    find("dialog[data-slot='dialog-content'][open]")

    within "dialog[data-slot='dialog-content'][open]" do
      fill_in_command "theming"
      find("[data-slot='command-item']", text: "Theming", match: :first).click
    end

    assert_selector "h1", text: "Theming"

    page.go_back

    assert_selector "h1", text: "Introdução"
    assert_no_selector "dialog[open]", visible: :all
  end

  test "small screens open the sidebar in a sheet" do
    resize_window_to(390, 844)

    visit docs_path

    assert_no_selector "dialog[data-slot='sheet-content'][open]"

    find("[data-slot='sheet-trigger']").click

    within "dialog[data-slot='sheet-content'][open]" do
      assert_selector "nav[aria-label='Documentation']"
      click_link "CLI"
    end

    assert_selector "h1", text: "CLI"
  end

  private

  def fill_in_command(query)
    find("[data-slot='command-input']").set(query)
  end

  def resize_window_to(width, height)
    page.driver.browser.manage.window.resize_to(width, height)
  end
end
