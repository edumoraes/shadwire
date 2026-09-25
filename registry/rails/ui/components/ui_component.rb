# frozen_string_literal: true

class UiComponent < ViewComponent::Base
  # What a Tailwind utility sets, for #class_names. Each pattern's first capture
  # names the property when one pattern covers several (`px` and `py` are both
  # spacing, and do not conflict).
  TAILWIND_COLOURS = %w[
    primary secondary destructive muted accent background foreground card popover input ring border
    transparent current white black inherit chart-1 chart-2 chart-3 chart-4 chart-5
    sidebar sidebar-primary sidebar-accent sidebar-border sidebar-ring
  ].join("|")
  TAILWIND_LENGTH = '(?:\d+(?:\.\d+)?(?:/\d+)?|px|auto|full|fit|max|min|screen|none|[sdl]vh|[2-7]?xs|sm|md|lg|[2-7]?xl|prose|\[.+\]|\(.+\))'
  TAILWIND_PROPERTIES = {
    "colour" => /\A(bg|text|border|ring|outline|fill|stroke)-(?:#{TAILWIND_COLOURS})(?:-foreground)?(?:\/\d+)?\z/,
    "font-size" => /\A(text)-(?:xs|sm|base|lg|xl|\dxl)\z/,
    "text-align" => /\A()text-(?:left|center|right|justify|start|end)\z/,
    "font-weight" => /\A(font)-(?:thin|light|normal|medium|semibold|bold|extrabold|black)\z/,
    "dimension" => /\A(h|w|size|min-w|min-h|max-w|max-h)-#{TAILWIND_LENGTH}\z/,
    "spacing" => /\A(p|px|py|pt|pr|pb|pl|m|mx|my|mt|mr|mb|ml|gap|gap-x|gap-y)-#{TAILWIND_LENGTH}\z/,
    "shadow" => /\A(shadow)(?:-(?:none|2xs|xs|sm|md|lg|xl|2xl))?\z/,
    "radius" => /\A(rounded(?:-[trbl]|-[tb][lr])?)(?:-(?:none|xs|sm|md|lg|xl|2xl|3xl|full|\[.+\]))?\z/,
    "border-width" => /\A(border(?:-[trblxy])?)(?:-(?:0|2|4|8))?\z/,
    "display" => /\A()(?:block|inline-block|inline|flex|inline-flex|grid|inline-grid|hidden|contents|table)\z/,
    "position" => /\A()(?:static|fixed|absolute|relative|sticky)\z/,
    "alignment" => /\A(items|justify|self|content)-(?:start|end|center|between|around|evenly|stretch|baseline|auto|normal)\z/,
    "line-height" => /\A(leading)-(?:none|tight|snug|normal|relaxed|loose|\d+)\z/,
    "letter-spacing" => /\A(tracking)-(?:tighter|tight|normal|wide|wider|widest)\z/,
    "opacity" => /\A(opacity)-\d+\z/,
    "overflow" => /\A(overflow(?:-[xy])?)-(?:auto|hidden|visible|scroll|clip)\z/,
    "whitespace" => /\A(whitespace)-(?:normal|nowrap|pre|pre-line|pre-wrap)\z/,
    "cursor" => /\A(cursor)-(?:default|pointer|not-allowed|wait|text|move)\z/
  }.freeze

  # A shorthand given later also overrides the longhands before it: `p-0`
  # after `px-4` leaves no horizontal padding.
  TAILWIND_SHORTHANDS = {
    "spacing:p" => %w[spacing:px spacing:py spacing:pt spacing:pr spacing:pb spacing:pl],
    "spacing:px" => %w[spacing:pr spacing:pl],
    "spacing:py" => %w[spacing:pt spacing:pb],
    "spacing:m" => %w[spacing:mx spacing:my spacing:mt spacing:mr spacing:mb spacing:ml],
    "spacing:mx" => %w[spacing:mr spacing:ml],
    "spacing:my" => %w[spacing:mt spacing:mb],
    "spacing:gap" => %w[spacing:gap-x spacing:gap-y],
    "dimension:size" => %w[dimension:w dimension:h],
    "radius:rounded" => %w[radius:rounded-t radius:rounded-r radius:rounded-b radius:rounded-l
                           radius:rounded-tl radius:rounded-tr radius:rounded-bl radius:rounded-br],
    "border-width:border" => %w[border-width:border-x border-width:border-y border-width:border-t
                                border-width:border-r border-width:border-b border-width:border-l]
  }.freeze

  class << self
    # The classes in order, less each one a later class overrides. What shadcn's
    # cn() does with tailwind-merge, for the utilities in TAILWIND_PROPERTIES;
    # any other class is kept as given.
    def merge_classes(classes)
      taken = {}

      classes.to_s.split.reverse.select { |name|
        keys = tailwind_keys(name)
        next true unless keys
        next false if taken.key?(keys.first)

        keys.each { |key| taken[key] = true }
      }.reverse.join(" ")
    end

    # [what the class sets, what else it overrides], each under the class's
    # variants and importance — `hover:bg-accent` and `bg-primary` set
    # different things, and so do `h-8!` and `h-9`. Nil for anything that is
    # not a utility listed above.
    def tailwind_keys(name)
      cache = (@tailwind_keys ||= {})

      cache.fetch(name) do
        cache.clear if cache.size > 10_000
        cache[name] = compute_tailwind_keys(name)
      end
    end

    private

    def compute_tailwind_keys(name)
      variants, _, utility = name.rpartition(":")
      important = utility.end_with?("!")
      utility = utility.delete_suffix("!")

      TAILWIND_PROPERTIES.each do |group, pattern|
        match = pattern.match(utility) or next
        property = "#{group}:#{match[1]}"

        return [ property, *TAILWIND_SHORTHANDS.fetch(property, []) ].map { |key| [ variants, important, key ] }
      end
      nil
    end
  end

  private

  # Rails' class_names, with Tailwind conflicts settled the way cn() settles
  # them upstream: of two utilities that set the same thing, the one given
  # later wins. Without it both reach the page and the stylesheet's order —
  # not the order given — picks one, so `class: "w-80"` lost to a component's
  # own `w-full`, and the outline Item's border to its base's transparent one.
  #
  # Rails escapes each token and marks the result safe; dropping tokens leaves
  # the rest as escaped, so it stays marked — a plain string would be escaped
  # twice on its way into the attribute.
  def class_names(*args)
    UiComponent.merge_classes(super).html_safe
  end

  def extract_class_name(attrs, class_name)
    [ attrs.delete(:class), class_name ].compact_blank.join(" ")
  end

  def fetch_variant(mapping, key, fallback:)
    variant = key.presence&.to_sym || fallback.to_sym

    mapping.fetch(variant) { mapping.fetch(fallback.to_sym) }
  end

  def html_attrs
    @attrs
  end
end
