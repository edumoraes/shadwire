# frozen_string_literal: true

require "json"

module Shadwire
  module Commands
    # Reports the consuming app's Shadwire context: stack detection, the
    # components installed with the helper methods they actually define, and
    # per-component drift.
    #
    # This is the payload the agent skill injects, so it must always succeed. A
    # directory that is not a Rails app, a missing shadwire.json, or an
    # unreachable registry are all reported as data — never raised — because an
    # exception here would leave an agent starting from a backtrace instead of
    # its project context.
    class Status
      def initialize(root:, registry: nil, json: false, ui: UI.new)
        @root = root.to_s
        @registry_override = registry
        @json = json
        @ui = ui
      end

      def call
        project = Project.new(@root)
        config = Config.load(@root)
        result = context(project, config)

        begin
          client = RegistryClient.new(@registry_override || config.registry)
          result["registryVersion"] = client.index["version"]
          result["availableCount"] = Array(client.index["items"]).size
          result["installed"] = installed(config, client)
        rescue Shadwire::Error => e
          result["registryError"] = e.message
        end

        emit(result)
        result
      end

      private

      def context(project, config)
        {
          "rails" => project.rails?,
          "configPresent" => File.exist?(File.join(@root, Config::CONFIG_FILE)),
          "registry" => @registry_override || config.registry,
          "registryVersion" => nil,
          "availableCount" => nil,
          "stack" => {
            "importmap" => project.importmap?,
            "stimulus" => project.stimulus?,
            "tailwindcssRails" => project.tailwindcss_rails?
          },
          "gems" => {
            "view_component" => project.gem?("view_component"),
            "lucide-rails" => project.gem?("lucide-rails")
          },
          "tailwind" => {
            "css" => config.tailwind_css,
            "importPresent" => tailwind_import?(config)
          },
          "helpers" => {
            "includeAllHelpers" => project.include_all_helpers?,
            "legacyHelperPresent" => project.legacy_helper?
          },
          "installed" => []
        }
      end

      def tailwind_import?(config)
        path = File.join(@root, config.tailwind_css)
        File.exist?(path) && File.read(path).include?("shadwire.css")
      end

      def installed(config, client)
        config.installed.map do |name, entry|
          item = client.item(name)
          components = Array(item.dig("api", "components"))

          {
            "name" => name,
            "version" => entry["version"],
            "drift" => drift(item),
            "helpers" => components.filter_map { |component| component["helper"] },
            "classes" => components.filter_map { |component| component["class"] }
          }
        rescue Shadwire::Error
          # The item vanished from the registry; report it rather than failing.
          { "name" => name, "version" => entry["version"], "drift" => "unknown",
            "helpers" => [], "classes" => [] }
        end
      end

      # Worst status across the item's files: missing beats modified beats
      # unchanged, so a single number tells an agent whether to look closer.
      def drift(item)
        statuses = Array(item["files"]).map do |file|
          path = File.join(@root, file["target"])
          next "missing" unless File.exist?(path)

          File.read(path) == file["content"] ? "unchanged" : "modified"
        end

        return "missing" if statuses.include?("missing")

        statuses.include?("modified") ? "modified" : "unchanged"
      end

      def emit(result)
        return @ui.say(JSON.generate(result)) if @json

        human(result)
      end

      def human(result)
        @ui.say("Rails app:  #{yes_no(result["rails"])}    shadwire.json: #{yes_no(result["configPresent"])}")
        @ui.say("Registry:   #{result["registry"]} (#{result["registryVersion"] || "unavailable"})")
        @ui.say("Stack:      importmap=#{result.dig("stack", "importmap")} " \
                "stimulus=#{result.dig("stack", "stimulus")} " \
                "tailwindcss-rails=#{result.dig("stack", "tailwindcssRails")}")
        @ui.say("Installed (#{result["installed"].size} of #{result["availableCount"] || "?"}):")
        result["installed"].each do |item|
          @ui.say("  #{item["drift"].ljust(9)} #{item["name"]}  #{item["helpers"].join(", ")}")
        end

        @ui.warn("Registry unavailable: #{result["registryError"]}") if result["registryError"]
        return unless result.dig("helpers", "legacyHelperPresent")

        @ui.warn("Note: app/helpers/ui_helper.rb is left over from an older install; " \
                 "helpers now live in app/helpers/ui/ and it can be deleted.")
      end

      def yes_no(value)
        value ? "yes" : "no"
      end
    end
  end
end
