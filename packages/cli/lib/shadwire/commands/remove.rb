# frozen_string_literal: true

require "json"

module Shadwire
  module Commands
    # Uninstalls one or more components. It deletes only files unique to the
    # removed items — never the shared base (ui_component/ui_helper/shadwire.css)
    # and never a file still listed by another installed entry — then prunes any
    # emptied directory under the components root and drops the items from
    # shadwire.json. Importmap pins that no remaining component uses are reported
    # (not auto-removed — dep cleanup is left to the user). Confirms first unless
    # --yes.
    class Remove
      def initialize(root:, names:, yes: false, registry: nil, json: false, ui: UI.new(yes:))
        @root = root.to_s
        @names = names
        @yes = yes
        @registry_override = registry
        @json = json
        @ui = ui
      end

      def call
        raise Shadwire::Error, "remove requires at least one component name" if @names.empty?

        Project.new(@root).raise_unless_rails!
        config = Config.load(@root)
        client = RegistryClient.new(@registry_override || config.registry)
        @names.each do |name|
          raise Shadwire::Error, "#{name} is not installed" unless config.installed.key?(name)
        end

        base_targets = client.index.fetch("base").fetch("files").map { |file| file["target"] }
        removed_targets = targets_for(config, @names)
        remaining = config.installed.keys - @names
        other_targets = targets_for(config, remaining)

        deletable = (removed_targets - base_targets - other_targets).select { |target| on_disk?(target) }
        kept_shared = base_targets & removed_targets

        unless @yes || @ui.confirm?("Remove #{deletable.size} files for #{@names.join(", ")}?")
          @ui.say("Aborted; nothing removed.")
          return { removed: [], deleted: [], keptShared: kept_shared, unusedPins: [] }
        end

        deletable.each { |target| File.delete(File.join(@root, target)) }
        prune_empty_dirs(deletable, config)

        @names.each { |name| config.forget(name) }
        config.save

        result = {
          removed: @names,
          deleted: deletable,
          keptShared: kept_shared,
          unusedPins: unused_pins(client, remaining)
        }
        emit(result)
        result
      end

      private

      def targets_for(config, names)
        names.flat_map { |name| config.installed[name]["files"] }.uniq
      end

      def on_disk?(target)
        File.exist?(File.join(@root, target))
      end

      # Removes now-empty directories from each deleted file's dir upward, bounded
      # strictly inside the components root (never the root itself or above).
      def prune_empty_dirs(deleted, config)
        components_root = File.expand_path(File.join(@root, config.aliases.fetch("components", "app/components")))
        deleted.each do |target|
          dir = File.dirname(File.expand_path(File.join(@root, target)))
          while dir.start_with?("#{components_root}#{File::SEPARATOR}") && File.directory?(dir) && Dir.empty?(dir)
            Dir.rmdir(dir)
            dir = File.dirname(dir)
          end
        end
      end

      # Pins of the removed items that no still-installed item pins.
      def unused_pins(client, remaining)
        remaining_names = remaining.map { |name| pins_for(client, name).map { |pin| pin["name"] } }.flatten
        @names.flat_map { |name| pins_for(client, name) }
              .reject { |pin| remaining_names.include?(pin["name"]) }
              .uniq
      end

      def pins_for(client, name)
        Array(client.item(name)["importmap"])
      end

      def emit(result)
        return @ui.say(JSON.generate(result)) if @json

        human(result)
      end

      def human(result)
        return if result[:removed].empty?

        @ui.say("Removed #{result[:removed].join(", ")}.")
        result[:deleted].each { |target| @ui.say("  delete  #{target}") }
        result[:keptShared].each { |target| @ui.say("  keep    #{target} (shared)") }
        result[:unusedPins].each do |pin|
          @ui.say(%(  note    importmap pin "#{pin["name"]}" is now unused; review config/importmap.rb))
        end
      end
    end
  end
end
