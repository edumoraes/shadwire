# frozen_string_literal: true

# Helpers for the component documentation pages.
#
# Sandbox-only — this file is not part of the Shadwire registry, so it is never
# overwritten by bin/sync_registry (unlike app/helpers/ui_helper.rb).
module DocsHelper
  EXAMPLES_DIR = Rails.root.join("app/views/components/examples")
  CODE_BLOCK_COLLAPSED_LINES = 8
  CODE_BLOCK_MAX_HEIGHT_REM = 32
  CODE_BLOCK_LINE_HEIGHT_REM = 1.625

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

  private

  def highlight_code(code, language:)
    formatter = Rouge::Formatters::HTML.new
    lexer = lexer_for(language, code.to_s)

    formatter.format(lexer.lex(code.to_s.strip)).html_safe
  end

  def example_source(name)
    slug = name.to_s.parameterize(separator: "_")
    File.read(EXAMPLES_DIR.join("_#{slug}.html.erb"))
  end

  def lexer_for(language, code)
    lexer_name = language.to_s
    return Rouge::Lexers::ERB.new if lexer_name == "erb"

    Rouge::Lexer.find_fancy(lexer_name, code) || Rouge::Lexers::PlainText.new
  end

  def docs_code_block_attrs(source, collapsible, class_name)
    data = {
      controller: class_names("clipboard", ("code-block" if collapsible)),
      clipboard_source_value: source
    }
    data[:code_block_expanded_value] = false if collapsible

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
        tag.span("Expandir", data: { code_block_target: "label" })
      ])
    end
  end

  def docs_code_block_copy_button
    ui_button(variant: :secondary, size: :sm,
              data: { action: "clipboard#copy" }) do
      safe_join([
        ui_icon("copy", size: :sm),
        tag.span("Copiar", data: { clipboard_target: "label" })
      ])
    end
  end

  def docs_code_block_collapsed(source, language:, frame:, collapsible:, block_id:)
    visible_source = collapsible ? source.lines.first(CODE_BLOCK_COLLAPSED_LINES).join.rstrip : source

    ui_scroll_area(id: (block_id if collapsible),
                   scrollbars: [ :horizontal ],
                   class: docs_code_block_scroll_area_class(frame),
                   data: ({ code_block_target: "collapsed" } if collapsible)) do
      tag.pre(class: docs_code_block_pre_class) do
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
      tag.pre(id: "#{block_id}-expanded", class: docs_code_block_pre_class) do
        tag.code(highlight_code(source, language:))
      end
    end
  end

  def docs_code_block_pre_class
    "highlight min-w-max p-4 pr-24 text-sm leading-relaxed"
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
