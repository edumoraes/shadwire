# frozen_string_literal: true

# Helpers for the component documentation pages.
#
# Sandbox-only — this file is not part of the Shadwire registry, so it is never
# overwritten by bin/sync_registry (unlike the Ui::*Helper modules under
# app/helpers/ui/).
module DocsHelper
  EXAMPLES_DIR = Rails.root.join("app/views/components/examples")
  # The publish manifest, one directory up from the sandbox. Read at render time
  # so the documented install never drifts from what the registry actually
  # installs — these lists were hand-maintained and still named a helper file
  # that had been removed.
  REGISTRY_MANIFEST = Rails.root.join("../registry/registry.json")
  CODE_BLOCK_COLLAPSED_LINES = 8
  CODE_BLOCK_MAX_HEIGHT_REM = 32
  CODE_BLOCK_LINE_HEIGHT_REM = 1.625

  # Section headings. Every documentation page uses these so the "Nesta página"
  # rail (built client-side by the docs-toc controller) sees a consistent
  # hierarchy, and so the class strings live in one place.
  def docs_h2(text)
    tag.h2(text, id: text.to_s.parameterize, class: "scroll-mt-24 border-b pb-2 text-2xl font-bold tracking-[-0.01em]")
  end

  def docs_h3(text)
    tag.h3(text, id: text.to_s.parameterize, class: "scroll-mt-24 text-lg font-bold tracking-[-0.01em]")
  end

  # Inline code, as it appears inside documentation prose.
  def docs_code(text)
    tag.code(text, class: "rounded bg-muted px-[0.3rem] py-[0.2rem] font-mono text-[0.8125rem]")
  end

  # The same, one step down: inline code inside the smaller supporting prose of
  # the install section and the API tables.
  def docs_code_sm(text)
    tag.code(text, class: "rounded bg-muted px-1 py-0.5 text-xs")
  end

  # The registry item a documentation page describes, or nil when the page has
  # no matching item.
  def registry_item(name)
    registry_items[name.to_s]
  end

  # Install targets for an item, in manifest order.
  def registry_install_targets(name)
    item = registry_item(name)
    return [] unless item

    item.fetch("files").map { |file| file.fetch("target") }
  end

  # `shadwire add <name>` — the command that installs the component.
  def registry_install_command(name)
    "shadwire add #{name}"
  end

  def registry_requires_stimulus?(name)
    registry_install_targets(name).any? { |target| target.start_with?("app/javascript/") }
  end

  # How many components ship a Stimulus controller. Counted rather than written
  # down: the prose said 28 for long enough that it outlived being true.
  def registry_stimulus_component_count
    registry_items.values.count do |item|
      item.fetch("type") == "component" &&
        item.fetch("files").any? { |file| file.fetch("target").start_with?("app/javascript/") }
    end
  end

  # Highlights an ERB snippet for display in a documentation code block.
  def highlight_erb(code)
    highlight_code(code, language: :erb)
  end

  # Renders a documentation code block with syntax highlighting and copy
  # controls. Long snippets start collapsed and expand into a Scroll Area.
  def docs_code_block(code, language: :erb, frame: true, class_name: nil)
    source = code.to_s.strip
    line_count = source.lines.count
    collapsible = line_count > CODE_BLOCK_COLLAPSED_LINES
    block_id = next_docs_code_block_id

    tag.div(**docs_code_block_attrs(source, collapsible, class_name)) do
      safe_join([
        docs_code_block_controls(collapsible, block_id),
        docs_code_block_collapsed(source, language:, frame:, collapsible:, block_id:),
        (docs_code_block_expanded(source, language:, frame:, line_count:, block_id:) if collapsible)
      ].compact)
    end
  end

  # Highlights the source of an example partial so the docs page can show the
  # exact code that produced the live preview rendered above it.
  def highlight_example(name)
    highlight_code(example_source(name), language: :erb)
  end

  def docs_example_source(name)
    example_source(name)
  end

  # The Rouge theme stylesheet, scoped to the .highlight code blocks.
  def rouge_stylesheet
    Rouge::Themes::Base16.mode(:dark).render(scope: ".highlight").html_safe
  end

  # The registry's published version, as the landing page badge shows it.
  def registry_version
    registry_manifest.fetch("version", "")
  end

  # Registry items keyed by name. Public because DocsNavHelper builds the
  # sidebar's component group from the same manifest.
  #
  # Memoized per request rather than per process: the manifest is small, and
  # caching it across requests would serve stale file lists in development after
  # editing registry.json.
  def registry_items
    @registry_items ||= registry_manifest.fetch("items", [])
                                         .to_h { |item| [ item.fetch("name"), item ] }
  end

  private

  def registry_manifest
    @registry_manifest ||= JSON.parse(REGISTRY_MANIFEST.read)
  rescue Errno::ENOENT, JSON::ParserError
    # The docs site is only ever served from the monorepo, but a missing or
    # broken manifest must not take the whole page down.
    @registry_manifest = {}
  end

  def highlight_code(code, language:)
    formatter = Rouge::Formatters::HTML.new
    lexer = lexer_for(language, code.to_s)

    formatter.format(lexer.lex(code.to_s.strip)).html_safe
  end

  # The snippet under a preview has to be the file that produced it. Rails picks
  # _foo.pt.html.erb over _foo.html.erb on its own when rendering, so reading the
  # source back must make the same choice — otherwise a Portuguese page shows a
  # demo and a listing of it that disagree.
  #
  # Most examples have no localised copy and never will: `ui_button { "Save" }`
  # illustrates a registry whose language is English. Only the demos whose
  # content is prose rather than UI labels are worth two files.
  def example_source(name)
    slug = name.to_s.parameterize(separator: "_")
    localised = EXAMPLES_DIR.join("_#{slug}.#{I18n.locale}.html.erb")

    File.read(localised.exist? ? localised : EXAMPLES_DIR.join("_#{slug}.html.erb"))
  end

  def lexer_for(language, code)
    lexer_name = language.to_s
    return Rouge::Lexers::ERB.new if lexer_name == "erb"

    Rouge::Lexer.find_fancy(lexer_name, code) || Rouge::Lexers::PlainText.new
  end

  def docs_code_block_attrs(source, collapsible, class_name)
    data = {
      controller: class_names("clipboard", ("code-block" if collapsible)),
      clipboard_source_value: source,
      clipboard_copy_value: t("docs.code.copy"),
      clipboard_copied_value: t("docs.code.copied")
    }

    if collapsible
      data[:code_block_expanded_value] = false
      data[:code_block_expand_value] = t("docs.code.expand")
      data[:code_block_collapse_value] = t("docs.code.collapse")
    end

    {
      class: class_names("relative", class_name),
      data:
    }
  end

  def docs_code_block_controls(collapsible, block_id)
    tag.div(class: "absolute right-3 top-3 z-10 flex items-center gap-2") do
      safe_join([
        (docs_code_block_toggle(block_id) if collapsible),
        docs_code_block_copy_button
      ].compact)
    end
  end

  def docs_code_block_toggle(block_id)
    ui_button(variant: :secondary, size: :sm,
              aria: { controls: block_id, expanded: false },
              data: {
                action: "code-block#toggle",
                code_block_target: "button"
              }) do
      safe_join([
        tag.span(data: { code_block_target: "expandIcon" }) { ui_icon("chevrons-down", size: :sm) },
        tag.span(data: { code_block_target: "collapseIcon" }, hidden: true) { ui_icon("chevrons-up", size: :sm) },
        tag.span(t("docs.code.expand"), data: { code_block_target: "label" })
      ])
    end
  end

  def docs_code_block_copy_button
    ui_button(variant: :secondary, size: :sm,
              data: { action: "clipboard#copy" }) do
      safe_join([
        ui_icon("copy", size: :sm),
        tag.span(t("docs.code.copy"), data: { clipboard_target: "label" })
      ])
    end
  end

  def docs_code_block_collapsed(source, language:, frame:, collapsible:, block_id:)
    visible_source = collapsible ? source.lines.first(CODE_BLOCK_COLLAPSED_LINES).join.rstrip : source

    ui_scroll_area(id: (block_id if collapsible),
                   scrollbars: [ :horizontal ],
                   class: docs_code_block_scroll_area_class(frame),
                   data: ({ code_block_target: "collapsed" } if collapsible)) do
      tag.pre(class: docs_code_block_pre_class(collapsible)) do
        tag.code(highlight_code(visible_source, language:))
      end
    end
  end

  def docs_code_block_expanded(source, language:, frame:, line_count:, block_id:)
    ui_scroll_area(scrollbars: [ :vertical, :horizontal ],
                   class: docs_code_block_scroll_area_class(frame),
                   style: "height: #{docs_code_block_expanded_height(line_count)}rem; max-height: #{CODE_BLOCK_MAX_HEIGHT_REM}rem;",
                   hidden: true,
                   data: { code_block_target: "expanded" }) do
      tag.pre(id: "#{block_id}-expanded", class: docs_code_block_pre_class(true)) do
        tag.code(highlight_code(source, language:))
      end
    end
  end

  # The controls float over the top-right corner, so the code reserves room for
  # them. A collapsible block carries two buttons ("Expandir" + "Copiar"), which
  # need roughly twice the room of "Copiar" alone. The block scrolls
  # horizontally, so the reserved space costs nothing but scroll width.
  def docs_code_block_pre_class(collapsible)
    class_names("highlight min-w-max p-4 text-sm leading-relaxed", collapsible ? "pr-56" : "pr-28")
  end

  def docs_code_block_scroll_area_class(frame)
    class_names("highlight", ("rounded-lg border" if frame))
  end

  def docs_code_block_expanded_height(line_count)
    [ (line_count * CODE_BLOCK_LINE_HEIGHT_REM) + 2, CODE_BLOCK_MAX_HEIGHT_REM ].min.round(3)
  end

  def next_docs_code_block_id
    @docs_code_block_id = @docs_code_block_id.to_i + 1
    "docs-code-block-#{@docs_code_block_id}"
  end
end
