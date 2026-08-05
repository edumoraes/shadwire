# frozen_string_literal: true

# Every I18n key an installed component reads, scanned out of the component
# source itself.
#
# Derived rather than written by hand, for the reason the sidebar's component
# group is derived from the registry: a key added to a component would otherwise
# be documented nowhere, and nothing would say so. DocsLocaleKeysTest fails if
# the scan comes back short or a call stops being parseable.
#
# Sandbox-only: nothing here ships in the Shadwire registry.
module DocsLocaleKeys
  SOURCE = Rails.root.join("app/components/ui")

  # I18n.t("ui.dialog.close", default: "Close") — every call in the registry
  # carries its default inline, which is what lets an installed component work
  # in an app with no locale file at all.
  CALL = /I18n\.t\(\s*"(ui\.[a-z0-9_.]+)"\s*,\s*default:\s*"((?:[^"\\]|\\.)*)"/

  # A key is a Stimulus value when the call is assigned into a data-*-value
  # attribute rather than printed. The string is resolved once, when the
  # component renders, and read out of the DOM by the controller.
  VALUE_ASSIGNMENT = /[-_]value["'\]]*\s*[:=]/

  module_function

  # { "calendar" => [{ key:, default:, stimulus: }, …] }, alphabetical.
  def grouped
    scan.group_by { |entry| entry.fetch(:key).split(".").fetch(1) }.sort.to_h
  end

  def scan
    Dir[SOURCE.join("**/*.{rb,erb}")].sort
                                     .flat_map { |file| entries_in(File.read(file)) }
                                     .uniq { |entry| entry.fetch(:key) }
                                     .sort_by { |entry| entry.fetch(:key) }
  end

  # One line of lookback: the longest call in the registry wraps after the
  # assignment, so the data-*-value attribute sits on the line above.
  def entries_in(source)
    lines = source.lines

    lines.each_with_index.flat_map do |line, index|
      line.scan(CALL).map do |key, default|
        context = index.zero? ? line : lines[index - 1] + line
        { key:, default:, stimulus: context.match?(VALUE_ASSIGNMENT) }
      end
    end
  end
end
