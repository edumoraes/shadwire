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

        @ui.say("Files:")
        payload["files"].each { |file| @ui.say("  #{file["target"]}") }

        section("Gems", payload["gems"])
        section("Registry dependencies", payload["registryDependencies"])

        pins = Array(payload["importmap"])
        return if pins.empty?

        @ui.say("Importmap:")
        pins.each { |pin| @ui.say("  #{pin["name"]} → #{pin["to"]}") }
      end

      def section(label, values)
        values = Array(values)
        @ui.say("#{label}: #{values.join(", ")}") unless values.empty?
      end
    end
  end
end
