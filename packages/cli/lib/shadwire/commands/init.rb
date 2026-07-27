# frozen_string_literal: true

require "json"

module Shadwire
  module Commands
    # Bootstraps a consuming Rails app: writes shadwire.json, installs the base
    # files, and applies the base gems + the Tailwind @import (confirm-then-apply,
    # auto on yes:). Idempotent on re-run; --force resets shadwire.json.
    class Init
      def initialize(root:, registry: nil, yes: false, force: false, json: false,
                     ui: UI.new(yes:), runner: Dependencies::DEFAULT_RUNNER)
        @root = root.to_s
        @registry_override = registry
        @yes = yes
        @force = force
        @json = json
        @ui = ui
        @runner = runner
      end

      def call
        project = Project.new(@root)
        project.raise_unless_rails!

        config = build_config
        client = RegistryClient.new(config.registry)
        base = client.index.fetch("base")

        report = Installer.new(@root, overwrite: :always).install(base.fetch("files"))

        deps = Dependencies.new(project, runner: @runner)
        confirm = ->(desc) { @ui.confirm?(desc) }
        gems = deps.ensure_gems(Array(base["gems"]), yes: @yes, confirm:)
        tailwind = deps.ensure_tailwind_import(
          vendor_css_target(config, base), css_entry: config.tailwind_css, yes: @yes, confirm:
        )

        config.save
        warn_missing_stack(project)
        result = { config:, report:, gems:, tailwind: }
        emit(result)
        Dependencies.raise_on_failure!(gems)

        result
      end

      private

      def build_config
        path = File.join(@root, Config::CONFIG_FILE)
        File.delete(path) if @force && File.exist?(path)
        config = Config.load(@root)
        config.registry = @registry_override if @registry_override
        config
      end

      def vendor_css_target(config, base)
        File.join(config.aliases.fetch("vendorCss", "vendor/shadwire"), base.dig("tailwind", "css"))
      end

      def warn_missing_stack(project)
        unless project.importmap?
          @ui.warn("Warning: importmap-rails not detected — Stimulus controllers won't auto-register.")
        end
        unless project.stimulus?
          @ui.warn("Warning: stimulus-rails not detected — interactive components need Stimulus.")
        end
        unless project.tailwindcss_rails?
          @ui.warn("Warning: tailwindcss-rails not detected — add the Shadwire @import to your CSS manually.")
        end
      end

      def emit(result)
        return @ui.say(JSON.generate(json_payload(result))) if @json

        print_summary(result[:report], result[:gems], result[:tailwind])
      end

      def json_payload(result)
        {
          "created" => result[:report][:written],
          "gems" => { "applied" => result[:gems][:applied], "pending" => result[:gems][:pending],
                      "failed" => result[:gems][:failed] },
          "tailwind" => { "applied" => result[:tailwind][:applied], "manual" => result[:tailwind][:manual] },
          "registry" => result[:config].registry
        }
      end

      def print_summary(report, gems, tailwind)
        @ui.say("Initialized shadwire (#{report[:written].size} base files).")
        report[:written].each { |t| @ui.say("  create  #{t}") }
        gems[:applied].each { |g| @ui.say("  gem     #{g}") }
        gems[:pending].each { |g| @ui.say("  pending #{g} (not installed — run: bundle add #{g})") }
        gems[:failed].each { |g| @ui.say("  FAILED  #{g} (bundle add failed)") }
        (tailwind[:applied]).each { |i| @ui.say("  tailwind #{i}") }
        tailwind[:manual].each { |m| @ui.say("  manual  #{m}") }
      end
    end
  end
end
