# frozen_string_literal: true

require "test_helper"
require "prism"
require_relative "../support/portuguese_text"

# The English documentation has to be English.
#
# The component pages were written in Portuguese and translated, and the
# translation stopped short in thirty places: "Or render Ui::ButtonComponent
# diretamente", "Atributos HTML livres", "Submenu aninhado", a connective "e"
# left between two code spans. The code snippets had the same leak — a card
# titled "Criar projeto" on the English page. ExampleLocalisationTest covers the
# example partials; this covers the prose and the snippets around them.
class DocsLanguageTest < ActiveSupport::TestCase
  ENGLISH_PAGES = Dir[Rails.root.join("app/views/components/*.en.html.erb")].sort.freeze

  # Shown on both trees as they are: usage snippets, composition diagrams, the
  # guide pages' code. DocsSnippets::LOCALISATION is the one exception — it shows
  # a pt.yml on purpose.
  SNIPPET_SOURCES = %w[app/controllers/components_controller.rb app/lib/docs_snippets.rb].freeze
  PORTUGUESE_ON_PURPOSE = %i[LOCALISATION].freeze

  test "the English component pages carry no Portuguese" do
    refute_empty ENGLISH_PAGES

    leaking = ENGLISH_PAGES.filter_map do |path|
      hits = PortugueseText.hits(PortugueseText.prose(File.read(path)), connective: true)
      "#{File.basename(path)}: #{hits.join(", ")}" if hits.any?
    end

    assert_empty leaking, "Portuguese in the English component pages:\n#{leaking.join("\n")}"
  end

  test "the snippets both trees show carry no Portuguese" do
    leaking = SNIPPET_SOURCES.flat_map do |relative|
      string_literals(Rails.root.join(relative).read).filter_map do |line, text|
        hits = PortugueseText.hits(text)
        "#{relative}:#{line}: #{hits.join(", ")}" if hits.any?
      end
    end

    assert_empty leaking, "Portuguese in the shared code snippets:\n#{leaking.join("\n")}"
  end

  # Guards the guard: each of these shipped on an English page.
  test "the detector still catches the leaks that shipped" do
    [
      "Or render Ui::ButtonComponent diretamente:",
      "Atributos HTML livres (href, data:, aria:, …).",
      "Submenu aninhado.",
      "O controller ui-select follows the APG pattern",
      %(<%= ui_card_title { "Criar projeto" } %>)
    ].each do |leak|
      refute_empty PortugueseText.hits(leak), "no longer caught: #{leak}"
    end

    refute_empty PortugueseText.hits("class / class_name e **attrs", connective: true)
  end

  test "the detector leaves English alone" do
    [
      "Every part accepts class / class_name and **attrs, e.g. data: and aria:.",
      "Write to ada@example.com or visit https://example.com/docs.",
      "An e-mail field, a toggle and a combobox."
    ].each do |english|
      assert_empty PortugueseText.hits(english, connective: true), english
    end
  end

  private

  # [line, text] for every string literal — heredocs included, and the literal
  # parts of interpolated ones — outside the constants that are Portuguese on
  # purpose.
  def string_literals(source)
    found = []
    walk = lambda do |node|
      next if node.is_a?(Prism::ConstantWriteNode) && PORTUGUESE_ON_PURPOSE.include?(node.name)

      found << [ node.location.start_line, node.unescaped ] if node.is_a?(Prism::StringNode)
      node.compact_child_nodes.each { |child| walk.call(child) }
    end
    walk.call(Prism.parse(source).value)
    found
  end
end
