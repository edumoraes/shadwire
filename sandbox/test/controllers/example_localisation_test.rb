# frozen_string_literal: true

require "test_helper"

# The live examples under components/examples/, in both language trees.
#
# The unsuffixed partial is the English copy and Rails picks _foo.pt.html.erb
# over it when the locale is :pt. Most examples have no localised copy and never
# will — `ui_button { "Save" }` illustrates a registry whose language is English.
# Only the demos whose content is prose or domain data are worth two files.
class ExampleLocalisationTest < ActionDispatch::IntegrationTest
  include DocsHelper

  BASE = Dir[DocsHelper::EXAMPLES_DIR.join("_*.html.erb")]
         .reject { |path| File.basename(path).match?(/\.[a-z]{2}\.html\.erb\z/) }
         .sort.freeze

  LOCALISED = Dir[DocsHelper::EXAMPLES_DIR.join("_*.pt.html.erb")].sort.freeze

  # Portuguese has diacritics English does not, and these words have no English
  # homograph. Between them they catch the leak without flagging prose.
  DIACRITICS = /[çãõáéíóúâêôà]/i
  WORDS = /\b(você|voce|não|nao|uma|para|seu|sua|aqui|então|também|arquivo|salvar|
             cancelar|criar|editar|excluir|inscrever|buscar|entrar|novo|nova|
             mensagem|senha|nome|conta|perfil|escolha|selecione|digite|clique)\b/xi

  # The RTL demos are written in Arabic on purpose, in both trees: the point of
  # the example is the direction, and a Latin-script string would not show it.
  RTL = /_rtl\./

  # The half of this the issue called a blocker rather than a blemish. English
  # in the Portuguese tree reads badly; Portuguese in the English tree is wrong.
  test "no English example partial contains Portuguese" do
    leaking = BASE.reject { |path| path.match?(RTL) }.filter_map do |path|
      source = File.read(path)
      hits = source.scan(DIACRITICS).uniq + source.scan(WORDS).flatten.compact.uniq
      "#{File.basename(path)}: #{hits.uniq.join(", ")}" if hits.any?
    end

    assert_empty leaking, "Portuguese in the English examples:\n#{leaking.join("\n")}"
  end

  test "every localised example has an English original" do
    orphans = LOCALISED.reject { |path| File.exist?(path.sub(".pt.html.erb", ".html.erb")) }

    assert_empty orphans.map { |path| File.basename(path) }
  end

  # A copy that was never translated would pass every check above.
  test "no localised example is a copy of the English" do
    copies = LOCALISED.select { |path| File.read(path) == File.read(path.sub(".pt.html.erb", ".html.erb")) }

    assert_empty copies.map { |path| File.basename(path) }
  end

  test "the localised examples are worth having" do
    refute_empty LOCALISED
    assert_operator LOCALISED.size, :<, BASE.size,
                    "every example was localised — the English-only default is the point"
  end

  test "a Portuguese page renders the Portuguese demo" do
    get "/pt/components/accordion"

    assert_response :success
    assert_select "body", text: /Como redefino minha senha\?/
    assert_select "body", { text: /How do I reset my password\?/, count: 0 },
                  "the English copy leaked into /pt"
  end

  test "an English page keeps the English demo" do
    get "/components/accordion"

    assert_response :success
    assert_select "body", text: /How do I reset my password\?/
    assert_select "body", { text: /Como redefino minha senha\?/, count: 0 }
  end

  # The snippet under a preview is read off disk, not captured from the render,
  # so the two can disagree: the demo would be Portuguese and the code listing
  # under it English, which is worse than either being consistent.
  test "the snippet under a Portuguese demo is the Portuguese source" do
    get "/pt/components/accordion"

    assert_select "pre.highlight", text: /Como redefino minha senha\?/
    assert_select "pre.highlight", { text: /How do I reset my password\?/, count: 0 }
  end

  test "the snippet under an English demo is the English source" do
    get "/components/accordion"

    assert_select "pre.highlight", text: /How do I reset my password\?/
  end

  # Localising a partial that a page never renders is dead weight, and the more
  # likely mistake — a slug typo — leaves the Portuguese page silently English.
  test "every localised example is rendered by some page" do
    slugs = LOCALISED.map { |path| File.basename(path).delete_prefix("_").delete_suffix(".pt.html.erb") }
    # The example lists reach examples_for both as named constants and as inline
    # arrays, so match the controller source rather than its constants.
    controller = Rails.root.join("app/controllers/components_controller.rb").read

    assert_empty slugs.reject { |slug| controller.include?(slug) }, "localised but never rendered"
  end
end
