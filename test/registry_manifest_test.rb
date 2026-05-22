# frozen_string_literal: true

require "json"
require "minitest/autorun"
require "pathname"

class RegistryManifestTest < Minitest::Test
  ROOT = Pathname.new(__dir__).join("..").expand_path
  REGISTRY = JSON.parse(ROOT.join("registry/registry.json").read)

  def test_all_declared_sources_exist
    REGISTRY.fetch("items").each do |item|
      item.fetch("files").each do |file|
        source = ROOT.join(file.fetch("source"))
        assert source.file?, "#{item.fetch("name")} source missing: #{source.relative_path_from(ROOT)}"
      end
    end
  end

  def test_all_targets_are_app_relative_or_vendor_relative
    allowed_prefixes = ["app/", "vendor/"]

    REGISTRY.fetch("items").each do |item|
      item.fetch("files").each do |file|
        target = file.fetch("target")
        assert allowed_prefixes.any? { |prefix| target.start_with?(prefix) }, "#{item.fetch("name")} target is outside install roots: #{target}"
      end
    end
  end

  def test_each_item_includes_shared_component_helper_and_style
    REGISTRY.fetch("items").each do |item|
      sources = item.fetch("files").map { |file| file.fetch("source") }

      assert_includes sources, "registry/rails/ui/components/ui_component.rb"
      assert_includes sources, "registry/rails/ui/helpers/ui_helper.rb"
      assert_includes sources, "registry/rails/ui/styles/shadwire.css"
    end
  end

  def test_theme_css_uses_the_shadcn_two_layer_token_structure
    css = ROOT.join("registry/rails/ui/styles/shadwire.css").read

    assert_includes css, "@custom-variant dark", "missing class-based dark variant"
    assert_includes css, "@theme inline", "missing @theme inline token mapping layer"
    assert_match(/^:root\s*\{/, css, "missing :root raw token block")
    assert_match(/^\.dark\s*\{/, css, "missing .dark raw token override block")
  end
end
