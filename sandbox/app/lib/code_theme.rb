# frozen_string_literal: true

# The syntax palette for the documentation's code cards, taken from
# rubyonrails.org's own `.highlight` rules — a pastel Monokai, bright enough to
# sit on the plum surface the reference uses rather than on a near-black one.
#
# This replaced Rouge's bundled Base16 dark, which is tuned for #181818 and
# broke in three ways once the surface lightened to the reference's plum: its
# comments fell to 1.6:1, and two of its rules — `.highlight .w` and
# `.highlight .gh` — pin background-color: #181818 at a specificity the site
# stylesheet cannot override with `.highlight` alone, so whitespace and diff
# headings painted near-black patches inside the card.
#
# Nothing here sets a background. The card's surface is --code in the site
# stylesheet, and it stays the only thing that draws it.
class CodeTheme < Rouge::CSSTheme
  TEXT = "#f8f8f2"     # names, punctuation, the base
  CYAN = "#9decfc"     # keywords and constants
  LILAC = "#cfb7fd"    # numbers, literals, escapes
  SAND = "#fff5ab"     # strings
  GREEN = "#d0ff71"    # attributes, insertions
  PINK = "#ff699b"     # tags, deletions, errors
  GREY = "#b4b4b3"     # comments and generic output
  OLIVE = "#9e9b8a"    # subheadings

  style Text, fg: TEXT
  style Error, fg: PINK

  # The reference greys line comments and italicises the rest. An unstyled
  # Comment would inherit the base colour, which reads as code.
  style Comment, fg: GREY, italic: true
  style Comment::Preproc, fg: TEXT, italic: false, bold: true

  style Keyword, fg: CYAN
  style Keyword::Constant, Keyword::Declaration, Keyword::Namespace,
        Keyword::Pseudo, Keyword::Reserved, Keyword::Type, fg: CYAN, bold: true

  style Literal, fg: LILAC
  style Literal::Date, fg: SAND
  style Literal::Number, fg: LILAC
  style Literal::String, fg: SAND
  style Literal::String::Escape, fg: LILAC

  style Name, fg: TEXT
  style Name::Attribute, Name::Other, fg: GREEN
  style Name::Constant, fg: CYAN
  style Name::Tag, fg: PINK
  style Name::Class, Name::Decorator, Name::Exception, Name::Function,
        Name::Function::Magic, Name::Label, fg: TEXT, bold: true

  style Operator, fg: TEXT, bold: true
  style Punctuation, fg: TEXT

  style Generic::Deleted, Generic::Error, fg: PINK
  style Generic::Inserted, fg: GREEN
  style Generic::Heading, Generic::Output, fg: GREY
  style Generic::Subheading, fg: OLIVE
  style Generic::Prompt, fg: "#ffffff"
  style Generic::Emph, italic: true
  style Generic::Strong, bold: true
end
