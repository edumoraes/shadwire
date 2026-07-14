# frozen_string_literal: true

require "json"

module Shadwire
  module Commands
    # Lists the registry catalog: one entry (name/type/title/description) per
    # published item. Read-only — needs a registry but no Rails app. With
    # json: true it emits the catalog array; otherwise a "name — title" line each.
    class List
      def initialize(root:, registry: nil, json: false, ui: UI.new)
        @root = root.to_s
        @registry_override = registry
        @json = json
        @ui = ui
      end

      def call
        client = RegistryClient.new(@registry_override || Config.load(@root).registry)
        items = client.index.fetch("items", [])
        emit(items)
        items
      end

      private

      def emit(items)
        if @json
          @ui.say(JSON.generate(items))
        else
          items.each { |item| @ui.say("#{item["name"]} — #{item["title"]}") }
        end
      end
    end
  end
end
