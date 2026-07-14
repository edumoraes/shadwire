# frozen_string_literal: true

require "json"

module Shadwire
  module Commands
    # Reports how installed files have drifted from the registry: for each file
    # of each requested (or, with no names, every installed) item, compares the
    # local bytes to the freshly fetched registry content. Status per file is
    # "unchanged", "modified", or "missing". Read-only — never writes.
    class Diff
      def initialize(root:, names: [], registry: nil, json: false, ui: UI.new)
        @root = root.to_s
        @names = names
        @registry_override = registry
        @json = json
        @ui = ui
      end

      def call
        config = Config.load(@root)
        client = RegistryClient.new(@registry_override || config.registry)

        entries = []
        diffs = {}
        resolve_names(config).each do |name|
          client.item(name).fetch("files").each do |file|
            target = file["target"]
            status, rendered = compare(target, file["content"])
            entries << { name:, file: target, status: }
            diffs["#{name}:#{target}"] = rendered if status == "modified"
          end
        end

        drifted = entries.any? { |entry| entry[:status] != "unchanged" }
        emit(entries, diffs)
        { entries:, diffs:, drifted: }
      end

      private

      def resolve_names(config)
        names = @names.empty? ? config.installed.keys : @names
        names.each do |name|
          raise Shadwire::Error, "#{name} is not installed" unless config.installed.key?(name)
        end
        names
      end

      def compare(target, registry_content)
        path = File.join(@root, target)
        return ["missing", nil] unless File.exist?(path)

        local = File.read(path)
        return ["unchanged", nil] if local == registry_content

        ["modified", Differ.unified(local, registry_content, path: target)]
      end

      def emit(entries, diffs)
        return @ui.say(JSON.generate(entries)) if @json

        entries.each { |entry| @ui.say("#{entry[:status].ljust(9)} #{entry[:name]}  #{entry[:file]}") }
        diffs.each_value { |rendered| @ui.say(rendered) if rendered && !rendered.empty? }
      end
    end
  end
end
