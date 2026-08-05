# frozen_string_literal: true

require "test_helper"

# The API reference tables on the component pages.
#
# Every one of them renders through docs/_table, so the card, the column classes
# and the header row exist in one file rather than twice on each of thirty
# locale pairs. These tests keep it that way, and keep the header row — which is
# repeated text, not page prose — out of the templates.
class ComponentApiTablesTest < ActionDispatch::IntegrationTest
  PAGES = Dir[Rails.root.join("app/views/components/*.html.erb")]
          .reject { |path| File.basename(path).start_with?("_", "doc_page") }
          .sort.freeze

  # "API" and "Helper" read the same in both languages. Anything else in a header
  # is a string that will be shown in whichever tree the page belongs to, so it
  # belongs in the locale files.
  NEUTRAL = %w[API Helper].freeze

  HEADERS = /headers:\s*\[(.+?)\]/m

  # Bare strings only: the argument of a t(...) call is a key, not a header.
  def header_literals(source)
    source.scan(HEADERS).flatten
          .map { |list| list.gsub(/t\(\s*"[^"]*"\s*\)/, "") }
          .flat_map { |list| list.scan(/"([^"]*)"/).flatten }
  end

  test "no page rebuilds the table markup by hand" do
    offenders = PAGES.select { |path| File.read(path).include?("<thead") }

    assert_empty offenders.map { |path| File.basename(path) },
                 "these write their own table instead of rendering docs/table"
  end

  test "every table header comes from the locale files" do
    offenders = PAGES.filter_map do |path|
      stray = header_literals(File.read(path)) - NEUTRAL
      "#{File.basename(path)}: #{stray.join(", ")}" if stray.any?
    end

    assert_empty offenders,
                 "hardcoded headers are shown in whichever tree the page is in:\n#{offenders.join("\n")}"
  end

  test "the tables render with a header row scoped for screen readers" do
    get "/components/tooltip"

    assert_response :success
    assert_select "main table thead th[scope='col']", count: 4
    assert_select "main table thead th", text: "Component"
    assert_select "main table tbody td code", text: "open_delay"
  end

  test "the Portuguese table reads in Portuguese" do
    get "/pt/components/tooltip"

    assert_response :success
    assert_select "main table thead th", text: "Componente"
    assert_select "main table thead th", text: "Descrição"
  end

  # The headers that used to be written into the templates were Portuguese, and
  # the English pages carried them too.
  test "an English page does not show a Portuguese header" do
    get "/components/accordion"

    assert_response :success
    assert_select "main table thead th", text: "Main arguments"
    assert_select "main table thead th", { text: "Argumentos principais", count: 0 }
  end
end
