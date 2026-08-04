# frozen_string_literal: true

require "test_helper"

# The sidebar is built from registry/registry.json, so a component added to the
# registry must also get a route and a documentation page. These tests fail when
# the three drift apart.
class DocsNavHelperTest < ActionView::TestCase
  include DocsNavHelper
  include DocsHelper

  test "every registry component has a sidebar entry" do
    registry_names = docs_component_items.map { |item| item.fetch("name") }
    nav_paths = docs_nav_components_group[:items].map { |item| item[:path] }

    registry_names.each do |name|
      assert_includes nav_paths, "/components/#{name}",
                      "#{name} is in the registry but not in the documentation sidebar"
    end
  end

  test "every sidebar entry resolves to a route" do
    docs_nav_items.each do |item|
      assert Rails.application.routes.recognize_path(item[:path]),
             "#{item[:title]} points at #{item[:path]}, which no route serves"
    end
  end

  test "the component group is alphabetical after the catalog index" do
    items = docs_nav_components_group[:items]

    assert_equal "Visão geral", items.first[:title]
    titles = items.drop(1).map { |item| item[:title] }
    assert_equal titles.sort_by(&:downcase), titles
  end

  test "the flattened order starts at the introduction" do
    assert_equal "/docs", docs_nav_items.first[:path]
  end

  test "sidebar entries are unique" do
    paths = docs_nav_items.map { |item| item[:path] }

    assert_equal paths.uniq, paths, "the sidebar lists the same page twice"
  end
end
