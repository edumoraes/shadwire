# frozen_string_literal: true

require "json"
require "fileutils"

module Shadwire
  # Reads and writes a consuming Rails app's shadwire.json.
  #
  # On-disk JSON shape (mirrors shadcn's components.json conventions):
  #
  #   {
  #     "registry": "https://edumoraes.github.io/shadwire/r",
  #     "tailwind": { "css": "app/assets/tailwind/application.css" },
  #     "aliases": {
  #       "components":  "app/components",
  #       "ui":          "app/components/ui",
  #       "helpers":     "app/helpers",
  #       "controllers": "app/javascript/controllers",
  #       "vendorCss":   "vendor/shadwire"
  #     },
  #     "installed": {
  #       "button": { "version": "1.0.0", "files": ["app/components/ui/button_component.rb"] }
  #     }
  #   }
  class Config
    CONFIG_FILE = "shadwire.json"

    DEFAULTS = {
      "registry" => "https://edumoraes.github.io/shadwire/r",
      "tailwind" => { "css" => "app/assets/tailwind/application.css" },
      "aliases" => {
        "components"  => "app/components",
        "ui"          => "app/components/ui",
        "helpers"     => "app/helpers",
        "controllers" => "app/javascript/controllers",
        "vendorCss"   => "vendor/shadwire"
      },
      "installed" => {}
    }.freeze

    attr_reader :root, :registry, :tailwind_css, :aliases, :installed

    # Loads shadwire.json from the given app root, or returns a Config with
    # defaults when the file does not exist.
    def self.load(root)
      path = File.join(root, CONFIG_FILE)
      data = File.exist?(path) ? JSON.parse(File.read(path)) : JSON.parse(JSON.generate(DEFAULTS))
      new(root, data)
    end

    # Writes pretty JSON to <root>/shadwire.json.
    def save
      FileUtils.mkdir_p(@root)
      File.write(File.join(@root, CONFIG_FILE), JSON.pretty_generate(to_h) + "\n")
    end

    # Records an installed component: installed[name] = { "version" => ..., "files" => [...] }.
    def record_installed(name, version, files)
      @installed[name] = { "version" => version, "files" => files }
    end

    # Removes an entry from installed.
    def forget(name)
      @installed.delete(name)
    end

    private

    def initialize(root, data)
      @root        = root
      @registry    = data.fetch("registry",  DEFAULTS["registry"])
      @tailwind_css = data.dig("tailwind", "css") || DEFAULTS.dig("tailwind", "css")
      @aliases     = data.fetch("aliases",   JSON.parse(JSON.generate(DEFAULTS["aliases"])))
      @installed   = data.fetch("installed", {})
    end

    def to_h
      {
        "registry" => @registry,
        "tailwind" => { "css" => @tailwind_css },
        "aliases"  => @aliases,
        "installed" => @installed
      }
    end
  end
end
