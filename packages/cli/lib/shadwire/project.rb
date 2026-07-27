# frozen_string_literal: true

module Shadwire
  # Detects a consuming Rails app and its front-end stack by inspecting the
  # Gemfile / Gemfile.lock and a few conventional files. Pure filesystem reads —
  # never loads the app or Bundler.
  class Project
    attr_reader :root

    def initialize(root)
      @root = root.to_s
    end

    def rails?
      File.exist?(path("config/application.rb")) || gem?("rails")
    end

    # True when the gem is declared in Gemfile.lock (authoritative when present)
    # or the Gemfile.
    def gem?(name)
      (File.exist?(lockfile_path) && lock_declares?(name)) || gemfile_declares?(name)
    end

    def importmap?
      gem?("importmap-rails") || File.exist?(importmap_path)
    end

    def tailwindcss_rails?
      gem?("tailwindcss-rails")
    end

    def stimulus?
      gem?("stimulus-rails") || File.exist?(path("app/javascript/controllers/index.js"))
    end

    def importmap_path
      path("config/importmap.rb")
    end

    # Rails includes every app/helpers/**/*_helper.rb module into views unless an
    # app opts out. When it does, the Ui::*Helper modules need per-controller
    # `helper` calls, so `status` surfaces it.
    def include_all_helpers?
      config = path("config/application.rb")
      return true unless File.exist?(config)

      !File.read(config).match?(/include_all_helpers\s*=\s*false/)
    end

    # A monolithic app/helpers/ui_helper.rb left over from before helpers were
    # split per item. No longer published; safe for the app to delete.
    def legacy_helper?
      File.exist?(path("app/helpers/ui_helper.rb"))
    end

    def tailwind_css_path(relative = "app/assets/tailwind/application.css")
      path(relative)
    end

    # Raises ProjectError unless this looks like a Rails app.
    def raise_unless_rails!
      return if rails?

      raise ProjectError,
            "Not a Rails app: no config/application.rb or `gem \"rails\"` found in #{@root}"
    end

    private

    def path(relative)
      File.join(@root, relative)
    end

    def gemfile_path
      path("Gemfile")
    end

    def lockfile_path
      path("Gemfile.lock")
    end

    def gemfile_declares?(name)
      File.exist?(gemfile_path) &&
        File.read(gemfile_path).match?(/^\s*gem\s+["']#{Regexp.escape(name)}["']/)
    end

    def lock_declares?(name)
      File.read(lockfile_path).match?(/^\s+#{Regexp.escape(name)} \(/)
    end
  end
end
