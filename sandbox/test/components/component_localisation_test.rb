# frozen_string_literal: true

require "test_helper"
require_relative "../support/component_catalog"

# What an installed component says, it says in the app's language.
#
# Four components announced English literals whatever the locale: the
# pagination and breadcrumb landmarks, the sidebar's toggle, the carousel's
# roledescriptions — so a Portuguese page read out "pagination" and "Toggle
# Sidebar". Two went the other way: the calendar's month and day names were
# Portuguese literals, so every English page showed "Setembro" over "Dom Seg",
# and the data table counted "Página 1 de 3" in any language.
#
# Every component is rendered in both of the sandbox's languages; an accessible
# string that comes out the same in both was never looked up.
class ComponentLocalisationTest < ViewComponent::TestCase
  # Text written for a screen reader, or shown to anyone hovering.
  ACCESSIBLE_ATTRIBUTES = %w[aria-label aria-roledescription aria-description title placeholder].freeze

  # Portuguese uses the English word.
  SAME_IN_BOTH = %w[slide].freeze

  ComponentCatalog::NAMES.each do |class_name|
    define_method("test_#{class_name.underscore.tr("/", "_")}_speaks_the_locale") do
      english = accessible_strings(class_name, :en)
      portuguese = accessible_strings(class_name, :pt)

      untranslated = (english & portuguese) - SAME_IN_BOTH
      assert_empty untranslated, "#{class_name} renders these whatever the locale: #{untranslated.join(", ")}"
    end
  end

  test "the landmarks and the sidebar toggle read in Portuguese" do
    I18n.with_locale(:pt) do
      render_inline(Ui::PaginationComponent.new) { "" }
      assert_selector "nav[aria-label='paginação']"

      render_inline(Ui::BreadcrumbComponent.new) { "" }
      assert_selector "nav[aria-label='trilha de navegação']"

      render_inline(Ui::Sidebar::TriggerComponent.new)
      assert_selector "button .sr-only", text: "Alternar barra lateral"

      render_inline(Ui::Sidebar::RailComponent.new)
      assert_selector "button[aria-label='Alternar barra lateral'][title='Alternar barra lateral']"

      render_inline(Ui::CarouselComponent.new) { "" }
      assert_selector "[aria-roledescription='carrossel']"
    end
  end

  test "the calendar names its months and days in the locale" do
    render_inline(Ui::CalendarComponent.new(name: "date"))
    calendar = page.find("[data-controller~='ui-calendar']", visible: :all)
    assert_equal "January", JSON.parse(calendar["data-ui-calendar-month-names-value"]).first
    assert_equal "Sun", JSON.parse(calendar["data-ui-calendar-day-names-value"]).first

    I18n.with_locale(:pt) { render_inline(Ui::CalendarComponent.new(name: "date")) }
    calendar = page.find("[data-controller~='ui-calendar']", visible: :all)
    assert_equal "Janeiro", JSON.parse(calendar["data-ui-calendar-month-names-value"]).first
    assert_equal "Dom", JSON.parse(calendar["data-ui-calendar-day-names-value"]).first
  end

  test "names passed to the calendar win over the locale's" do
    render_inline(Ui::CalendarComponent.new(name: "date", day_names: %w[S M T W T F S]))

    calendar = page.find("[data-controller~='ui-calendar']", visible: :all)
    assert_equal %w[S M T W T F S], JSON.parse(calendar["data-ui-calendar-day-names-value"])
    assert_equal "January", JSON.parse(calendar["data-ui-calendar-month-names-value"]).first
  end

  # The fallback the JavaScript uses when the component sends no names — an app
  # whose locale has no date.* keys — is English, like every other default.
  test "the calendar controller falls back to English names" do
    source = Rails.root.join("app/javascript/controllers/ui_calendar_controller.js").read

    assert_match(/"January"/, source)
    assert_match(/"Sun"/, source)
    assert_no_match(/Janeiro|Setembro|"Dom"/, source)
  end

  test "the data table's page count is a translated template" do
    table = -> { Ui::DataTableComponent.new(columns: [ { key: :name, label: "Name" } ], rows: [ { name: "Ada" } ], per_page: 1) }

    render_inline(table.call)
    assert_selector "[data-ui-data-table-page-label-value='Page %{page} of %{total}']", visible: :all

    I18n.with_locale(:pt) { render_inline(table.call) }
    assert_selector "[data-ui-data-table-page-label-value='Página %{page} de %{total}']", visible: :all

    source = Rails.root.join("app/javascript/controllers/ui_data_table_controller.js").read
    assert_no_match(/Página|" de "/, source, "the controller still writes its own Portuguese")
  end

  private

  def accessible_strings(class_name, locale)
    fragment = I18n.with_locale(locale) do
      render_inline(ComponentCatalog.build(class_name).with_content("content"))
    end

    attributes = fragment.css(ACCESSIBLE_ATTRIBUTES.map { |name| "[#{name}]" }.join(", "))
                         .flat_map { |node| ACCESSIBLE_ATTRIBUTES.filter_map { |name| node[name] } }
    hidden_text = fragment.css(".sr-only").map { |node| node.text.strip }

    (attributes + hidden_text).select { |text| text.match?(/[[:alpha:]]/) } - [ "content" ]
  end
end
