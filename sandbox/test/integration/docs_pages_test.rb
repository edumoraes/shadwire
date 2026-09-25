# frozen_string_literal: true

require "test_helper"
require_relative "../support/class_conflicts"
require_relative "../support/html_nesting"

# Every component documentation page must render, and its install section must
# describe what the registry actually installs.
#
# These pages had no render coverage, which is how they came to advertise a
# helper file the registry no longer ships and to claim the install CLI did not
# exist yet — for months after it shipped.
class DocsPagesTest < ActionDispatch::IntegrationTest
  REGISTRY = JSON.parse(Rails.root.join("../registry/registry.json").read)
  ITEMS = REGISTRY.fetch("items").to_h { |item| [ item.fetch("name"), item ] }.freeze

  # Component doc routes, derived from the routing table so a new page is
  # covered the moment it is routed. Every page sits inside the optional locale
  # scope, so its spec is prefixed with (/:locale); stripping that leaves the
  # English address, which is the one the registry item name is derived from.
  DOC_PATHS = Rails.application.routes.routes.filter_map { |route|
    path = route.path.spec.to_s.sub("(.:format)", "").sub("(/:locale)", "")
    path if path.start_with?("/components/") && route.verb == "GET"
  }.uniq.freeze

  # The same pages in both languages. A page that renders in English can still
  # be broken in Portuguese: the two are separate templates.
  BILINGUAL_DOC_PATHS = DOC_PATHS.flat_map { |path| [ path, "/pt#{path}" ] }.freeze

  test "every component documentation page renders in both languages" do
    refute_empty DOC_PATHS, "expected component documentation routes"

    BILINGUAL_DOC_PATHS.each do |path|
      get path
      assert_response :success, "#{path} did not render"
    end
  end

  test "documentation pages never advertise the removed monolithic helper" do
    BILINGUAL_DOC_PATHS.each do |path|
      get path
      assert_no_match %r{app/helpers/ui_helper\.rb}, response.body,
                      "#{path} still lists the removed app/helpers/ui_helper.rb"
    end
  end

  # Deliberately literal. A fuzzy pattern here matched "cli" inside "clipboard"
  # and flagged an example that legitimately reads "Enterprise (em breve)".
  STALE_CLAIMS = [
    "CLI de instalação ainda está por vir",
    "install CLI is still to come",
    "bin/sync_registry" # the monorepo's internal dev script, not a user command
  ].freeze

  test "documentation pages never advertise a stale install story" do
    BILINGUAL_DOC_PATHS.each do |path|
      get path

      STALE_CLAIMS.each do |claim|
        assert_not_includes response.body, claim, "#{path} still says: #{claim}"
      end
    end
  end

  test "install sections show the shadwire add command and the real file list" do
    covered = 0

    DOC_PATHS.each do |path|
      name = path.sub("/components/", "").tr("_", "-")
      item = ITEMS[name]
      next unless item

      covered += 1

      # Both languages: the install section is one partial, but it is rendered
      # per locale and the file list it prints must not depend on the language.
      [ path, "/pt#{path}" ].each do |localised|
        get localised
        assert_response :success

        assert_match(/shadwire add #{Regexp.escape(name)}/, response.body,
                     "#{localised} does not show its install command")

        item.fetch("files").map { |file| file.fetch("target") }.each do |target|
          assert_includes response.body, target,
                          "#{localised} omits #{target}, which the registry installs"
        end
      end
    end

    assert_operator covered, :>, 20, "expected most doc pages to map to a registry item"
  end

  # Every page the site publishes, guides included, in both languages.
  SITE_PATHS = Rails.application.routes.routes.filter_map { |route|
    path = route.path.spec.to_s.sub("(.:format)", "").sub("(/:locale)", "")
    path if path.match?(%r{\A/(docs|components)(/|\z)}) && route.verb == "GET"
  }.uniq.flat_map { |path| [ path, "/pt#{path}" ] }.freeze

  # Checks on the markup as rendered, one request per page:
  #
  # - No raw ERB in the text a reader sees. An ERB comment ends at the first
  #   `%>` — even one inside an escaped `<%%` — and docs/_table's header comment
  #   printed its own tail, "<% end %> %>", under every reference table on the
  #   site.
  # - No interactive content inside a button or a link (HtmlNesting), which the
  #   browser silently splits apart.
  # - No element left with two classes that set the same thing
  #   (ClassConflicts). The examples pass their widths and alignments to
  #   components that set their own, the way upstream's do; until class_names
  #   merged them, sixty of those overrides lost — the combobox trigger stayed
  #   centred, the ⌘K palette kept the dialog's padding.
  test "no page shows raw ERB, nests interactive content or keeps an overridden class" do
    assert_operator SITE_PATHS.size, :>, 100

    SITE_PATHS.each do |path|
      get path
      assert_response :success

      assert_empty ClassConflicts.in_fragment(Nokogiri::HTML5(response.body)), "#{path} keeps classes a later one overrides"
      assert_empty HtmlNesting.nested_interactive(response.body), "#{path} nests interactive content"

      document = Nokogiri::HTML5(response.body)
      document.css("pre, code, script, style, template, textarea").each(&:remove)
      assert_no_match(/<%|%>/, document.text, "#{path} prints raw ERB")
    end
  end

  test "pages for Stimulus components say so" do
    stimulus_page = DOC_PATHS.find do |path|
      item = ITEMS[path.sub("/components/", "").tr("_", "-")]
      item && item.fetch("files").any? { |f| f.fetch("target").start_with?("app/javascript/") }
    end
    refute_nil stimulus_page, "expected at least one documented Stimulus component"

    get stimulus_page
    assert_match(/Stimulus/, response.body)
  end
end
