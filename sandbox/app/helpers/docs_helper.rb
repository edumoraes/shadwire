# frozen_string_literal: true

# Helpers for the component documentation pages.
#
# Sandbox-only — this file is not part of the Shadwire registry, so it is never
# overwritten by bin/sync_registry (unlike app/helpers/ui_helper.rb).
module DocsHelper
  EXAMPLES_DIR = Rails.root.join("app/views/components/examples")

  # Highlights an ERB snippet for display in a documentation code block.
  def highlight_erb(code)
    formatter = Rouge::Formatters::HTML.new
    formatter.format(Rouge::Lexers::ERB.new.lex(code.to_s.strip)).html_safe
  end

  # Highlights the source of an example partial so the docs page can show the
  # exact code that produced the live preview rendered above it.
  def highlight_example(name)
    slug = name.to_s.parameterize(separator: "_")
    highlight_erb(File.read(EXAMPLES_DIR.join("_#{slug}.html.erb")))
  end

  # The Rouge theme stylesheet, scoped to the .highlight code blocks.
  def rouge_stylesheet
    Rouge::Themes::Base16.mode(:dark).render(scope: ".highlight").html_safe
  end
end
