# frozen_string_literal: true

module Shadwire
  module Commands
    # Installs one or more components and their transitive registry
    # dependencies: writes files (overwrite policy from flags, content-aware
    # prompting), applies the union of gems + importmap pins, and records each
    # named component in shadwire.json.
    class Add
      def initialize(root:, names:, yes: false, overwrite: false, no_deps: false,
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

        items = resolve_items(client)
        files = items.flat_map { |item| item.fetch("files") }
        report = install_files(files)

        deps = Dependencies.new(project, runner: @runner)
        dep_confirm = ->(desc) { @ui.confirm?(desc) }
        gems = deps.ensure_gems(union(items, "gems"), yes: @yes, confirm: dep_confirm)
        pins = deps.ensure_importmap_pins(union(items, "importmap"), yes: @yes, confirm: dep_confirm)

        record_installed(config, client, items)
        config.save

        result = { report:, gems:, pins: }
        emit(result)
        Dependencies.raise_on_failure!(gems, pins)

        result
      end

      private

      def resolve_items(client)
        @no_deps ? @names.map { |name| client.item(name) } : Resolver.expand(@names, client)
      end

      def union(items, key)
        items.flat_map { |item| Array(item[key]) }.uniq
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

      def record_installed(config, client, items)
        by_name = items.to_h { |item| [item["name"], item] }
        version = client.index["version"]
        @names.each do |name|
          item = by_name[name] || client.item(name)
          targets = item.fetch("files").map { |file| file["target"] }
          config.record_installed(name, version, targets)
        end
      end

      def emit(result)
        return @ui.say(JSON.generate(json_payload(result))) if @json

        print_summary(result[:report], result[:gems], result[:pins])
      end

      def json_payload(result)
        {
          "added" => @names,
          "written" => result[:report][:written],
          "skipped" => result[:report][:skipped],
          "gems" => slice_deps(result[:gems]),
          "pins" => slice_deps(result[:pins])
        }
      end

      def slice_deps(deps)
        { "applied" => deps[:applied], "pending" => deps[:pending],
          "failed" => deps[:failed], "manual" => deps[:manual] }
      end

      def print_summary(report, gems, pins)
        @ui.say("Added #{@names.join(", ")}.")
        report[:written].each { |t| @ui.say("  write   #{t}") }
        report[:skipped].each { |t| @ui.say("  skip    #{t}") }
        gems[:applied].each { |g| @ui.say("  gem     #{g}") }
        gems[:pending].each { |g| @ui.say("  pending #{g} (not installed — run: bundle add #{g})") }
        gems[:failed].each { |g| @ui.say("  FAILED  #{g} (bundle add failed)") }
        pins[:applied].each { |p| @ui.say("  pin     #{p}") }
        pins[:pending].each { |p| @ui.say("  pending pin #{p}") }
        (gems[:manual] + pins[:manual]).each { |m| @ui.say("  manual  #{m}") }
      end
    end
  end
end
