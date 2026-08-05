# frozen_string_literal: true

require "test_helper"

# The corpus the ⌘K palette searches.
#
# The queries below are the ones from the issue that opened this: each has an
# answer on the site and each found nothing when the palette matched titles
# only. They are the specification, so they are the test.
class DocsSearchIndexTest < ActionDispatch::IntegrationTest
  # Built once for the whole file — it renders every page twice over.
  INDEX = DocsSearchIndex.build.freeze

  def entries(locale) = INDEX.select { |entry| entry[:locale] == locale.to_s }

  def find_by_path(path) = INDEX.find { |entry| entry[:path] == path }

  def matching(query, locale: "en")
    entries(locale).select { |entry| entry[:text].downcase.include?(query) }.map { |entry| entry[:title] }
  end

  test "both language trees are indexed, and separately" do
    assert_operator entries(:en).size, :>, 60
    assert_equal entries(:en).size, entries(:pt).size,
                 "the trees are the same site — a gap means a page is unreachable in one of them"
    assert entries(:pt).all? { |entry| entry[:path].start_with?("/pt/") }
    assert entries(:en).none? { |entry| entry[:path].start_with?("/pt/") }
  end

  test "the index covers every page the palette offers" do
    get docs_path
    offered = css_select("[data-slot='command-item'][data-href]").map { |item| item["data-href"] }.uniq

    assert_empty offered - entries(:en).map { |entry| entry[:path] }
  end

  # Each of these opened nothing before. The expectations are the issue's table.
  test "the queries the title filter could not answer now find their page" do
    { "oklch" => "Theming",
      "binstub" => "Installation",
      "exit-code" => "CLI",
      "form_with" => "Forms",
      "sr-only" => "Composition" }.each do |query, page|
      assert_includes matching(query), page, "#{query.inspect} still does not find #{page}"
    end
  end

  test "a page carries its headings so a heading hit can outrank a body hit" do
    theming = find_by_path("/docs/theming")

    assert_includes theming[:headings], "The tokens"
    assert_includes theming[:title], "Theming"
    assert_equal "Guides", find_by_path("/docs/composition")[:group]
  end

  # The sidebar, the header and the palette are on all 70-odd pages. Indexing
  # them would make every page match every navigational word.
  test "only the main content is indexed" do
    text = find_by_path("/docs/theming")[:text]

    refute_includes text, "Search the documentation", "the palette itself is in the corpus"
    refute_includes text, "Shadwire on GitHub", "the header is in the corpus"
  end

  test "a Portuguese page is indexed in Portuguese" do
    theming = INDEX.find { |entry| entry[:path] == "/pt/docs/theming" }

    assert_includes theming[:text], "oklch"
    assert_includes matching("tokens", locale: "pt"), "Theming"
  end

  test "the index is written per locale" do
    Dir.mktmpdir do |dir|
      written = DocsSearchIndex.write(dir: Pathname.new(dir))

      assert_equal I18n.available_locales.sort, written.keys.sort
      I18n.available_locales.each do |locale|
        path = DocsSearchIndex.path_for(locale, dir: Pathname.new(dir))
        assert path.exist?, "#{path} was not written"
        assert_operator JSON.parse(path.read).size, :>, 60
      end
    end
  end
end
