# frozen_string_literal: true

require "test_helper"

# The API reference on every component page covers every argument the component
# takes, in both languages.
#
# Twenty-five pages render through the generic doc_page, and none of them had an
# API reference; the hand-written tables had drifted from the code (the overlay
# triggers' old default, the sidebar's missing arguments). The generic pages now
# generate theirs from the source (components/_api, DocsComponentApi) and the
# hand-written ones keep their own tables. Both are held to the source here.
class DocsComponentApiTest < ActionDispatch::IntegrationTest
  # The combobox ships no component of its own — it is composed from the
  # popover's and the command's — so it has no reference to check.
  COMPONENTS = DocsComponentApi.items.values
                               .select { |item| item.fetch("type") == "component" }
                               .map { |item| item.fetch("name") }
                               .select { |name| DocsComponentApi.parts(name).any? }.freeze

  PREFIXES = { en: "", pt: "/pt" }.freeze

  API_DOCS = %w[en pt].to_h { |locale|
    [ locale, YAML.load_file(Rails.root.join("config/locales/#{locale}.yml")).dig(locale, "components", "api_docs") ]
  }.freeze

  test "every argument a component takes is in its page's API reference" do
    missing = each_page.flat_map do |name, path, section|
      # `side`, `side:` and `side: :top` all name the argument; `:top` does not.
      documented = section.css("code").filter_map { |code| code.text.strip[/\A\w+/] }
      (DocsComponentApi.props(name).map(&:name) - documented).map { |prop| "#{path}: #{prop}" }
    end

    assert_empty missing, "arguments the source takes that its page does not document:\n#{missing.join("\n")}"
  end

  test "every generated row has a description" do
    generated = COMPONENTS.reject { |name| hand_written?(name) }
    assert_operator generated.size, :>, 20

    blank = each_page(generated).flat_map do |_name, path, section|
      section.css("tbody tr").filter_map do |row|
        cells = row.css("td").map { |cell| cell.text.strip }
        "#{path}: #{cells.first(2).join(" ")}" if cells.last.blank? || cells.last == "—"
      end
    end

    assert_empty blank, "add these to components.api_docs in config/locales:\n#{blank.join("\n")}"
  end

  # config.i18n.fallbacks would fill a missing Portuguese line with the English
  # one, silently; the page would render and read half in English.
  test "the Portuguese descriptions mirror the English ones" do
    assert_equal key_paths(API_DOCS.fetch("en")), key_paths(API_DOCS.fetch("pt"))
  end

  # The other direction: a renamed argument leaves a description nothing reads.
  test "every description belongs to an argument the source still takes" do
    props = DocsComponentApi.items.keys.flat_map { |name| DocsComponentApi.parts(name) }
                            .select(&:helper).to_h { |part| [ part.helper, part.props.map(&:name) ] }

    orphans = API_DOCS.fetch("en").fetch("args").flat_map do |helper, args|
      next [ helper ] unless props.key?(helper)

      (args.keys - props.fetch(helper)).map { |arg| "#{helper}.#{arg}" }
    end

    assert_empty orphans, "components.api_docs.args describes what the source no longer takes:\n#{orphans.join("\n")}"
  end

  test "defaults read as the reader would write them" do
    prop = ->(default) { DocsComponentApi::Prop.new(name: "label", default: default) }

    assert_equal "—", DocsComponentApi.display_default(prop.(nil))
    assert_equal ":default", DocsComponentApi.display_default(prop.(":default"))
    assert_equal %("Toggle Sidebar"), DocsComponentApi.display_default(prop.(%(I18n.t("ui.sidebar.toggle", default: "Toggle Sidebar"))))
  end

  private

  # [name, path, API section] for each component page, in both languages.
  def each_page(names = COMPONENTS)
    names.flat_map do |name|
      PREFIXES.map do |locale, prefix|
        path = "#{prefix}/components/#{name}"
        get path
        assert_response :success

        [ name, path, api_section(locale, path) ]
      end
    end
  end

  def api_section(locale, path)
    heading = I18n.t("components.sections.api", locale: locale)
    h2 = css_select("main h2").find { |node| node.text.strip == heading }
    assert h2, "#{path} has no #{heading} section"
    h2.parent
  end

  def hand_written?(name)
    Rails.root.join("app/views/components/#{name.tr("-", "_")}.en.html.erb").exist?
  end

  def key_paths(hash, prefix = nil)
    hash.flat_map do |key, value|
      path = [ prefix, key ].compact.join(".")
      value.is_a?(Hash) ? key_paths(value, path) : [ path ]
    end.sort
  end
end
