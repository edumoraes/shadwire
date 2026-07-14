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
