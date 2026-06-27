# frozen_string_literal: true

require "fileutils"
require "pathname"

module Shadwire
  # Writes published registry file entries into a consuming Rails app, applying
  # the same safety checks bin/sync_registry enforces. It is non-interactive:
  # the overwrite policy and an optional confirm callable are injected so that
  # commands own the UI and tests stay deterministic.
  #
  # A file entry is a Hash of the published shape:
  #   { "target" => "app/.../x.rb", "type" => "component", "content" => "..." }
  class Installer
    # @param root [String, Pathname] the consuming app root
    # @param overwrite [Symbol] :always, :never, or :prompt
    # @param confirm [#call, nil] called with the target string when :prompt;
    #   truthy result overwrites, falsy skips
    def initialize(root, overwrite: :prompt, confirm: nil)
      @root = Pathname(root).expand_path
      @overwrite = overwrite
      @confirm = confirm
    end

    # Validates all targets (fail-fast), then writes.
    # @param files [Array<Hash>] flat array of published file entries
    # @return [Hash] { written: [target strings], skipped: [target strings] }
    def install(files)
      planned = validate(files)

      written = []
      skipped = []

      planned.each do |target, content|
        path = @root.join(target)

        if path.exist? && !overwrite?(target)
          skipped << target
          next
        end

        FileUtils.mkdir_p(path.dirname)
        path.write(content)
        written << target
      end

      { written:, skipped: }
    end

    private

    # Runs the escape-path and conflict checks before any write, de-duplicating
    # identical (target, content) entries. Returns target => content pairs in
    # first-seen order.
    def validate(files)
      seen = {}

      files.each do |file|
        target = file.fetch("target")
        content = file.fetch("content")
        absolute = @root.join(target).expand_path

        unless inside_directory?(absolute, @root)
          raise RegistryError, "Unsafe install target escapes app root: #{target}"
        end

        if seen.key?(target) && seen[target] != content
          raise RegistryError, "Conflicting install target: #{target} maps to two different contents"
        end

        seen[target] = content
      end

      seen
    end

    def overwrite?(target)
      case @overwrite
      when :always then true
      when :never then false
      when :prompt then !!@confirm&.call(target)
      else false
      end
    end

    def inside_directory?(path, directory)
      relative = path.relative_path_from(directory)
      relative.each_filename.first != ".."
    end
  end
end
