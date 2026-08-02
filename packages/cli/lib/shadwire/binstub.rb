# frozen_string_literal: true

require "fileutils"
require "pathname"

module Shadwire
  # The canonical entry point a consuming app uses to run the CLI: bin/shadwire.
  #
  # The template is the shape Rails 8 generates for bin/rubocop and bin/brakeman,
  # so the file reads as native to the app it lands in. Being a bundler binstub,
  # it only works once `gem "shadwire"` is declared in the app's Gemfile —
  # Commands::Init gates the write on that, because a binstub written without it
  # raises Gem::LoadError on first run.
  #
  # Deliberately not routed through Installer: that writes published registry
  # entries tracked in shadwire.json, and it never sets an execute bit.
  module Binstub
    PATH = "bin/shadwire"
    MODE = 0o755

    TEMPLATE = <<~RUBY
      #!/usr/bin/env ruby
      # frozen_string_literal: true
      require "rubygems"
      require "bundler/setup"
      load Gem.bin_path("shadwire", "shadwire")
    RUBY

    # The gem that backs the binstub. `init` adds it, `status` reports it.
    GEM = "shadwire"

    def self.exist?(root)
      File.exist?(File.join(root.to_s, PATH))
    end

    # Writes bin/shadwire unless it already exists.
    #
    # An existing binstub is left alone: `bundle binstubs shadwire` produces a
    # different, working file, and it is not tracked in shadwire.json, so
    # `shadwire diff` could never report that we replaced it.
    #
    # @param root [String, Pathname] the consuming app root
    # @param force [Boolean] rewrite an existing binstub
    # @return [Hash] { written: Boolean, skipped: Boolean }
    def self.write(root, force: false)
      path = Pathname(root).join(PATH)
      return { written: false, skipped: true } if path.exist? && !force

      FileUtils.mkdir_p(path.dirname)
      path.write(TEMPLATE)
      path.chmod(MODE)
      { written: true, skipped: false }
    end
  end
end
