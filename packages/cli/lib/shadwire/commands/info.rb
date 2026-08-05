# frozen_string_literal: true

require "json"

module Shadwire
  module Commands
    # Shows one item's metadata: type, title, description, file targets, gems,
    # importmap pins, and registry dependencies. Read-only. The file bodies
    # (`content`) are stripped so both the JSON and human output stay a manifest,
    # not a payload. An unknown name propagates RegistryError from the client.
    class Info
      def initialize(root:, name:, registry: nil, json: false, ui: UI.new)
        @root = root.to_s
        @name = name
        @registry_override = registry
        @json = json
        @ui = ui
      end

      def call
        client = RegistryClient.new(@registry_override || Config.load(@root).registry)
        payload = strip_content(client.item(@name))
        emit(payload)
        payload
      end

      private

      def strip_content(item)
        payload = item.dup
        payload["files"] = Array(item["files"]).map { |file| file.reject { |key, _| key == "content" } }
        payload
      end

      def emit(payload)
        return @ui.say(JSON.generate(payload)) if @json

        human(payload)
      end

      def human(payload)
        @ui.say("#{payload["name"]} (#{payload["type"]}) — #{payload["title"]}")
        @ui.say(payload["description"]) if payload["description"]
        @ui.say("When to use: #{payload["whenToUse"]}") if payload["whenToUse"]

        components(payload)

        @ui.say("Files:")
        payload["files"].each { |file| @ui.say("  #{file["target"]}") }

        section("Gems", payload["gems"])
        section("Registry dependencies", payload["registryDependencies"])
        @ui.say("Requires Stimulus: yes (needs importmap with eager loading)") if payload["requiresStimulus"]

        pins = Array(payload["importmap"])
        unless pins.empty?
          @ui.say("Importmap:")
          pins.each { |pin| @ui.say("  #{pin["name"]} → #{pin["to"]}") }
        end

        usage(payload)
        licence(payload)
      end

      # The terms ride on the published item, so `info` can answer "what am I
      # about to copy into this codebase" without leaving the CLI. Older
      # registries predate the field, so its absence is not an error.
      def licence(payload)
        return unless payload["license"]

        url = payload["licenseUrl"]
        @ui.say("License: #{payload["license"]}#{url ? " (#{url})" : ""}")

        attribution = payload["attribution"]
        return unless attribution

        @ui.say("  Ported from #{attribution["derivedFrom"]} (#{attribution["url"]}), #{attribution["license"]}.")
        @ui.say("  #{attribution["notice"]}") if attribution["notice"]
      end

      # The generated API: what to call and what it accepts. Roots first, so the
      # entry point is obvious before its composition parts.
      def components(payload)
        entries = Array(payload.dig("api", "components")).reject { |entry| entry["helper"].nil? }
        return if entries.empty?

        @ui.say("Components:")
        entries.sort_by { |entry| entry["root"] ? 0 : 1 }.each do |entry|
          @ui.say("  #{entry["class"]} — #{entry["helper"]}")
          @ui.say("    variants: #{entry["variants"].join(" | ")}") if entry["variants"]&.any?
          @ui.say("    sizes:    #{entry["sizes"].join(" | ")}") if entry["sizes"]&.any?
          props = Array(entry["props"]).map { |prop| prop["default"] ? "#{prop["name"]}: #{prop["default"]}" : "#{prop["name"]}:" }
          @ui.say("    props:    #{props.join(", ")}") unless props.empty?
        end
      end

      def usage(payload)
        snippets = Array(payload["usage"])
        return if snippets.empty?

        @ui.say("Usage:")
        # Blank line between snippets: items that document several recipes
        # (date-picker) would otherwise print as one wall of ERB.
        snippets.each_with_index do |snippet, index|
          @ui.say("") unless index.zero?
          @ui.say(snippet.lines.map { |line| "  #{line}" }.join.chomp)
        end
      end

      def section(label, values)
        values = Array(values)
        @ui.say("#{label}: #{values.join(", ")}") unless values.empty?
      end
    end
  end
end
