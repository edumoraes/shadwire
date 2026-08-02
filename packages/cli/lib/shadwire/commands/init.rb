# frozen_string_literal: true

require "json"

module Shadwire
  module Commands
    # Bootstraps a consuming Rails app: writes shadwire.json, installs the base
    # files, and applies the base gems + the Tailwind @import (confirm-then-apply,
    # auto on yes:). Idempotent on re-run; --force resets shadwire.json.
    class Init
      # The CLI gem is a development-time tool for the app, deliberately kept out
      # of registry.json: the registry's gems are what the *components* need at
      # runtime, and installed files carry no Shadwire dependency.
      CLI_GEM = "shadwire"
      CLI_GEM_GROUP = "development"

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
        base_gems = deps.ensure_gems(Array(base["gems"]), yes: @yes, confirm:)
        cli_gem = deps.ensure_gems([CLI_GEM], yes: @yes, confirm:, group: CLI_GEM_GROUP)
        gems = merge_gem_results(base_gems, cli_gem)
        tailwind = deps.ensure_tailwind_import(
          vendor_css_target(config, base), css_entry: config.tailwind_css, yes: @yes, confirm:
        )
        binstub = write_binstub(cli_gem)

        config.save
        warn_missing_stack(project)
        result = { config:, report:, gems:, tailwind:, binstub: }
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

      def merge_gem_results(*results)
        %i[applied skipped pending manual failed]
          .to_h { |key| [key, results.flat_map { |result| result[key] }] }
      end

      # Only write the binstub once `shadwire` is actually declared in the app's
      # Gemfile — a bundler binstub without it raises Gem::LoadError on first run.
      #
      # The gate reads the ensure_gems result rather than re-reading the Gemfile:
      # it is a direct record of what the command did, and it does not depend on
      # `bundle add` writing a line the Project#gem? regex recognizes.
      def write_binstub(cli_gem)
        present = (cli_gem[:applied] + cli_gem[:skipped]).include?(CLI_GEM)
        return { status: :unavailable } unless present

        Binstub.write(@root, force: @force)[:written] ? { status: :written } : { status: :skipped }
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

        print_summary(result[:report], result[:gems], result[:tailwind], result[:binstub])
      end

      def json_payload(result)
        {
          "created" => result[:report][:written],
          "gems" => { "applied" => result[:gems][:applied], "pending" => result[:gems][:pending],
                      "failed" => result[:gems][:failed] },
          "tailwind" => { "applied" => result[:tailwind][:applied], "manual" => result[:tailwind][:manual] },
          "binstub" => { "path" => Binstub::PATH,
                         "written" => result[:binstub][:status] == :written,
                         "skipped" => result[:binstub][:status] == :skipped },
          "registry" => result[:config].registry
        }
      end

      def print_summary(report, gems, tailwind, binstub)
        @ui.say("Initialized shadwire (#{report[:written].size} base files).")
        report[:written].each { |t| @ui.say("  create  #{t}") }
        gems[:applied].each { |g| @ui.say("  gem     #{g}") }
        gems[:pending].each { |g| @ui.say("  pending #{g} (not installed — run: bundle add #{g})") }
        gems[:failed].each { |g| @ui.say("  FAILED  #{g} (bundle add failed)") }
        (tailwind[:applied]).each { |i| @ui.say("  tailwind #{i}") }
        tailwind[:manual].each { |m| @ui.say("  manual  #{m}") }
        print_binstub(binstub)
      end

      def print_binstub(binstub)
        case binstub[:status]
        when :written then @ui.say("  create  #{Binstub::PATH}")
        when :skipped then @ui.say("  skip    #{Binstub::PATH} (already exists)")
        when :unavailable
          @ui.say("  manual  #{Binstub::PATH} (add `gem \"#{CLI_GEM}\"` to the Gemfile, then re-run init)")
        end
      end
    end
  end
end
