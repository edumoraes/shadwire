# frozen_string_literal: true

require Rails.root.join("../lib/shadwire_registry/api_extractor").to_s

# The API reference of a registry item, read off the component source it ships.
#
# The arguments, their defaults and the variant and size names come from the
# same extractor that publishes `api` in the registry, so the table on the page
# is the one `shadwire info` prints and cannot fall behind the code. Only the
# one-line descriptions are written by hand, in the locale files under
# components.api_docs.
module DocsComponentApi
  ROOT = Rails.root.join("..").freeze
  REGISTRY = ROOT.join("registry/registry.json").freeze
  HELPERS_GLOB = ROOT.join("registry/rails/ui/helpers/ui/*.rb").to_s.freeze

  # Class names in the table drop the namespace and suffix every one of them
  # shares: Ui::ToggleGroup::ItemComponent reads as ToggleGroup::Item.
  Part = Data.define(:name, :helper, :props, :variants, :sizes)
  Prop = Data.define(:name, :default)

  module_function

  # The item's own components, in manifest order — the root first. Parts it
  # bundles from other items (a Button inside a trigger, the Icon) are
  # documented on their own pages.
  def parts(item_name)
    item = items[item_name.to_s]
    return [] unless item

    snake = item.fetch("name").tr("-", "_")
    item.fetch("files").filter_map do |file|
      source = file.fetch("source")
      next unless own_component?(source, snake)

      part(source)
    end
  end

  # Every argument the item's components take, besides class/class_name.
  def props(item_name)
    parts(item_name).flat_map(&:props)
  end

  def part(source)
    api = ShadwireRegistry::ApiExtractor.call(source: ROOT.join(source).read, path: source)
    Part.new(
      name: api.fetch("class").delete_prefix("Ui::").delete_suffix("Component"),
      helper: helpers[api.fetch("class")],
      props: api.fetch("props").reject { |prop| prop.fetch("name") == "class_name" }
               .map { |prop| Prop.new(name: prop.fetch("name"), default: prop.fetch("default")) },
      variants: api.fetch("variants"),
      sizes: api.fetch("sizes")
    )
  end

  # A root is named after the item; parts live in a directory of that name, or
  # share its prefix when the item has no root of its own (resizable).
  def own_component?(source, snake)
    return false unless source.include?("/components/") && source.end_with?(".rb")

    source.end_with?("/components/#{snake}_component.rb") ||
      source.include?("/components/#{snake}/") ||
      File.basename(source).start_with?("#{snake}_")
  end

  # A default as the reader would write it: the literal from the signature, or
  # the English text an I18n.t(..., default:) call falls back to.
  def display_default(prop)
    literal = prop.default
    return "—" if literal.nil?

    literal[/\AI18n\.t\(.*default:\s*("(?:[^"\\]|\\.)*")\s*\)\z/, 1] || literal
  end

  def items
    @items ||= JSON.parse(REGISTRY.read).fetch("items").index_by { |item| item.fetch("name") }
  end

  # Component class => ui_* helper, paired the way bin/build_registry pairs them.
  def helpers
    @helpers ||= Dir[HELPERS_GLOB].each_with_object({}) do |file, index|
      File.read(file).scan(/def (ui_\w+)[\s\S]*?(Ui::[A-Za-z0-9:]*Component)/).each do |helper, klass|
        index[klass] ||= helper
      end
    end
  end
end
