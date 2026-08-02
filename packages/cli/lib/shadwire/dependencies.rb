# frozen_string_literal: true

require "pathname"

module Shadwire
  # Applies a component's non-file dependencies to a consuming Rails app: gems
  # (via `bundle add`), importmap pins, and the Tailwind `@import`. Each method
  # detects what is missing, then applies only when told to (`yes:` or a truthy
  # `confirm:` callback) — the command owns the prompting. On an unsupported
  # stack (no importmap / no tailwindcss-rails) it returns manual instructions
  # and mutates nothing.
  #
  # Every method returns a normalized result hash:
  #   { applied: [...], skipped: [...], pending: [...], manual: [...], failed: [...] }
  #
  # `failed` carries the things we tried to apply and could not — a `bundle add`
  # that exited non-zero, above all. Callers must surface it and exit non-zero:
  # reporting a gem as installed when it is not leaves the app raising
  # `uninitialized constant ViewComponent` at request time, which looks unrelated
  # to the install that caused it.
  class Dependencies
    # Runs a shell command in the app root, isolated from the CLI's own bundle.
    DEFAULT_RUNNER = lambda do |cmd, chdir:|
      require "bundler"
      Bundler.with_unbundled_env { system(*cmd, chdir: chdir) }
    end

    # Raises when any of the given result hashes reports something it failed to
    # apply, so a command that could not install a dependency exits non-zero
    # instead of claiming success.
    def self.raise_on_failure!(*results)
      failed = results.flat_map { |result| Array(result[:failed]) }.uniq
      return if failed.empty?

      raise Error, "Failed to install: #{failed.join(", ")}. " \
                   "Run `bundle add #{failed.join(" ")}` in the app and re-run this command."
    end

    def initialize(project, runner: DEFAULT_RUNNER)
      @project = project
      @runner = runner
    end

    # Ensures each gem name is present, running `bundle add <missing...>`.
    # `group:` adds them to a bundler group — used for the shadwire CLI itself,
    # which belongs in development, not in the app's runtime dependencies.
    def ensure_gems(names, yes:, confirm: nil, group: nil)
      present = names.select { |name| @project.gem?(name) }
      missing = names - present
      return result(skipped: present) if missing.empty?

      suffix = group ? " --group #{group}" : ""
      unless apply?(yes, confirm, "Add gems: #{missing.join(", ")} (bundle add#{suffix})")
        return result(skipped: present, pending: missing)
      end

      command = ["bundle", "add", *missing]
      command.push("--group", group.to_s) if group

      # `system` returns false on a non-zero exit and nil when the command could
      # not be run at all; neither means the gems landed.
      return result(skipped: present, failed: missing) unless @runner.call(command, chdir: @project.root)

      result(applied: missing, skipped: present)
    end

    # Ensures each pin ({ "name" =>, "to" => }) exists in config/importmap.rb.
    def ensure_importmap_pins(pins, yes:, confirm: nil)
      # importmap? is true when the gem is in the Gemfile, but config/importmap.rb
      # only exists once `importmap:install` has run — guard the read so an
      # unconfigured app falls back to a manual instruction instead of crashing.
      path = @project.importmap_path
      unless @project.importmap? && File.exist?(path)
        return result(manual: pins.map { |p| manual_pin_instruction(p) })
      end

      content = File.read(path)
      present, missing = pins.partition { |pin| pin_present?(content, pin) }
      return result(skipped: present.map { |p| p["name"] }) if missing.empty?

      names = missing.map { |p| p["name"] }
      unless apply?(yes, confirm, "Add importmap pins: #{names.join(", ")}")
        return result(skipped: present.map { |p| p["name"] }, pending: names)
      end

      appended = content
      appended += "\n" unless appended.end_with?("\n")
      missing.each { |pin| appended += %(pin "#{pin["name"]}", to: "#{pin["to"]}"\n) }
      File.write(path, appended)
      result(applied: names, skipped: present.map { |p| p["name"] })
    end

    # Ensures `@import "<relative>";` (pointing at the vendored shadwire.css)
    # appears after `@import "tailwindcss";` in the Tailwind css entry.
    def ensure_tailwind_import(vendor_css_target, css_entry: "app/assets/tailwind/application.css", yes:, confirm: nil)
      css_path = @project.tailwind_css_path(css_entry)
      unless @project.tailwindcss_rails? && File.exist?(css_path)
        return result(manual: [manual_tailwind_instruction(vendor_css_target, css_entry)])
      end

      relative = relative_import(vendor_css_target, css_entry)
      content = File.read(css_path)
      return result(skipped: [relative]) if content.include?(%(@import "#{relative}"))

      unless apply?(yes, confirm, "Add Tailwind import: #{relative}")
        return result(pending: [relative])
      end

      File.write(css_path, insert_import(content, relative))
      result(applied: [relative])
    end

    private

    def result(applied: [], skipped: [], pending: [], manual: [], failed: [])
      { applied:, skipped:, pending:, manual:, failed: }
    end

    def apply?(yes, confirm, description)
      yes || !!confirm&.call(description)
    end

    def pin_present?(content, pin)
      content.match?(/^\s*pin\s+["']#{Regexp.escape(pin["name"])}["']/)
    end

    def relative_import(vendor_css_target, css_entry)
      Pathname(vendor_css_target).relative_path_from(Pathname(css_entry).dirname).to_s
    end

    # Inserts the import right after the `@import "tailwindcss";` line, or at the
    # top when that line is absent.
    def insert_import(content, relative)
      import_line = %(@import "#{relative}";)
      lines = content.lines
      index = lines.index { |line| line.match?(/^\s*@import\s+["']tailwindcss["']/) }
      if index
        lines.insert(index + 1, "#{import_line}\n")
      else
        lines.unshift("#{import_line}\n")
      end
      lines.join
    end

    def manual_pin_instruction(pin)
      %(Add to config/importmap.rb: pin "#{pin["name"]}", to: "#{pin["to"]}")
    end

    def manual_tailwind_instruction(vendor_css_target, css_entry)
      relative = relative_import(vendor_css_target, css_entry)
      %(Add to #{css_entry} after `@import "tailwindcss";`: @import "#{relative}";)
    end
  end
end
