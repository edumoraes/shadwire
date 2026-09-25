# frozen_string_literal: true

require "test_helper"
require_relative "../support/html_nesting"

# The `usage` snippets registry.json publishes, rendered as they are.
#
# They are the first code anyone copies: the CLI's `info`, llms.txt and the
# agent skill all print them. Nine of them nested a ui_button inside a trigger
# that is already a button — the browser splits that into an empty trigger and a
# button that opens nothing. The radio group's raised on a missing `name:`, the
# input OTP's passed an argument the component does not take, and the hover
# card's put a link inside its link trigger. RegistrySchemaTest reads the
# snippets as text; this is the only place they are run.
class RegistryUsageTest < ActionDispatch::IntegrationTest
  ITEMS = JSON.parse(Rails.root.join("../registry/registry.json").read).fetch("items").freeze

  ITEMS.each do |item|
    Array(item["usage"]).each_with_index do |snippet, index|
      define_method("test_#{item.fetch("name").tr("-", "_")}_usage_#{index + 1}_renders") do
        html = render_snippet(snippet, item.fetch("name"))

        assert html.strip.present?, "#{item.fetch("name")} usage #{index + 1} rendered nothing"
        assert_empty HtmlNesting.nested_interactive(html),
                     "#{item.fetch("name")} usage #{index + 1} nests interactive content:\n#{snippet}"
      end
    end
  end

  test "every component item publishes a snippet this test runs" do
    components = ITEMS.select { |item| item.fetch("type") == "component" }

    assert_empty components.select { |item| Array(item["usage"]).empty? }.map { |item| item.fetch("name") }
  end

  # Guards the guard: the nesting the snippets used to publish.
  test "the nesting check sees a button inside a trigger" do
    html = render_snippet(<<~ERB, "dialog")
      <%= ui_dialog do %>
        <%= ui_dialog_trigger { ui_button { "Open" } } %>
      <% end %>
    ERB

    assert_equal [ "<button> inside <button>" ], HtmlNesting.nested_interactive(html)
  end

  private

  def render_snippet(snippet, name)
    ApplicationController.render(inline: snippet, layout: false)
  rescue StandardError, SyntaxError => error
    flunk "#{name} usage raised #{error.class}: #{error.message}\n#{snippet}"
  end
end
