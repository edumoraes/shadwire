# frozen_string_literal: true

require "test_helper"

# UiComponent#class_names settles Tailwind conflicts the way shadcn's cn()
# does: of two utilities that set the same thing, the later one wins.
#
# Every component composes `base → variant → size → your class`, and the port
# took cn() for plain class_names. Plain class_names keeps both classes of a
# conflict, and the browser applies whichever one Tailwind emitted later —
# alphabetical for names, ascending for numbers. So `class: "w-80"` lost to a
# component's `w-full`, the outline Item kept its base's transparent border,
# the sidebar trigger stayed a 36px icon button and the ⌘K palette kept the
# dialog's padding.
class UiComponentTest < ViewComponent::TestCase
  def merge(classes)
    UiComponent.merge_classes(classes)
  end

  test "the later of two utilities that set the same thing wins" do
    assert_equal "py-2 h-8 px-2.5", merge("h-9 px-4 py-2 h-8 px-2.5")
    assert_equal "bg-accent", merge("bg-primary bg-accent")
    assert_equal "text-xs text-muted-foreground", merge("text-sm text-foreground text-xs text-muted-foreground")
    assert_equal "hidden", merge("inline-flex hidden")
    assert_equal "justify-between font-normal", merge("justify-center font-medium justify-between font-normal")
    assert_equal "rounded-full", merge("rounded-md rounded-full")
  end

  test "classes that set different things are all kept, in order" do
    classes = "flex items-center gap-2 text-sm text-muted-foreground border border-input shadow-xs"

    assert_equal classes, merge(classes)
  end

  test "variants and importance keep two classes apart" do
    assert_equal "bg-primary hover:bg-accent", merge("bg-primary hover:bg-accent")
    assert_equal "sm:max-w-lg max-w-md", merge("sm:max-w-lg max-w-md")
    assert_equal "h-8! h-9", merge("h-8! h-9")
    assert_equal "focus-visible:ring-destructive/20", merge("focus-visible:ring-ring/50 focus-visible:ring-destructive/20")
    assert_equal "[&_svg:not([class*='size-'])]:size-4 size-5", merge("[&_svg:not([class*='size-'])]:size-4 size-5")
  end

  test "a later shorthand overrides the longhands before it, not after it" do
    assert_equal "p-0", merge("px-4 py-2 p-0")
    assert_equal "p-6 px-0", merge("p-6 px-0")
    assert_equal "size-7", merge("h-9 w-9 size-7")
    assert_equal "border-0", merge("border border-l-2 border-0")
    assert_equal "rounded-none", merge("rounded-l-md rounded-none")
  end

  test "anything the table does not list is kept as given" do
    classes = "grid-cols-[calc(var(--spacing)*4)_1fr] -translate-y-1/2 data-[state=open]:animate-in inset-x-0"

    assert_equal classes, merge(classes)
  end

  # class_names escapes each token and marks the result safe; the merge must
  # keep it marked, or the attribute is escaped twice and `[&_svg]` reaches
  # the page as `[&amp;_svg]`.
  test "a selector-shaped class reaches the page unescaped" do
    render_inline(Ui::ButtonComponent.new(class: "[&>span]:truncate")) { "Save" }

    classes = page.find("button")[:class].split
    assert_includes classes, "[&_svg:not([class*='size-'])]:size-4"
    assert_includes classes, "[&>span]:truncate"
  end

  test "a caller's class replaces the component's own" do
    render_inline(Ui::ButtonComponent.new(size: :sm, class: "h-10 w-80")) { "Save" }

    classes = page.find("button")[:class].split
    assert_includes classes, "h-10"
    assert_includes classes, "w-80"
    refute_includes classes, "h-8"
  end
end
