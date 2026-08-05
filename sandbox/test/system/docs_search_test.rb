# frozen_string_literal: true

require "application_system_test_case"

# The ⌘K palette only really exists in a browser: the corpus is fetched on the
# first keystroke and the results are rendered client-side.
class DocsSearchTest < ApplicationSystemTestCase
  # The index is a build artifact, not a fixture. Building it here is also the
  # only way the test server can serve it out of public/.
  #
  # Rendering every page twice takes a few seconds, so do it once for the file.
  def self.build_index_once
    @built ||= DocsSearchIndex.write
  end

  setup { self.class.build_index_once }

  def open_palette
    find("body").send_keys([ :control, "k" ])
    find("dialog[data-slot='dialog-content'][open]")
  end

  def type(query)
    find("[data-slot='command-input']").set(query)
  end

  def results
    "dialog[open] [data-docs-search-target='results']"
  end

  # The issue's "done when": typing a word that appears nowhere in a title finds
  # the page that explains it.
  test "a word only in the body of a page finds that page" do
    visit docs_path
    open_palette

    type "oklch"

    assert_selector "#{results} [data-slot='command-item']", text: "Theming"
    assert_selector "#{results} mark", text: "oklch"
  end

  test "a body hit shows the sentence it was found in" do
    visit docs_path
    open_palette

    type "binstub"

    within results do
      assert_selector "[data-slot='command-item']", minimum: 1
      # Not just the title: the snippet is what tells the reader why this page.
      assert_selector "[data-slot='command-item']", text: /binstub/i
    end
  end

  test "a title match outranks a body match" do
    visit docs_path
    open_palette

    type "theming"

    assert_equal "Theming", first("#{results} [data-slot='command-item']").text.lines.first.strip
  end

  test "choosing a result navigates to the page" do
    visit docs_path
    open_palette

    type "oklch"
    find("#{results} [data-slot='command-item']", text: "Theming", match: :first).click

    assert_selector "h1", text: "Theming"
  end

  test "clearing the query brings the sidebar listing back" do
    visit docs_path
    open_palette

    type "oklch"
    assert_selector "#{results} [data-slot='command-item']"

    type ""

    assert_no_selector "#{results} [data-slot='command-item']"
    assert_selector "dialog[open] [data-slot='command-item']:not([hidden])", text: "Installation"
  end

  test "the Portuguese palette searches the Portuguese pages" do
    visit "/pt/docs"
    open_palette

    type "oklch"

    assert_selector "#{results} [data-slot='command-item']", text: "Theming"
    assert_selector "#{results} [data-slot='command-item'][data-href^='/pt/']"
  end

  # The palette must never get worse than it was: an index that cannot be
  # fetched leaves ui-command's own title filter running underneath.
  #
  # The URL is repointed rather than the file moved away. public/ is served with
  # `cache-control: public, max-age=3600` in this environment, so a file deleted
  # from disk keeps arriving from the browser cache and the fallback never runs —
  # which is exactly how this test passed locally and failed in CI.
  test "the title filter still works when the index cannot be fetched" do
    visit docs_path
    open_palette
    page.execute_script(<<~JS)
      document.querySelector("[data-controller~='docs-search']")
              .setAttribute("data-docs-search-index-url-value", "/search-index.nonexistent.json")
    JS

    type "theming"

    assert_selector "dialog[open] [data-slot='command-item']:not([hidden])", text: "Theming"
    assert_no_selector "#{results} [data-slot='command-item']"
  end
end
