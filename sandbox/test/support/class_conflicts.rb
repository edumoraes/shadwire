# frozen_string_literal: true

# Finds an element carrying two Tailwind utilities that set the same thing, as
# UiComponent.merge_classes reckons it: `h-9` beside `h-8`, `p-6` beside a
# later `p-0`.
#
# The browser applies whichever of the two Tailwind emitted later, not the one
# written later, so the override loses about half the time. UiComponent's
# class_names drops the earlier class the way cn() does upstream; a pair left
# on the page means classes were put together some other way.
module ClassConflicts
  module_function

  # "h-9 + h-8"-style descriptions — the class, then the later one that
  # overrides it — for every element of a Nokogiri fragment or document.
  def in_fragment(fragment)
    fragment.css("[class]").flat_map { |node| in_classes(node[:class]) }.uniq
  end

  def in_classes(classes)
    names = classes.split.uniq

    names.each_with_index.filter_map do |name, index|
      keys = UiComponent.tailwind_keys(name) or next
      later = names.drop(index + 1).find { |other| UiComponent.tailwind_keys(other)&.include?(keys.first) }
      "#{name} + #{later}" if later
    end
  end
end
