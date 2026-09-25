# frozen_string_literal: true

require "test_helper"
require_relative "../support/class_conflicts"
require_relative "../support/component_catalog"

# The styling contracts the registry's components share, so that two controls
# side by side in a form look like they belong to the same library.
#
# Before this, the input had a 1px ring and the native select next to it a 3px
# one; the button, checkbox, radio, switch, select and tabs triggers each had
# their own; an explicit `ui_icon(size: :lg)` inside a button or a menu item was
# forced back to size-4; three overlay triggers defaulted to a primary button
# while the other four were outline.
class ComponentStyleTest < ViewComponent::TestCase
  SOURCE = Rails.root.join("../registry/rails/ui/components").freeze
  SOURCES = Dir[SOURCE.join("**/*.{rb,erb}")].sort.freeze

  FOCUS_RING = %w[focus-visible:ring-[3px] focus-visible:ring-ring/50].freeze
  INVALID_RING = %w[aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40].freeze

  # Upstream's own exceptions to the 3px ring, kept on purpose: the overlay
  # close X rings with an offset, the sidebar with its own token, and the
  # resizable handle is a hairline a 3px ring would swallow.
  THIN_RING_ALLOWED = %w[
    dialog/content_component.rb sheet/content_component.rb resizable_handle_component.rb
  ].freeze

  # Places that size every svg on purpose, as upstream does: the sidebar's menu
  # rows, the badge and alert icons, the breadcrumb chevron.
  FORCED_SVG_SIZE_ALLOWED = %w[
    alert_component.rb badge_component.rb breadcrumb/separator_component.rb
  ].freeze

  test "no control keeps a thin focus ring of its own" do
    offenders = SOURCES.filter_map do |path|
      relative = Pathname.new(path).relative_path_from(SOURCE).to_s
      next if THIN_RING_ALLOWED.include?(relative) || relative.start_with?("sidebar/")

      relative if File.read(path).match?(/focus(?:-visible)?:ring-(?:1|2)\b/)
    end

    assert_empty offenders, "these still use a 1px/2px focus ring instead of the shared 3px one"
  end

  test "no component forces its size on an icon that has one" do
    offenders = SOURCES.filter_map do |path|
      relative = Pathname.new(path).relative_path_from(SOURCE).to_s
      next if FORCED_SVG_SIZE_ALLOWED.include?(relative) || relative.start_with?("sidebar/")

      relative if File.read(path).match?(/\[&[_>]svg\]:size-/)
    end

    assert_empty offenders, "use [&_svg:not([class*='size-'])]:size-* so an explicit ui_icon size wins"
  end

  test "focusable controls share one focus ring" do
    {
      "button" => Ui::ButtonComponent.new,
      "input" => Ui::InputComponent.new,
      "textarea" => Ui::TextareaComponent.new,
      "input[type=checkbox]" => Ui::CheckboxComponent.new,
      "input[type=radio]" => Ui::RadioGroup::ItemComponent.new(name: "plan", value: "free"),
      "input[role=switch]" => Ui::SwitchComponent.new,
      "select" => Ui::NativeSelectComponent.new,
      "button[role=combobox]" => Ui::Select::TriggerComponent.new,
      "button[role=tab]" => Ui::Tabs::TriggerComponent.new(value: "one"),
      "[data-slot=accordion-trigger]" => Ui::Accordion::TriggerComponent.new,
      "[data-slot=toggle]" => Ui::ToggleComponent.new,
      "[data-slot=toggle-group-item]" => Ui::ToggleGroup::ItemComponent.new(value: "a"),
      "[data-slot=carousel-previous]" => Ui::Carousel::PreviousComponent.new,
      "[data-slot=carousel-next]" => Ui::Carousel::NextComponent.new,
      "[data-slot=input-group-button]" => Ui::InputGroup::ButtonComponent.new,
      "[data-slot=badge]" => Ui::BadgeComponent.new(tag: :a, href: "#"),
      "[data-slot=navigation-menu-link]" => Ui::NavigationMenu::LinkComponent.new(href: "#")
    }.each do |selector, component|
      render_inline(component) { "Label" }
      classes = page.find(selector, visible: :all)[:class].split

      FOCUS_RING.each do |utility|
        assert_includes classes, utility, "#{component.class} lacks #{utility}"
      end
    end
  end

  test "form controls share one invalid ring" do
    {
      "button" => Ui::ButtonComponent.new,
      "input" => Ui::InputComponent.new,
      "textarea" => Ui::TextareaComponent.new,
      "input[type=checkbox]" => Ui::CheckboxComponent.new,
      "input[type=radio]" => Ui::RadioGroup::ItemComponent.new(name: "plan", value: "free"),
      "select" => Ui::NativeSelectComponent.new,
      "button[role=combobox]" => Ui::Select::TriggerComponent.new
    }.each do |selector, component|
      render_inline(component) { "Label" }
      classes = page.find(selector, visible: :all)[:class].split

      INVALID_RING.each do |utility|
        assert_includes classes, utility, "#{component.class} lacks #{utility}"
      end
    end
  end

  test "an explicit icon size survives inside a button and a menu item" do
    [
      Ui::ButtonComponent.new,
      Ui::DropdownMenu::ItemComponent.new,
      Ui::ContextMenu::ItemComponent.new,
      Ui::Menubar::ItemComponent.new,
      Ui::Command::ItemComponent.new,
      Ui::Tabs::TriggerComponent.new(value: "one")
    ].each do |component|
      render_inline(component) { render_inline_icon }

      host = page.find("[data-slot]", match: :first, visible: :all)[:class]
      assert_includes host, "[&_svg:not([class*='size-'])]:size-4", "#{component.class} still forces its icon size"
      assert_selector "svg.size-5", visible: :all
    end
  end

  # Each is a Button underneath, and keeps its own slot over the button's.
  test "every overlay trigger defaults to an outline button" do
    {
      Ui::Dialog::TriggerComponent => "dialog-trigger", Ui::AlertDialog::TriggerComponent => "alert-dialog-trigger",
      Ui::Sheet::TriggerComponent => "sheet-trigger", Ui::Drawer::TriggerComponent => "drawer-trigger",
      Ui::DropdownMenu::TriggerComponent => "dropdown-menu-trigger", Ui::Popover::TriggerComponent => "popover-trigger",
      Ui::Tooltip::TriggerComponent => "tooltip-trigger"
    }.each do |trigger, slot|
      render_inline(trigger.new) { "Open" }

      button = page.find("button[data-slot='#{slot}']", text: "Open", visible: :all)
      assert_includes button[:class].split, "bg-background", "#{trigger} does not default to the outline variant"
      assert_includes button[:class].split, "border", "#{trigger} does not default to the outline variant"
    end
  end

  test "the menus' labels and destructive items look the same" do
    [ Ui::DropdownMenu::LabelComponent, Ui::ContextMenu::LabelComponent, Ui::Menubar::LabelComponent ].each do |label|
      render_inline(label.new) { "Account" }
      assert_selector "div.font-medium", text: "Account", visible: :all
    end

    [ Ui::DropdownMenu::ItemComponent, Ui::ContextMenu::ItemComponent, Ui::Menubar::ItemComponent ].each do |item|
      render_inline(item.new(variant: :destructive)) { "Delete" }
      assert_includes page.find("[data-slot]", match: :first, visible: :all)[:class],
                      "data-[variant=destructive]:focus:bg-destructive/10", "#{item} has no destructive focus"
    end
  end

  # Every component, in every variant and size: whatever the variant, the size
  # or a wrapping component overrides, only the override reaches the page.
  test "no component leaves two classes that set the same thing" do
    conflicts = ComponentCatalog::NAMES.flat_map do |name|
      component = name.constantize
      variants = component.const_defined?(:VARIANTS, false) ? component::VARIANTS.keys : [ nil ]
      sizes = component.const_defined?(:SIZES, false) ? component::SIZES.keys : [ nil ]

      variants.product(sizes).flat_map do |variant, size|
        options = { variant:, size: }.compact
        found = ClassConflicts.in_fragment(render_inline(ComponentCatalog.build(name, **options).with_content("x")))
        found.map { |pair| "#{name} #{options}: #{pair}" }
      end
    end

    assert_empty conflicts, "both classes reach the page, and the stylesheet — not the order — picks one:\n#{conflicts.join("\n")}"
  end

  # Overrides that lost to the class they override until class_names merged
  # them; each rendered wrong on the site.
  test "the overrides the components make take effect" do
    [
      [ Ui::ItemComponent.new(variant: :outline), "[data-slot=item]", %w[border-border], %w[border-transparent] ],
      [ Ui::ButtonComponent.new(variant: :destructive), "button", %w[focus-visible:ring-destructive/20], %w[focus-visible:ring-ring/50] ],
      [ Ui::BadgeComponent.new(variant: :destructive), "span", %w[focus-visible:ring-destructive/20], %w[focus-visible:ring-ring/50] ],
      [ Ui::ToggleComponent.new(variant: :outline), "button", %w[hover:bg-accent], %w[hover:bg-muted] ],
      [ Ui::ToggleGroup::ItemComponent.new(value: "a", variant: :outline), "button", %w[hover:bg-accent], %w[hover:bg-muted] ],
      [ Ui::Sidebar::TriggerComponent.new, "button", %w[size-7], %w[size-9] ],
      [ Ui::Sidebar::InputComponent.new, "input", %w[h-8 bg-background shadow-none], %w[h-9 bg-transparent shadow-xs] ],
      [ Ui::Sidebar::SeparatorComponent.new, "[data-slot=sidebar-separator]", %w[w-auto bg-sidebar-border], %w[w-full bg-border] ],
      [ Ui::Sidebar::MenuButtonComponent.new(size: :lg), "button", %w[group-data-[collapsible=icon]:p-0!], %w[group-data-[collapsible=icon]:p-2!] ],
      [ Ui::ButtonGroup::SeparatorComponent.new, "[data-slot=button-group-separator]", %w[bg-input], %w[bg-border] ],
      [ Ui::Pagination::PreviousComponent.new(href: "#"), "a", %w[gap-1 px-2.5], %w[gap-2 px-4] ],
      [ Ui::NavigationMenu::TriggerComponent.new, "svg", %w[size-3], %w[size-4] ]
    ].each do |component, selector, present, absent|
      render_inline(component) { "x" }
      classes = page.find(selector, match: :first, visible: :all)[:class].split

      present.each { |utility| assert_includes classes, utility, "#{component.class} lacks #{utility}" }
      absent.each { |utility| refute_includes classes, utility, "#{component.class} still carries #{utility}" }
    end
  end

  private

  def render_inline_icon
    ApplicationController.render(Ui::IconComponent.new("download", size: :lg), layout: false)
  end
end
