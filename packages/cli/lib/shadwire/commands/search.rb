# frozen_string_literal: true

require "json"

module Shadwire
  module Commands
    # Filters the registry catalog by a case-insensitive substring match on an
    # item's name, title, or description. Read-only. With json: true it emits the
    # matching catalog entries; otherwise a "name — title" line each.
    class Search
      SEARCHABLE = %w[name title description].freeze

      def initialize(root:, query:, registry: nil, json: false, ui: UI.new)
        @root = root.to_s
        @query = query.to_s
        @registry_override = registry
        @json = json
        @ui = ui
      end

      def call
        client = RegistryClient.new(@registry_override || Config.load(@root).registry)
        matches = filter(client.index.fetch("items", []))
        emit(matches)
        matches
      end

      private

      def filter(items)
        needle = @query.downcase
        items.select do |item|
          SEARCHABLE.any? { |key| item[key].to_s.downcase.include?(needle) }
        end
      end

      def emit(matches)
        if @json
          @ui.say(JSON.generate(matches))
        elsif matches.empty?
          @ui.say(%(No matches for "#{@query}".))
        else
          matches.each { |item| @ui.say("#{item["name"]} — #{item["title"]}") }
        end
      end
    end
  end
end
