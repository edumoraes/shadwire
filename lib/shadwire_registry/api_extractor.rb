# frozen_string_literal: true

require "prism"

module ShadwireRegistry
  # Derives a component's public API from its own source so the published
  # registry can never drift from the code it ships. Pure: takes source text,
  # returns a Hash.
  #
  #   {
  #     "class"    => "Ui::ButtonComponent",
  #     "variants" => ["default", "destructive", ...],   # VARIANTS keys, in source order
  #     "sizes"    => ["default", "sm", "lg", "icon"],   # SIZES keys
  #     "props"    => [{ "name" => "tag", "default" => ":button" }, ...],
  #     "attrs"    => true                                # accepts free HTML attributes
  #   }
  #
  # Runs in repo tooling only (bin/build_registry, Ruby 3.4). Prism is stdlib
  # from Ruby 3.3, while the shipped gem supports >= 3.2 — so this must never be
  # required from packages/cli. The CLI consumes the generated result instead.
  module ApiExtractor
    # Class-body constants whose hash keys are part of the public API.
    VARIANT_CONSTANTS = { "VARIANTS" => "variants", "SIZES" => "sizes" }.freeze

    class << self
      def call(source:, path: nil)
        result = Prism.parse(source)
        raise ArgumentError, "unparsable component source: #{path}" if result.failure?

        root = result.value

        api = { "class" => class_name(root), "variants" => [], "sizes" => [], "props" => [], "attrs" => false }
        variant_lists(root).each { |key, values| api[key] = values }
        api.merge!(initialize_signature(root))
        api
      end

      private

      # Joins the enclosing module/class path: `module Ui` + `class ButtonComponent`
      # becomes "Ui::ButtonComponent", and a nested `module Card` yields
      # "Ui::Card::HeaderComponent".
      def class_name(root)
        names = []
        visit = lambda do |node|
          names << node.constant_path.slice if node.is_a?(Prism::ModuleNode) || node.is_a?(Prism::ClassNode)
          node.compact_child_nodes.each { |child| visit.call(child) }
        end
        visit.call(root)

        names.empty? ? nil : names.join("::")
      end

      def variant_lists(root)
        descendants(root, Prism::ConstantWriteNode).filter_map do |node|
          key = VARIANT_CONSTANTS[node.name.to_s]
          next unless key

          hash = unwrap_freeze(node.value)
          next unless hash.is_a?(Prism::HashNode)

          [key, hash.elements.filter_map { |element| hash_key(element) }]
        end
      end

      # `{ ... }.freeze` — read through the freeze call to the literal.
      def unwrap_freeze(node)
        node.is_a?(Prism::CallNode) && node.name == :freeze ? node.receiver : node
      end

      def hash_key(element)
        return unless element.respond_to?(:key)

        key = element.key
        key.respond_to?(:unescaped) ? key.unescaped : nil
      end

      # Keyword arguments are the component's props. A keyword with no default is
      # required and publishes a nil default; `**attrs` becomes attrs: true.
      def initialize_signature(root)
        definition = descendants(root, Prism::DefNode).find { |node| node.name == :initialize }
        parameters = definition&.parameters
        return {} unless parameters

        props = parameters.keywords.map do |keyword|
          default = keyword.respond_to?(:value) && keyword.value ? keyword.value.slice : nil
          { "name" => keyword.name.to_s.delete_suffix(":"), "default" => default }
        end

        { "props" => props, "attrs" => !parameters.keyword_rest.nil? }
      end

      def descendants(node, type, found = [])
        found << node if node.is_a?(type)
        node.compact_child_nodes.each { |child| descendants(child, type, found) }
        found
      end
    end
  end
end
