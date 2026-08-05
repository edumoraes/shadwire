# frozen_string_literal: true

module ShadwireRegistry
  # Renders the published registry as plain text for agents that never install
  # the skill or the CLI. Two files, served next to the registry:
  #
  #   llms.txt       one line per component — the catalog and how to install it
  #   llms-full.txt  every component's generated API and usage
  #
  # Pure: takes the published item hashes, returns strings.
  module LlmsWriter
    module_function

    def index(registry:, items:)
      lines = items.map { |item| "- #{item.fetch("name")} — #{item.fetch("whenToUse")}" }

      <<~TXT
        # #{registry.fetch("name")} #{registry.fetch("version")}

        shadcn/ui components for Ruby on Rails, delivered as source your app owns.
        Components are copied into the app by the CLI; there is no runtime
        dependency on Shadwire.

        ## Install

        gem install shadwire      # or: bundle add shadwire --group development
        shadwire init             # writes shadwire.json and the shared base files
        shadwire add <name>       # installs a component and its dependencies

        Run `shadwire status --json` in an app for its context: stack, installed
        components, and the ui_* helpers that actually exist. Run
        `shadwire info <name> --json` for a component's full API before using it.

        Full API reference for every component: llms-full.txt

        #{licence(registry)}

        ## Components (#{items.size})

        #{lines.join("\n")}
      TXT
    end

    def full(registry:, items:)
      <<~TXT
        # #{registry.fetch("name")} #{registry.fetch("version")} — component reference

        Every component below installs with `shadwire add <name>`. Helpers are the
        ui_* methods; each component's own helper module installs with it, so only
        the components you install define helpers.

        #{licence(registry)}

        #{items.map { |item| card(item) }.join("\n---\n\n")}
      TXT
    end

    # These files are what an agent reads when it cannot run the CLI, and the
    # ones most likely to be pasted into a model's context, so the terms travel
    # in them rather than only in the repository.
    def licence(registry)
      attribution = registry.fetch("attribution")

      <<~TXT.chomp
        ## Licence

        #{registry.fetch("license")} — #{registry.fetch("licenseUrl")}
        Ported from #{attribution.fetch("derivedFrom")} (#{attribution.fetch("url")}), #{attribution.fetch("license")}.
        #{attribution.fetch("notice")}
      TXT
    end

    def card(item)
      lines = [
        "## #{item.fetch("name")} — #{item.fetch("title")}",
        "",
        item.fetch("description"),
        "",
        "When to use: #{item.fetch("whenToUse")}",
        "",
        "Install: `shadwire add #{item.fetch("name")}`"
      ]
      lines << "Requires Stimulus (importmap with eager loading)." if item["requiresStimulus"]
      lines << ""

      components(item).each { |component| lines.concat(component_lines(component)) }
      Array(item["usage"]).each { |snippet| lines.push("```erb", snippet, "```", "") }

      lines.join("\n")
    end

    # Only components an app can actually call: the shared base, internal parts a
    # parent renders itself, and block components have no ui_* wrapper.
    def components(item)
      Array(item.dig("api", "components")).reject { |component| component["helper"].nil? }
    end

    def component_lines(component)
      lines = ["### #{component.fetch("class")} — `#{component.fetch("helper")}`"]
      lines << "variants: #{component["variants"].join(" | ")}" if component["variants"]&.any?
      lines << "sizes: #{component["sizes"].join(" | ")}" if component["sizes"]&.any?

      props = Array(component["props"]).map do |prop|
        prop["default"] ? "#{prop["name"]}: #{prop["default"]}" : "#{prop["name"]}: (required)"
      end
      props << "**attrs (free HTML attributes)" if component["attrs"]
      lines << "props: #{props.join(", ")}" unless props.empty?

      lines << ""
      lines
    end
  end
end
