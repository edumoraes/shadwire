# frozen_string_literal: true

require "minitest/autorun"
require "pathname"
require "set"

# Guards the theme against the failure shapes a colour grep misses.
#
# Every defect this encodes was found by hand in a full audit of the registry,
# and none of them is a literal colour sitting in a class list — that part of the
# codebase was already clean. They are missing companion utilities, variants that
# lose a specificity tie, and values frozen out of step with the token they
# imitate. All of them render correctly in one theme and wrongly in the other,
# which is what let them ship.
class ThemeLintTest < Minitest::Test
  ROOT = Pathname.new(__dir__).join("..").expand_path
  SOURCES = (Dir[ROOT.join("registry/rails/ui/components/**/*.rb")] +
             Dir[ROOT.join("registry/rails/ui/javascript/controllers/*.js")]).sort.freeze
  STYLESHEET = ROOT.join("registry/rails/ui/styles/shadwire.css")

  PALETTE = %w[
    white black slate gray grey zinc neutral stone red orange amber yellow lime
    green emerald teal cyan sky blue indigo violet purple fuchsia pink rose
  ].join("|")
  COLOR_UTILITY = /\b(?:bg|text|border|ring|from|to|via|fill|stroke|divide|outline|shadow|placeholder|caret|accent|decoration)-(?:#{PALETTE})(?:-\d{2,3})?(?:\/\d+)?\b/

  # Upstream shadcn paints every overlay scrim this exact value, so matching it
  # is the point. Keyed by the file that is allowed to say it.
  PALETTE_ALLOWANCES = {
    "components/sidebar_component.rb" => ["bg-black/50"]
  }.freeze

  # The one indicator that cannot read a token: a stroked check glyph inside a
  # data URI, where var() does not reach. Each literal is pinned to the token it
  # stands in for so a drift is a decision, not an accident.
  GLYPH_LITERALS = {
    "%23fafafa" => "--primary-foreground, light theme",
    "%23171717" => "--primary-foreground, dark theme"
  }.freeze

  # `selection:bg-*` paints ::selection, `file:bg-*` the file button — a
  # different box from the element's own background, so they cannot collide with
  # `dark:bg-*` the way a state variant does.
  PSEUDO_ELEMENT_VARIANTS = %w[
    selection placeholder file marker before after backdrop first-line first-letter
  ].freeze

  def test_no_palette_colours_where_a_token_exists
    each_source do |path, body, relative|
      allowed = PALETTE_ALLOWANCES.fetch(relative, [])
      offenders = body.scan(COLOR_UTILITY).uniq - allowed

      assert_empty offenders,
                   "#{relative} uses #{offenders.join(", ")}. Reach for a semantic token " \
                   "(bg-primary, text-muted-foreground, border-input …). If upstream shadcn " \
                   "hardcodes the same value, add it to PALETTE_ALLOWANCES with that reason."
    end
  end

  def test_no_raw_colour_values_in_component_sources
    each_source do |path, body, relative|
      offenders = strip_comments(body, path)
                  .scan(/#[0-9a-fA-F]{3,8}\b|\brgba?\([^)]*\)|\bhsla?\([^)]*\)|\boklch\([^)]*\)/)
                  .uniq
                  .reject { |value| value.include?("${") } # built from measured pixels, not written down

      assert_empty offenders,
                   "#{relative} hardcodes #{offenders.join(", ")}. A colour written out cannot " \
                   "follow a re-themed token."
    end
  end

  # `ring-offset-N` opens a gap that Tailwind fills with --tw-ring-offset-color,
  # whose initial value is #fff. Without the companion the gap is literal white
  # on a dark surface, and no colour appears in the source at all.
  def test_ring_offsets_declare_their_colour
    each_source do |path, body, relative|
      class_lists(body).each do |classes|
        next unless classes.grep(/\Aring-offset-\d/).any? || classes.grep(/:ring-offset-\d/).any?

        assert_includes classes, "ring-offset-background",
                        "#{relative} sets a ring offset without ring-offset-background, " \
                        "so the gap paints #fff regardless of theme."
      end
    end
  end

  # `checked:bg-primary` and `dark:bg-input/80` are both one class plus one
  # pseudo-class, so source order decides — and Tailwind emits dark later. The
  # state loses, silently, in one theme only.
  def test_state_backgrounds_survive_the_dark_variant
    each_source do |path, body, relative|
      class_lists(body).each do |classes|
        next unless classes.any? { |c| c.match?(/\Adark:bg-/) }

        states = classes.filter_map { |c| c[/\A([a-z-]+):bg-/, 1] }.uniq
        states -= ["dark", *PSEUDO_ELEMENT_VARIANTS]
        states.each do |state|
          next unless classes.none? { |c| c.start_with?("dark:#{state}:bg-") }

          flunk "#{relative} pairs #{state}:bg-* with dark:bg-*, which wins on source order. " \
                "Add dark:#{state}:bg-* — the same companion checkbox_component.rb carries."
        end
      end
    end
  end

  # Tailwind v4 marks an override with a trailing `!`. The leading form is v3 and
  # still compiles, so a stray one drifts unnoticed.
  def test_overrides_use_the_v4_marker
    each_source do |path, body, relative|
      offenders = class_lists(body).flatten.grep(/\A!/).uniq

      assert_empty offenders,
                   "#{relative} uses the v3 leading-bang form (#{offenders.join(", ")}). " \
                   "Tailwind v4 puts the marker last: w-auto!, not !w-auto."
    end
  end

  def test_stylesheet_literals_stay_pinned_to_their_token
    body = STYLESHEET.read
    tokens, rest = split_token_blocks(body)
    refute_empty tokens, "could not find the :root/.dark token blocks"

    found = rest.scan(/%23[0-9a-fA-F]{6}|#[0-9a-fA-F]{3,8}\b/).uniq.to_set

    assert_equal GLYPH_LITERALS.keys.to_set, found,
                 "the literal colours outside the token blocks changed. Every one needs an " \
                 "entry in GLYPH_LITERALS naming the token it imitates — anything that can " \
                 "read a token should, as the radio dot and switch thumb now do via " \
                 "radial-gradient(var(--token))."
  end

  def test_every_token_is_defined_in_both_themes
    body = STYLESHEET.read
    root = declared_vars(body, /:root\s*\{(.*?)\n\}/m)
    dark = declared_vars(body, /\.dark\s*\{(.*?)\n\}/m)

    refute_empty root
    refute_empty dark

    sources = SOURCES.map { |f| File.read(f) }.join
    used = (sources + body).scan(/var\((--[a-z0-9-]+)/).flatten.uniq
    # Sidebar widths and the skeleton's width are declared inline at render time.
    declared = root + dark + sources.scan(/(--[a-z0-9-]+)\s*:/).flatten
    used.reject! { |name| name.start_with?("--tw-", "--radix-") }

    assert_empty(used - declared, "referenced but nothing declares them")
    # --radius is a length, not a colour, so it does not vary by theme.
    assert_empty(root - dark - ["--radius"], "defined in :root but missing from .dark, " \
                                             "so they keep their light value under .dark")
  end

  private

  def strip_comments(body, path)
    return body.gsub(%r{/\*.*?\*/}m, "").gsub(%r{^\s*//.*$}, "") if path.extname == ".js"

    body.gsub(/^\s*#.*$/, "")
  end

  def each_source
    SOURCES.each do |file|
      path = Pathname.new(file)
      yield path, path.read, path.relative_path_from(ROOT.join("registry/rails/ui")).to_s
    end
  end

  # Class lists as written, one array per quoted string. Keeping them grouped is
  # what makes the companion checks possible: the question is always whether a
  # class sits next to another in the same list.
  def class_lists(body)
    body.scan(/"([^"\n]*)"/).flatten
        .select { |s| s.match?(/[a-z]-|:[a-z]/) }
        .map { |s| s.split(/\s+/).reject(&:empty?) }
        .reject(&:empty?)
  end

  def split_token_blocks(body)
    blocks = body.scan(/(?::root|\.dark)\s*\{.*?\n\}/m)
    [blocks, blocks.reduce(body) { |rest, block| rest.sub(block, "") }]
  end

  def declared_vars(body, pattern)
    body[pattern, 1].to_s.scan(/(--[a-z0-9-]+)\s*:/).flatten.uniq
  end
end
