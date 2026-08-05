# frozen_string_literal: true

require "test_helper"

# The catalog blurb of every registry item, in both languages.
#
# registry.json stays canonical and English; config/locales/registry.pt.yml
# carries the Portuguese. That arrangement only holds if a missing translation
# is loud, and by default it is the opposite of loud: config.i18n.fallbacks
# resolves the miss to English, so a component added without a translation would
# render English inside /pt and no page would 500.
class RegistryDescriptionsTest < ActionDispatch::IntegrationTest
  include DocsHelper

  MANIFEST = JSON.parse(DocsHelper::REGISTRY_MANIFEST.read).fetch("items").freeze

  def key_for(name)
    "registry.descriptions.#{name.tr("-", "_")}"
  end

  test "every registry item has a Portuguese description" do
    missing = MANIFEST.reject { |item| I18n.exists?(key_for(item.fetch("name")), :pt) }
                      .map { |item| item.fetch("name") }

    assert_empty missing,
                 "add these to config/locales/registry.pt.yml: #{missing.join(", ")}"
  end

  # The other direction: a component removed from the registry leaves a
  # translation nothing reads.
  test "no Portuguese description describes an item that is gone" do
    names = MANIFEST.map { |item| item.fetch("name").tr("-", "_") }
    orphans = I18n.t("registry.descriptions", locale: :pt).keys.map(&:to_s) - names

    assert_empty orphans,
                 "these are in registry.pt.yml but not in the registry: #{orphans.join(", ")}"
  end

  # A translation that is a copy of the English is a translation that was never
  # written, and the key-set checks above would pass on it.
  test "no Portuguese description is just the English text" do
    untranslated = MANIFEST.select { |item|
      I18n.t(key_for(item.fetch("name")), locale: :pt) == item.fetch("description")
    }.map { |item| item.fetch("name") }

    assert_empty untranslated, "still in English: #{untranslated.join(", ")}"
  end

  test "the English catalog reads from the registry" do
    get components_path

    assert_response :success
    MANIFEST.select { |item| item.fetch("type") == "component" }.each do |item|
      assert_select "nav[aria-label='Components'] a span", text: item.fetch("description")
    end
  end

  test "the Portuguese catalog reads in Portuguese" do
    get "/pt/components"

    assert_response :success
    MANIFEST.select { |item| item.fetch("type") == "component" }.each do |item|
      assert_select "nav[aria-label='Componentes'] a span",
                    text: I18n.t(key_for(item.fetch("name")), locale: :pt)
    end
  end

  # Blocks are registry items too. They used to be described a second time in
  # the locale files, under a different wording than the registry's.
  test "the blocks index describes blocks from the same source" do
    blocks = MANIFEST.select { |item| item.fetch("type") == "block" }
    refute_empty blocks

    get blocks_path
    blocks.each { |block| assert_select "p", text: block.fetch("description") }

    get "/pt/blocks"
    blocks.each do |block|
      assert_select "p", text: I18n.t(key_for(block.fetch("name")), locale: :pt)
    end
  end
end
