# frozen_string_literal: true

# Finds interactive content nested inside a <button> or an <a>, in HTML as it
# was written.
#
# A browser does not keep that nesting: it closes the outer button when the
# inner one starts, so `ui_dialog_trigger { ui_button { "Open" } }` renders an
# empty trigger next to an "Open" button that opens nothing. An HTML5 parser
# repairs the markup the same way, which hides the bug; this reads the tags as
# written instead.
#
# The rule is the content model of the two elements: neither may contain
# interactive content (a link, a button, a form control, a label…) or an
# element with a tabindex, and an <a> may not contain another <a> even when
# neither has an href — which is how the hover card's usage, a link inside its
# link trigger, slipped past a check that only looked at hrefs.
module HtmlNesting
  VOID = %w[area base br col embed hr img input link meta source track wbr].freeze
  # Their content is text, not markup: kept as an opening tag, emptied.
  OPAQUE = %w[pre script template textarea style].freeze
  CONTAINERS = %w[a button].freeze
  INTERACTIVE = %w[button details embed iframe label select textarea].freeze

  module_function

  # "<button> inside <button>"-style descriptions, one per offending element.
  def nested_interactive(html)
    html = html.gsub(/<!--.*?-->/m, "").gsub(%r{(<(#{OPAQUE.join("|")})\b[^>]*>).*?</\2>}m, '\1</\2>')
    stack = []

    html.scan(%r{<(/?)([a-zA-Z][\w-]*)([^>]*?)(/?)>}).filter_map do |closing, name, attrs, self_closing|
      name = name.downcase

      if closing == "/"
        index = stack.rindex { |open| open == name }
        stack.slice!(index..) if index
        next
      end

      outer = stack.reverse.find { |open| CONTAINERS.include?(open) }
      stack << name unless VOID.include?(name) || self_closing == "/"
      "<#{name}> inside <#{outer}>" if outer && forbidden?(name, attrs, outer)
    end
  end

  def forbidden?(name, attrs, outer)
    return true if name == "a" && (outer == "a" || attrs.match?(/\bhref=/))
    return true if name == "input" && !attrs.match?(/\btype=["']?hidden\b/)

    INTERACTIVE.include?(name) || attrs.match?(/\btabindex=/)
  end
end
