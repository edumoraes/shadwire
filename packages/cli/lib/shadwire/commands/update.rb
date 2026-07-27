# frozen_string_literal: true

require "json"

module Shadwire
  module Commands
    # Re-applies the registry version of installed components. With no names it
    # updates every installed item. It surfaces local drift (via Differ) before
    # writing so edits are never clobbered silently, then reuses add's overwrite
    # policy, dependency handling, and installed bookkeeping. --yes/--overwrite
    # skip the per-file prompt; --no-deps limits the update to the named items.
    class Update
      def initialize(root:, names: [], yes: false, overwrite: false, no_deps: false,
                     registry: nil, json: false, ui: UI.new(yes:), runner: Dependencies::DEFAULT_RUNNER)
        @root = root.to_s
        @names = names
        @yes = yes
        @overwrite = overwrite
        @no_deps = no_deps
        @registry_override = registry
        @json = json
        @ui = ui
        @runner = runner
      end

      def call
        project = Project.new(@root)
        project.raise_unless_rails!

        config = Config.load(@root)
        client = RegistryClient.new(@registry_override || config.registry)
        targets = resolve_targets(config)

        items = resolve_items(targets, client)
        files = items.flat_map { |item| item.fetch("files") }

        diffs = compute_diffs(files) # read local drift before any overwrite
        report = install_files(files)

        deps = Dependencies.new(project, runner: @runner)
        dep_confirm = ->(desc) { @ui.confirm?(desc) }
        gems = deps.ensure_gems(union(items, "gems"), yes: @yes, confirm: dep_confirm)
        pins = deps.ensure_importmap_pins(union(items, "importmap"), yes: @yes, confirm: dep_confirm)

        record_installed(config, client, targets, items)
        config.save

        result = { updated: targets, report:, gems:, pins:, diffs: }
        emit(result)
        Dependencies.raise_on_failure!(gems, pins)

        result
      end

      private

      def resolve_targets(config)
        targets = @names.empty? ? config.installed.keys : @names
        targets.each do |name|
          raise Shadwire::Error, "#{name} is not installed" unless config.installed.key?(name)
        end
        targets
      end

      def resolve_items(targets, client)
        @no_deps ? targets.map { |name| client.item(name) } : Resolver.expand(targets, client)
      end

      def compute_diffs(files)
        diffs = {}
        files.each do |file|
          target = file["target"]
          path = File.join(@root, target)
          next unless File.exist?(path)

          local = File.read(path)
          diffs[target] = Differ.unified(local, file["content"], path: target) unless local == file["content"]
        end
        diffs
      end

      def install_files(files)
        if @yes || @overwrite
          Installer.new(@root, overwrite: :always).install(files)
        else
          Installer.new(@root, overwrite: :prompt, confirm: content_aware_confirm(files)).install(files)
        end
      end

      # Skips files whose on-disk content already matches the registry; prompts
      # only for locally-modified files.
      def content_aware_confirm(files)
        by_target = files.to_h { |file| [file["target"], file["content"]] }
        lambda do |target|
          current = File.read(File.join(@root, target))
          return false if current == by_target[target]

          @ui.confirm?("Overwrite modified #{target}?")
        end
      end

      def union(items, key)
        items.flat_map { |item| Array(item[key]) }.uniq
      end

      def record_installed(config, client, targets, items)
        by_name = items.to_h { |item| [item["name"], item] }
        version = client.index["version"]
        targets.each do |name|
          item = by_name[name] || client.item(name)
          file_targets = item.fetch("files").map { |file| file["target"] }
          config.record_installed(name, version, file_targets)
        end
      end

      def emit(result)
        return @ui.say(JSON.generate(json_payload(result))) if @json

        human(result)
      end

      # `overwritten` is the whole point: update clobbers local edits, and the
      # human path prints the diff. Omitting it from JSON let an agent destroy
      # customizations without ever being told they existed.
      def json_payload(result)
        {
          updated: result[:updated],
          written: result[:report][:written],
          skipped: result[:report][:skipped],
          overwritten: result[:diffs].keys & result[:report][:written],
          diffs: result[:diffs],
          gems: result[:gems][:applied],
          gemsFailed: result[:gems][:failed],
          pins: result[:pins][:applied],
          pinsFailed: result[:pins][:failed]
        }
      end

      def human(result)
        @ui.say("Updated #{result[:updated].join(", ")}.")
        result[:diffs].each_value { |rendered| @ui.say(rendered) }
        result[:report][:written].each { |target| @ui.say("  write   #{target}") }
        result[:report][:skipped].each { |target| @ui.say("  skip    #{target}") }
      end
    end
  end
end
