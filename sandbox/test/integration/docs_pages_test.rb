# frozen_string_literal: true

require "test_helper"

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
  # covered the moment it is routed.
  DOC_PATHS = Rails.application.routes.routes.filter_map { |route|
    path = route.path.spec.to_s.sub("(.:format)", "")
    path if path.start_with?("/components/") && route.verb == "GET"
  }.uniq.freeze

  test "every component documentation page renders" do
    refute_empty DOC_PATHS, "expected component documentation routes"

    DOC_PATHS.each do |path|
      get path
      assert_response :success, "#{path} did not render"
    end
  end

  test "documentation pages never advertise the removed monolithic helper" do
    DOC_PATHS.each do |path|
      get path
      assert_no_match %r{app/helpers/ui_helper\.rb}, response.body,
                      "#{path} still lists the removed app/helpers/ui_helper.rb"
    end
  end

  # Deliberately literal. A fuzzy pattern here matched "cli" inside "clipboard"
  # and flagged an example that legitimately reads "Enterprise (em breve)".
  STALE_CLAIMS = [
    "CLI de instalação ainda está por vir",
    "bin/sync_registry" # the monorepo's internal dev script, not a user command
  ].freeze

  test "documentation pages never advertise a stale install story" do
    DOC_PATHS.each do |path|
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
      get path
      assert_response :success

      assert_match(/shadwire add #{Regexp.escape(name)}/, response.body,
                   "#{path} does not show its install command")

      item.fetch("files").map { |file| file.fetch("target") }.each do |target|
        assert_includes response.body, target,
                        "#{path} omits #{target}, which the registry installs"
      end
    end

    assert_operator covered, :>, 20, "expected most doc pages to map to a registry item"
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
