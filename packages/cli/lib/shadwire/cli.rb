# frozen_string_literal: true

require "thor"

module Shadwire
  class CLI < Thor
    package_name "shadwire"

    def self.exit_on_failure? = true

    class_option :cwd, type: :string,
                       desc: "Run against this app directory (default: current directory)"

    desc "version", "Print the shadwire version"
    def version
      puts Shadwire::VERSION
    end

    desc "init", "Bootstrap shadwire in a Rails app (config, base files, base deps)"
    method_option :yes, type: :boolean, default: false, aliases: "-y",
                        desc: "Apply dependency changes without prompting"
    method_option :registry, type: :string, desc: "Registry base URL to install from"
    method_option :force, type: :boolean, default: false,
                          desc: "Overwrite an existing shadwire.json"
    def init
      run_command do |root, ui|
        Commands::Init.new(
          root:, registry: options[:registry], yes: options[:yes],
          force: options[:force], ui:
        ).call
      end
    end

    desc "add NAME...", "Install components and their registry dependencies"
    method_option :yes, type: :boolean, default: false, aliases: "-y",
                        desc: "Apply file/dependency changes without prompting"
    method_option :overwrite, type: :boolean, default: false,
                              desc: "Overwrite locally-modified files without prompting"
    method_option :deps, type: :boolean, default: true,
                         desc: "Install transitive registry dependencies (--no-deps to skip)"
    method_option :registry, type: :string, desc: "Registry base URL to install from"
    def add(*names)
      raise Shadwire::Error, "add requires at least one component name" if names.empty?

      run_command do |root, ui|
        Commands::Add.new(
          root:, names:, yes: options[:yes], overwrite: options[:overwrite],
          no_deps: !options[:deps], registry: options[:registry], ui:
        ).call
      end
    end

    desc "list", "List every component in the registry catalog"
    method_option :registry, type: :string, desc: "Registry base URL to read from"
    method_option :json, type: :boolean, default: false, desc: "Emit machine-readable JSON"
    def list
      run_command do |root, ui|
        Commands::List.new(root:, registry: options[:registry], json: options[:json], ui:).call
      end
    end

    desc "search QUERY", "Search the catalog by name, title, or description"
    method_option :registry, type: :string, desc: "Registry base URL to read from"
    method_option :json, type: :boolean, default: false, desc: "Emit machine-readable JSON"
    def search(query = nil)
      raise Shadwire::Error, "search requires a query" if query.nil? || query.strip.empty?

      run_command do |root, ui|
        Commands::Search.new(root:, query:, registry: options[:registry], json: options[:json], ui:).call
      end
    end

    desc "info NAME", "Show a component's metadata (files, gems, pins, dependencies)"
    method_option :registry, type: :string, desc: "Registry base URL to read from"
    method_option :json, type: :boolean, default: false, desc: "Emit machine-readable JSON"
    def info(name)
      run_command do |root, ui|
        Commands::Info.new(root:, name:, registry: options[:registry], json: options[:json], ui:).call
      end
    end

    desc "diff [NAME...]", "Show how installed files have drifted from the registry"
    method_option :registry, type: :string, desc: "Registry base URL to compare against"
    method_option :json, type: :boolean, default: false, desc: "Emit machine-readable JSON"
    method_option :exit_code, type: :boolean, default: false,
                              desc: "Exit non-zero when drift is found (for CI)"
    def diff(*names)
      run_command do |root, ui|
        result = Commands::Diff.new(
          root:, names:, registry: options[:registry], json: options[:json], ui:
        ).call
        exit 1 if options[:exit_code] && result[:drifted]
      end
    end

    desc "update [NAME...]", "Re-apply the registry version of installed components"
    method_option :yes, type: :boolean, default: false, aliases: "-y",
                        desc: "Overwrite locally-modified files without prompting"
    method_option :overwrite, type: :boolean, default: false,
                              desc: "Overwrite locally-modified files without prompting"
    method_option :deps, type: :boolean, default: true,
                         desc: "Also update transitive registry dependencies (--no-deps to skip)"
    method_option :registry, type: :string, desc: "Registry base URL to update from"
    method_option :json, type: :boolean, default: false, desc: "Emit machine-readable JSON"
    def update(*names)
      run_command do |root, ui|
        Commands::Update.new(
          root:, names:, yes: options[:yes], overwrite: options[:overwrite],
          no_deps: !options[:deps], registry: options[:registry], json: options[:json], ui:
        ).call
      end
    end

    desc "remove NAME...", "Uninstall components, deleting only their own files"
    method_option :yes, type: :boolean, default: false, aliases: "-y",
                        desc: "Delete without prompting"
    method_option :registry, type: :string, desc: "Registry base URL to reconcile against"
    method_option :json, type: :boolean, default: false, desc: "Emit machine-readable JSON"
    def remove(*names)
      raise Shadwire::Error, "remove requires at least one component name" if names.empty?

      run_command do |root, ui|
        Commands::Remove.new(
          root:, names:, yes: options[:yes], registry: options[:registry], json: options[:json], ui:
        ).call
      end
    end

    desc "status", "Report app context: stack, installed components, helpers, drift"
    method_option :registry, type: :string, desc: "Registry base URL to reconcile against"
    method_option :json, type: :boolean, default: false, desc: "Emit machine-readable JSON"
    def status
      run_command do |root, ui|
        Commands::Status.new(root:, registry: options[:registry], json: options[:json], ui:).call
      end
    end

    private

    def resolve_root
      File.expand_path(options[:cwd] || Dir.pwd)
    end

    def run_command
      ui = UI.new(yes: options[:yes])
      yield(resolve_root, ui)
    rescue Shadwire::Error => e
      ui.error(e.message)
      exit 1
    end
  end
end
