# frozen_string_literal: true

# Serves the component documentation pages of the sandbox.
class ComponentsController < ApplicationController
  # The catalog and the documentation pages share the documentation shell:
  # header, topic sidebar, breadcrumb, the on-this-page rail and the footer.
  layout "docs"

  BUTTON_EXAMPLES = %w[default secondary destructive outline ghost link icon with_icon sizes loading disabled as_link].freeze

  USAGE_HELPER = <<~ERB
    <%= ui_button { "Save" } %>
    <%= ui_button(variant: :outline, size: :sm) { "Cancel" } %>
  ERB

  USAGE_COMPONENT = <<~ERB
    <%= render Ui::ButtonComponent.new(variant: :destructive) do %>
      Delete
    <% end %>
  ERB

  CHART_EXAMPLES = %w[
    chart_bar_horizontal chart_bar_stacked chart_line chart_area chart_pie chart_radar chart_radial chart_tooltip chart_layer
  ].freeze

  # The chart page builds one chart a part at a time, so most of these are its
  # steps: each is the one before with a part added.
  CHART_SNIPPETS = {
    importmap: <<~RUBY,
      # config/importmap.rb — the CLI adds it with the component.
      pin "d3", to: "https://cdn.jsdelivr.net/npm/d3@7.9.0/+esm"
    RUBY

    rows: <<~RUBY,
      rows = [
        { month: Date.new(2024, 1), desktop: 186, mobile: 80 },
        { month: Date.new(2024, 2), desktop: 305, mobile: 200 },
        { month: Date.new(2024, 3), desktop: 237, mobile: 120 },
        { month: Date.new(2024, 4), desktop: 73, mobile: 190 },
        { month: Date.new(2024, 5), desktop: 209, mobile: 130 },
        { month: Date.new(2024, 6), desktop: 214, mobile: 140 }
      ]
    RUBY

    config: <<~RUBY,
      config = {
        desktop: { label: "Desktop", color: "var(--chart-1)" },
        mobile: { label: "Mobile", color: "var(--chart-2)" }
      }
    RUBY

    bars: <<~ERB,
      <%= ui_chart(config: config, rows: rows, class: "min-h-[200px] w-full") do %>
        <%= ui_chart_bar(data_key: :desktop, radius: 4) %>
        <%= ui_chart_bar(data_key: :mobile, radius: 4) %>
      <% end %>
    ERB

    grid: <<~ERB,
      <%= ui_chart(config: config, rows: rows, class: "min-h-[200px] w-full") do %>
        <%= ui_chart_grid %>
        <%= ui_chart_bar(data_key: :desktop, radius: 4) %>
        <%= ui_chart_bar(data_key: :mobile, radius: 4) %>
      <% end %>
    ERB

    axis: <<~ERB,
      <%= ui_chart(config: config, rows: rows, class: "min-h-[200px] w-full") do %>
        <%= ui_chart_grid %>
        <%= ui_chart_x_axis(data_key: :month, tick_format: "%b") %>
        <%= ui_chart_bar(data_key: :desktop, radius: 4) %>
        <%= ui_chart_bar(data_key: :mobile, radius: 4) %>
      <% end %>
    ERB

    tooltip: <<~ERB,
      <%= ui_chart(config: config, rows: rows, class: "min-h-[200px] w-full") do %>
        <%= ui_chart_grid %>
        <%= ui_chart_x_axis(data_key: :month, tick_format: "%b") %>
        <%= ui_chart_tooltip(label_format: "%B") %>
        <%= ui_chart_bar(data_key: :desktop, radius: 4) %>
        <%= ui_chart_bar(data_key: :mobile, radius: 4) %>
      <% end %>
    ERB

    legend: <<~ERB,
      <%= ui_chart(config: config, rows: rows, class: "min-h-[200px] w-full") do %>
        <%= ui_chart_grid %>
        <%= ui_chart_x_axis(data_key: :month, tick_format: "%b") %>
        <%= ui_chart_tooltip(label_format: "%B") %>
        <%= ui_chart_legend %>
        <%= ui_chart_bar(data_key: :desktop, radius: 4) %>
        <%= ui_chart_bar(data_key: :mobile, radius: 4) %>
      <% end %>
    ERB

    composition: <<~TEXT,
      ui_chart                          rows, config, layout: what every part shares
      |-- ui_chart_grid
      |-- ui_chart_x_axis / ui_chart_y_axis
      |-- ui_chart_bar / ui_chart_line / ui_chart_area
      |   `-- ui_chart_label_list       labels on the series' points
      |-- ui_chart_pie / ui_chart_radial_bar / ui_chart_radar
      |   `-- ui_chart_label_list
      |-- ui_chart_polar_grid / ui_chart_polar_angle_axis
      |-- ui_chart_tooltip
      |-- ui_chart_legend
      |-- ui_chart_layer                a layer you draw with D3
      `-- your markup                   a total in a donut, a note over the plot
    TEXT

    config_full: <<~RUBY,
      config = {
        desktop: {
          label: "Desktop",
          icon: "monitor",              # a Lucide icon, for the legend and the tooltip
          color: "#2563eb"              # any CSS color, or var(--chart-1)…
        },
        mobile: {
          label: "Mobile",
          theme: { light: "#60a5fa", dark: "#1d4ed8" }  # …or one per theme
        }
      }
    RUBY

    theme_tokens: <<~CSS,
      /* vendor/shadwire/shadwire.css */
      :root {
        --chart-1: oklch(0.646 0.222 41.116);
        --chart-2: oklch(0.6 0.118 184.704);
      }

      .dark {
        --chart-1: oklch(0.488 0.243 264.376);
        --chart-2: oklch(0.696 0.17 162.48);
      }
    CSS

    colors_elsewhere: <<~ERB,
      <%# A part's own color, over the config's %>
      <%= ui_chart_bar(data_key: :desktop, color: "var(--chart-3)") %>

      <%# A row's own color: slices and bars take a row's `fill` %>
      <% rows = [ { browser: "chrome", visitors: 275, fill: "var(--color-chrome)" } ] %>

      <%# And your own markup, inside the chart %>
      <span class="text-(--color-desktop)">Desktop</span>
    ERB

    tooltip_keys: <<~ERB,
      <%= ui_chart(config: { visitors: { label: "Total visitors" },
                             chrome: { label: "Chrome", color: "var(--chart-1)" },
                             safari: { label: "Safari", color: "var(--chart-2)" } },
                   rows: [ { browser: "chrome", visitors: 187 },
                           { browser: "safari", visitors: 200 } ]) do %>
        <%# "Total visitors" as the label, "Chrome" and "Safari" as the names %>
        <%= ui_chart_tooltip(label_key: :visitors) %>
        <%= ui_chart_pie(data_key: :visitors, name_key: :browser) %>
      <% end %>
    ERB

    legend_name_key: <<~ERB,
      <%# One entry per bar, named by its browser, rather than one for the series %>
      <%= ui_chart_legend(name_key: :browser) %>
    ERB

    formats: <<~ERB,
      <%= ui_chart_y_axis(tick_format: "~s") %>              <%# 1.2k %>
      <%= ui_chart_y_axis(tick_format: "$,.0f") %>           <%# $1,234 %>
      <%= ui_chart_x_axis(data_key: :day, tick_format: "%b %-d") %>  <%# Apr 1 %>
      <%= ui_chart_tooltip(label_format: "%A, %B %-d", value_format: ".1f") %>
    ERB

    layer: <<~ERB,
      <%= ui_chart(config: config, rows: rows, class: "min-h-[200px] w-full") do %>
        <%= ui_chart_bar(data_key: :desktop, radius: 4) %>
        <%= ui_chart_layer(controller: "chart-goal", options: { value: 250, label: "Goal" },
              class: "stroke-foreground fill-foreground") %>
      <% end %>
    ERB

    events: <<~TEXT
      ui-chart:layout     before the plot is sized: event.detail.reserve(side, px) claims room at an edge
      ui-chart:render     the scales are ready: draw from event.detail.chart and event.detail.options
      ui-chart:highlight  the tooltip moved: event.detail.active is { index } or null
    TEXT
  }.freeze

  BADGE_EXAMPLES = %w[badge_variants].freeze

  BADGE_USAGE_HELPER = <<~ERB
    <%= ui_badge { "Badge" } %>
    <%= ui_badge(variant: :secondary) { "Secondary" } %>
  ERB

  BADGE_USAGE_COMPONENT = <<~ERB
    <%= render Ui::BadgeComponent.new(variant: :outline) do %>
      Outline
    <% end %>
  ERB

  CARD_EXAMPLES = %w[card_default].freeze

  CARD_USAGE_HELPER = <<~ERB
    <%= ui_card do %>
      <%= ui_card_header do %>
        <%= ui_card_title { "Create project" } %>
        <%= ui_card_description { "Deploy your new project in one click." } %>
      <% end %>
      <%= ui_card_content { "Card content." } %>
    <% end %>
  ERB

  CARD_USAGE_COMPONENT = <<~ERB
    <%= render Ui::CardComponent.new do %>
      <%= render Ui::Card::HeaderComponent.new do %>
        <%= render Ui::Card::TitleComponent.new do %>
          Create project
        <% end %>
      <% end %>
    <% end %>
  ERB

  CARD_COMPOSITION = <<~TEXT
    Card
    |-- Card::Header
    |   |-- Card::Title
    |   `-- Card::Description
    |-- Card::Content
    `-- Card::Footer
  TEXT

  ALERT_EXAMPLES = %w[alert_default alert_destructive].freeze

  ALERT_USAGE_HELPER = <<~ERB
    <%= ui_alert do %>
      <%= ui_icon("terminal") %>
      <%= ui_alert_title { "Heads up!" } %>
      <%= ui_alert_description { "You can add components to your app with the CLI." } %>
    <% end %>
  ERB

  ALERT_USAGE_COMPONENT = <<~ERB
    <%= render Ui::AlertComponent.new(variant: :destructive) do %>
      <%= render Ui::Alert::TitleComponent.new do %>
        Could not save your changes.
      <% end %>
    <% end %>
  ERB

  SEPARATOR_EXAMPLES = %w[separator_default].freeze

  SEPARATOR_USAGE_HELPER = <<~ERB
    <%= ui_separator %>
    <%= ui_separator(orientation: :vertical, class: "h-5") %>
  ERB

  SEPARATOR_USAGE_COMPONENT = <<~ERB
    <%= render Ui::SeparatorComponent.new(decorative: true) %>
  ERB

  AVATAR_EXAMPLES = %w[avatar_default].freeze

  AVATAR_USAGE_HELPER = <<~ERB
    <%= ui_avatar(src: "/avatar.png", alt: "Eduardo Moraes", fallback: "EM") %>
  ERB

  AVATAR_USAGE_COMPONENT = <<~ERB
    <%= render Ui::AvatarComponent.new(fallback: "EM", aria: { label: "Eduardo Moraes" }) %>
  ERB

  ICON_EXAMPLES = %w[icon_default].freeze

  ICON_USAGE_HELPER = <<~ERB
    <%= ui_icon("download") %>
    <%= ui_icon("bell", label: "Notifications") %>
  ERB

  ICON_USAGE_COMPONENT = <<~ERB
    <%= render Ui::IconComponent.new("download", size: :lg) %>
  ERB

  ACCORDION_EXAMPLES = %w[accordion_basic accordion_multiple accordion_disabled accordion_borders accordion_card].freeze

  ACCORDION_USAGE_HELPER = <<~ERB
    <%= ui_accordion(default_value: :item_1) do %>
      <%= ui_accordion_item(value: :item_1) do %>
        <%= ui_accordion_header do %>
          <%= ui_accordion_trigger { "Is it accessible?" } %>
        <% end %>
        <%= ui_accordion_content do %>
          Yes. It follows the WAI-ARIA pattern for accordions.
        <% end %>
      <% end %>
    <% end %>
  ERB

  ACCORDION_USAGE_COMPONENT = <<~ERB
    <%= render Ui::AccordionComponent.new(default_value: :item_1) do %>
      <%= render Ui::Accordion::ItemComponent.new(value: :item_1) do %>
        <%= render Ui::Accordion::HeaderComponent.new do %>
          <%= render Ui::Accordion::TriggerComponent.new do %>
            Is it accessible?
          <% end %>
        <% end %>
        <%= render Ui::Accordion::ContentComponent.new do %>
          Yes. It follows the WAI-ARIA pattern for accordions.
        <% end %>
      <% end %>
    <% end %>
  ERB

  ACCORDION_COMPOSITION = <<~ERB
    <%= ui_accordion do %>
      <%= ui_accordion_item do %>
        <%= ui_accordion_header do %>
          <%= ui_accordion_trigger { "Title" } %>
        <% end %>
        <%= ui_accordion_content { "Content" } %>
      <% end %>
    <% end %>
  ERB

  SCROLL_AREA_EXAMPLES = %w[scroll_area_vertical scroll_area_horizontal scroll_area_rtl].freeze

  SCROLL_AREA_USAGE_HELPER = <<~ERB
    <%= ui_scroll_area(class: "h-[200px] w-[350px] rounded-md border p-4") do %>
      Your scrollable content here.
    <% end %>
  ERB

  SCROLL_AREA_USAGE_COMPONENT = <<~ERB
    <%= render Ui::ScrollAreaComponent.new(class: "h-[200px] w-[350px] rounded-md border p-4") do %>
      Your scrollable content here.
    <% end %>
  ERB

  SCROLL_AREA_COMPOSITION = <<~TEXT
    ScrollArea
    `-- ScrollBar
  TEXT

  SCROLL_AREA_USAGE_HORIZONTAL = <<~ERB
    <%= ui_scroll_area(scrollbars: [ :horizontal ], class: "w-96 rounded-md border whitespace-nowrap") do %>
      <div class="flex w-max gap-4 p-4">...</div>
    <% end %>
  ERB

  SCROLL_AREA_RTL = <<~ERB
    <%= ui_scroll_area(dir: "rtl", class: "h-[200px] w-[350px] rounded-md border p-4") do %>
      المحتوى القابل للتمرير هنا.
    <% end %>
  ERB

  INPUT_EXAMPLES = %w[input_default input_with_label input_disabled input_file input_form].freeze

  INPUT_USAGE_HELPER = <<~ERB
    <%= ui_input(type: :email, placeholder: "you@example.com") %>
  ERB

  INPUT_USAGE_COMPONENT = <<~ERB
    <%= render Ui::InputComponent.new(type: :email, name: "user[email]") %>
  ERB

  LABEL_EXAMPLES = %w[label_default label_disabled].freeze

  LABEL_USAGE_HELPER = <<~ERB
    <%= ui_label(for: "email") { "Email" } %>
    <%= ui_input(type: :email, id: "email") %>
  ERB

  LABEL_USAGE_COMPONENT = <<~ERB
    <%= render Ui::LabelComponent.new(for: "email") do %>
      Email
    <% end %>
  ERB

  TEXTAREA_EXAMPLES = %w[textarea_default textarea_with_label textarea_disabled].freeze

  TEXTAREA_USAGE_HELPER = <<~ERB
    <%= ui_textarea(name: "post[body]", placeholder: "Type your message here.") %>
  ERB

  TEXTAREA_USAGE_COMPONENT = <<~ERB
    <%= render Ui::TextareaComponent.new(placeholder: "Type your message here.") do %>
      Initial content
    <% end %>
  ERB

  CHECKBOX_EXAMPLES = %w[checkbox_default checkbox_checked checkbox_disabled checkbox_form].freeze

  CHECKBOX_USAGE_HELPER = <<~ERB
    <%= ui_checkbox(id: "terms") %>
    <%= ui_label(for: "terms") { "Accept terms" } %>
  ERB

  CHECKBOX_USAGE_COMPONENT = <<~ERB
    <%= render Ui::CheckboxComponent.new(name: "user[terms]", checked: true) %>
  ERB

  def button
    @examples = examples_for(BUTTON_EXAMPLES)
    @usage_helper = USAGE_HELPER
    @usage_component = USAGE_COMPONENT
  end

  def badge
    @examples = examples_for(BADGE_EXAMPLES)
    @usage_helper = BADGE_USAGE_HELPER
    @usage_component = BADGE_USAGE_COMPONENT
  end

  def card
    @examples = examples_for(CARD_EXAMPLES)
    @usage_helper = CARD_USAGE_HELPER
    @usage_component = CARD_USAGE_COMPONENT
    @composition = CARD_COMPOSITION
  end

  def alert
    @examples = examples_for(ALERT_EXAMPLES)
    @usage_helper = ALERT_USAGE_HELPER
    @usage_component = ALERT_USAGE_COMPONENT
  end

  def separator
    @examples = examples_for(SEPARATOR_EXAMPLES)
    @usage_helper = SEPARATOR_USAGE_HELPER
    @usage_component = SEPARATOR_USAGE_COMPONENT
  end

  def avatar
    @examples = examples_for(AVATAR_EXAMPLES)
    @usage_helper = AVATAR_USAGE_HELPER
    @usage_component = AVATAR_USAGE_COMPONENT
  end

  def icon
    @examples = examples_for(ICON_EXAMPLES)
    @usage_helper = ICON_USAGE_HELPER
    @usage_component = ICON_USAGE_COMPONENT
  end

  RADIO_GROUP_EXAMPLES = %w[radio_group_default radio_group_disabled radio_group_form].freeze

  RADIO_GROUP_USAGE_HELPER = <<~ERB
    <%= ui_radio_group(aria: { label: "Plan" }) do %>
      <div class="flex items-center gap-2">
        <%= ui_radio_group_item(name: "plan", value: "free", id: "plan-free", checked: true) %>
        <%= ui_label(for: "plan-free") { "Free" } %>
      </div>
    <% end %>
  ERB

  RADIO_GROUP_USAGE_COMPONENT = <<~ERB
    <%= render Ui::RadioGroupComponent.new do %>
      <%= render Ui::RadioGroup::ItemComponent.new(name: "plan", value: "free") %>
    <% end %>
  ERB

  RADIO_GROUP_COMPOSITION = <<~TEXT
    RadioGroup
    `-- RadioGroup::Item (one per option, same name:)
  TEXT

  def checkbox
    @examples = examples_for(CHECKBOX_EXAMPLES)
    @usage_helper = CHECKBOX_USAGE_HELPER
    @usage_component = CHECKBOX_USAGE_COMPONENT
  end

  SWITCH_EXAMPLES = %w[switch_default switch_checked switch_disabled switch_form].freeze

  SWITCH_USAGE_HELPER = <<~ERB
    <%= ui_switch(id: "airplane-mode") %>
    <%= ui_label(for: "airplane-mode") { "Airplane mode" } %>
  ERB

  SWITCH_USAGE_COMPONENT = <<~ERB
    <%= render Ui::SwitchComponent.new(name: "settings[airplane]", checked: true) %>
  ERB

  def radio_group
    @examples = examples_for(RADIO_GROUP_EXAMPLES)
    @usage_helper = RADIO_GROUP_USAGE_HELPER
    @usage_component = RADIO_GROUP_USAGE_COMPONENT
    @composition = RADIO_GROUP_COMPOSITION
  end

  SKELETON_EXAMPLES = %w[skeleton_default skeleton_card].freeze

  SKELETON_USAGE_HELPER = <<~ERB
    <%= ui_skeleton(class: "h-4 w-48") %>
  ERB

  SKELETON_USAGE_COMPONENT = <<~ERB
    <%= render Ui::SkeletonComponent.new(class: "size-10 rounded-full") %>
  ERB

  def switch
    @examples = examples_for(SWITCH_EXAMPLES)
    @usage_helper = SWITCH_USAGE_HELPER
    @usage_component = SWITCH_USAGE_COMPONENT
  end

  PROGRESS_EXAMPLES = %w[progress_default progress_values progress_custom].freeze

  PROGRESS_USAGE_HELPER = <<~ERB
    <%= ui_progress(value: 60, aria: { label: "Upload progress" }) %>
  ERB

  PROGRESS_USAGE_COMPONENT = <<~ERB
    <%= render Ui::ProgressComponent.new(value: 8, max: 12) %>
  ERB

  def skeleton
    @examples = examples_for(SKELETON_EXAMPLES)
    @usage_helper = SKELETON_USAGE_HELPER
    @usage_component = SKELETON_USAGE_COMPONENT
  end

  TABLE_EXAMPLES = %w[table_demo table_selected].freeze

  TABLE_USAGE_HELPER = <<~ERB
    <%= ui_table do %>
      <%= ui_table_header do %>
        <%= ui_table_row do %>
          <%= ui_table_head(scope: "col") { "Fatura" } %>
        <% end %>
      <% end %>
      <%= ui_table_body do %>
        <%= ui_table_row do %>
          <%= ui_table_cell { "INV001" } %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  TABLE_USAGE_COMPONENT = <<~ERB
    <%= render Ui::TableComponent.new do %>
      <%= render Ui::Table::BodyComponent.new do %>
        <%= render Ui::Table::RowComponent.new do %>
          <%= render Ui::Table::CellComponent.new do %>
            INV001
          <% end %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  TABLE_COMPOSITION = <<~TEXT
    Table (overflow container + <table>)
    |-- Table::Caption
    |-- Table::Header
    |   `-- Table::Row > Table::Head (th)
    |-- Table::Body
    |   `-- Table::Row > Table::Cell (td)
    `-- Table::Footer
        `-- Table::Row > Table::Cell
  TEXT

  def progress
    @examples = examples_for(PROGRESS_EXAMPLES)
    @usage_helper = PROGRESS_USAGE_HELPER
    @usage_component = PROGRESS_USAGE_COMPONENT
  end

  BREADCRUMB_EXAMPLES = %w[breadcrumb_default breadcrumb_ellipsis breadcrumb_custom_separator].freeze

  BREADCRUMB_USAGE_HELPER = <<~ERB
    <%= ui_breadcrumb do %>
      <%= ui_breadcrumb_list do %>
        <%= ui_breadcrumb_item do %>
          <%= ui_breadcrumb_link(href: "/") { "Home" } %>
        <% end %>
        <%= ui_breadcrumb_separator %>
        <%= ui_breadcrumb_item do %>
          <%= ui_breadcrumb_page { "Current page" } %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  BREADCRUMB_USAGE_COMPONENT = <<~ERB
    <%= render Ui::BreadcrumbComponent.new do %>
      <%= render Ui::Breadcrumb::ListComponent.new do %>
        <%= render Ui::Breadcrumb::ItemComponent.new do %>
          <%= render Ui::Breadcrumb::PageComponent.new do %>
            Current page
          <% end %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  BREADCRUMB_COMPOSITION = <<~TEXT
    Breadcrumb (nav aria-label="breadcrumb")
    `-- Breadcrumb::List (ol)
        |-- Breadcrumb::Item (li) > Breadcrumb::Link (a) or Breadcrumb::Page (span)
        |-- Breadcrumb::Separator (decorative li)
        `-- Breadcrumb::Ellipsis (decorative span)
  TEXT

  def table
    @examples = examples_for(TABLE_EXAMPLES)
    @usage_helper = TABLE_USAGE_HELPER
    @usage_component = TABLE_USAGE_COMPONENT
    @composition = TABLE_COMPOSITION
  end

  PAGINATION_EXAMPLES = %w[pagination_default].freeze

  PAGINATION_USAGE_HELPER = <<~ERB
    <%= ui_pagination do %>
      <%= ui_pagination_content do %>
        <%= ui_pagination_item do %>
          <%= ui_pagination_previous(href: "?page=1") %>
        <% end %>
        <%= ui_pagination_item do %>
          <%= ui_pagination_link(href: "?page=2", active: true) { "2" } %>
        <% end %>
        <%= ui_pagination_item do %>
          <%= ui_pagination_next(href: "?page=3") %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  PAGINATION_USAGE_COMPONENT = <<~ERB
    <%= render Ui::Pagination::LinkComponent.new(href: "?page=2", active: true) do %>
      2
    <% end %>
  ERB

  PAGINATION_COMPOSITION = <<~TEXT
    Pagination (nav role="navigation" aria-label="pagination")
    `-- Pagination::Content (ul)
        |-- Pagination::Item (li) > Pagination::Previous / Pagination::Link / Pagination::Next
        `-- Pagination::Item (li) > Pagination::Ellipsis
  TEXT

  def breadcrumb
    @examples = examples_for(BREADCRUMB_EXAMPLES)
    @usage_helper = BREADCRUMB_USAGE_HELPER
    @usage_component = BREADCRUMB_USAGE_COMPONENT
    @composition = BREADCRUMB_COMPOSITION
  end

  TABS_EXAMPLES = %w[tabs_default tabs_disabled].freeze

  TABS_USAGE_HELPER = <<~ERB
    <%= ui_tabs(default_value: :account) do %>
      <%= ui_tabs_list do %>
        <%= ui_tabs_trigger(value: :account) { "Account" } %>
        <%= ui_tabs_trigger(value: :password) { "Password" } %>
      <% end %>
      <%= ui_tabs_content(value: :account) { "Account settings" } %>
      <%= ui_tabs_content(value: :password) { "Password settings" } %>
    <% end %>
  ERB

  TABS_USAGE_COMPONENT = <<~ERB
    <%= render Ui::TabsComponent.new(default_value: :account) do %>
      <%= render Ui::Tabs::ListComponent.new do %>
        <%= render Ui::Tabs::TriggerComponent.new(value: :account) do %>
          Account
        <% end %>
      <% end %>
      <%= render Ui::Tabs::ContentComponent.new(value: :account) do %>
        Account settings
      <% end %>
    <% end %>
  ERB

  TABS_COMPOSITION = <<~TEXT
    Tabs (data-controller="ui-tabs")
    |-- Tabs::List (role="tablist")
    |   `-- Tabs::Trigger (role="tab", one per panel)
    `-- Tabs::Content (role="tabpanel", one per value)
  TEXT

  def pagination
    @examples = examples_for(PAGINATION_EXAMPLES)
    @usage_helper = PAGINATION_USAGE_HELPER
    @usage_component = PAGINATION_USAGE_COMPONENT
    @composition = PAGINATION_COMPOSITION
  end

  DIALOG_EXAMPLES = %w[dialog_default dialog_no_backdrop_close dialog_custom_close].freeze

  DIALOG_USAGE_HELPER = <<~ERB
    <%= ui_dialog do %>
      <%= ui_dialog_trigger(variant: :outline) { "Open" } %>
      <%= ui_dialog_content do %>
        <%= ui_dialog_header do %>
          <%= ui_dialog_title { "Title" } %>
          <%= ui_dialog_description { "The dialog's description." } %>
        <% end %>
        <%= ui_dialog_footer do %>
          <%= ui_dialog_close { "Cancel" } %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  DIALOG_USAGE_COMPONENT = <<~ERB
    <%= render Ui::DialogComponent.new do %>
      <%= render Ui::Dialog::TriggerComponent.new do %>
        Open
      <% end %>
      <%= render Ui::Dialog::ContentComponent.new do %>
        <%= render Ui::Dialog::TitleComponent.new do %>
          Title
        <% end %>
      <% end %>
    <% end %>
  ERB

  DIALOG_COMPOSITION = <<~TEXT
    Dialog (data-controller="ui-dialog")
    |-- Dialog::Trigger (a Button that calls showModal)
    `-- Dialog::Content (native <dialog>)
        |-- Dialog::Header > Dialog::Title + Dialog::Description
        `-- Dialog::Footer > Dialog::Close (Button)
  TEXT

  def tabs
    @examples = examples_for(TABS_EXAMPLES)
    @usage_helper = TABS_USAGE_HELPER
    @usage_component = TABS_USAGE_COMPONENT
    @composition = TABS_COMPOSITION
  end

  ALERT_DIALOG_EXAMPLES = %w[alert_dialog_default].freeze

  ALERT_DIALOG_USAGE_HELPER = <<~ERB
    <%= ui_alert_dialog do %>
      <%= ui_alert_dialog_trigger(variant: :destructive) { "Delete" } %>
      <%= ui_alert_dialog_content do %>
        <%= ui_alert_dialog_header do %>
          <%= ui_alert_dialog_title { "Are you sure?" } %>
          <%= ui_alert_dialog_description { "This action cannot be undone." } %>
        <% end %>
        <%= ui_alert_dialog_footer do %>
          <%= ui_alert_dialog_cancel { "Cancel" } %>
          <%= ui_alert_dialog_action { "Continue" } %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  ALERT_DIALOG_USAGE_COMPONENT = <<~ERB
    <%= render Ui::AlertDialogComponent.new do %>
      <%= render Ui::AlertDialog::TriggerComponent.new do %>
        Delete
      <% end %>
      <%= render Ui::AlertDialog::ContentComponent.new do %>
        <%= render Ui::AlertDialog::TitleComponent.new do %>
          Are you sure?
        <% end %>
      <% end %>
    <% end %>
  ERB

  ALERT_DIALOG_COMPOSITION = <<~TEXT
    AlertDialog (ui-dialog with backdrop and Esc dismissal off)
    |-- AlertDialog::Trigger (Button)
    `-- AlertDialog::Content (<dialog role="alertdialog">, no X)
        |-- AlertDialog::Header > AlertDialog::Title + AlertDialog::Description
        `-- AlertDialog::Footer > AlertDialog::Cancel + AlertDialog::Action
  TEXT

  def dialog
    @examples = examples_for(DIALOG_EXAMPLES)
    @usage_helper = DIALOG_USAGE_HELPER
    @usage_component = DIALOG_USAGE_COMPONENT
    @composition = DIALOG_COMPOSITION
  end

  SHEET_EXAMPLES = %w[sheet_default sheet_sides].freeze

  SHEET_USAGE_HELPER = <<~ERB
    <%= ui_sheet do %>
      <%= ui_sheet_trigger(variant: :outline) { "Open" } %>
      <%= ui_sheet_content(side: :right) do %>
        <%= ui_sheet_header do %>
          <%= ui_sheet_title { "Title" } %>
          <%= ui_sheet_description { "The panel's description." } %>
        <% end %>
        <%= ui_sheet_footer do %>
          <%= ui_sheet_close { "Close" } %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  SHEET_USAGE_COMPONENT = <<~ERB
    <%= render Ui::SheetComponent.new do %>
      <%= render Ui::Sheet::TriggerComponent.new do %>
        Open
      <% end %>
      <%= render Ui::Sheet::ContentComponent.new(side: :left) do %>
        <%= render Ui::Sheet::TitleComponent.new do %>
          Title
        <% end %>
      <% end %>
    <% end %>
  ERB

  SHEET_COMPOSITION = <<~TEXT
    Sheet (ui-dialog)
    |-- Sheet::Trigger (Button)
    `-- Sheet::Content (<dialog> anchored to an edge, side:)
        |-- Sheet::Header > Sheet::Title + Sheet::Description
        `-- Sheet::Footer > Sheet::Close (Button)
  TEXT

  def alert_dialog
    @examples = examples_for(ALERT_DIALOG_EXAMPLES)
    @usage_helper = ALERT_DIALOG_USAGE_HELPER
    @usage_component = ALERT_DIALOG_USAGE_COMPONENT
    @composition = ALERT_DIALOG_COMPOSITION
  end

  def sheet
    @examples = examples_for(SHEET_EXAMPLES)
    @usage_helper = SHEET_USAGE_HELPER
    @usage_component = SHEET_USAGE_COMPONENT
    @composition = SHEET_COMPOSITION
  end

  TOOLTIP_EXAMPLES = %w[tooltip_default tooltip_sides].freeze

  TOOLTIP_USAGE_HELPER = <<~ERB
    <%= ui_tooltip do %>
      <%= ui_tooltip_trigger(variant: :outline) { "Passe o mouse" } %>
      <%= ui_tooltip_content { "Add to library" } %>
    <% end %>
  ERB

  TOOLTIP_USAGE_COMPONENT = <<~ERB
    <%= render Ui::TooltipComponent.new(open_delay: 150) do %>
      <%= render Ui::Tooltip::TriggerComponent.new do %>
        Help
      <% end %>
      <%= render Ui::Tooltip::ContentComponent.new(side: :right) do %>
        More details
      <% end %>
    <% end %>
  ERB

  TOOLTIP_COMPOSITION = <<~TEXT
    Tooltip (data-controller="ui-tooltip", relative)
    |-- Tooltip::Trigger (a Button described through aria-describedby)
    `-- Tooltip::Content (role="tooltip", absolute, side:)
  TEXT

  def tooltip
    @examples = examples_for(TOOLTIP_EXAMPLES)
    @usage_helper = TOOLTIP_USAGE_HELPER
    @usage_component = TOOLTIP_USAGE_COMPONENT
    @composition = TOOLTIP_COMPOSITION
  end

  POPOVER_EXAMPLES = %w[popover_default popover_align].freeze

  POPOVER_USAGE_HELPER = <<~ERB
    <%= ui_popover do %>
      <%= ui_popover_trigger(variant: :outline) { "Open" } %>
      <%= ui_popover_content do %>
        Popover content.
      <% end %>
    <% end %>
  ERB

  POPOVER_USAGE_COMPONENT = <<~ERB
    <%= render Ui::PopoverComponent.new do %>
      <%= render Ui::Popover::TriggerComponent.new do %>
        Open
      <% end %>
      <%= render Ui::Popover::ContentComponent.new(side: :bottom, align: :start) do %>
        Content
      <% end %>
    <% end %>
  ERB

  POPOVER_COMPOSITION = <<~TEXT
    Popover (data-controller="ui-popover", relative)
    |-- Popover::Trigger (Button, aria-expanded)
    `-- Popover::Content (absolute, side: + align:)
  TEXT

  def popover
    @examples = examples_for(POPOVER_EXAMPLES)
    @usage_helper = POPOVER_USAGE_HELPER
    @usage_component = POPOVER_USAGE_COMPONENT
    @composition = POPOVER_COMPOSITION
  end

  DROPDOWN_MENU_EXAMPLES = %w[dropdown_menu_default dropdown_menu_variants].freeze

  DROPDOWN_MENU_USAGE_HELPER = <<~ERB
    <%= ui_dropdown_menu do %>
      <%= ui_dropdown_menu_trigger(variant: :outline) { "Open" } %>
      <%= ui_dropdown_menu_content do %>
        <%= ui_dropdown_menu_label { "My account" } %>
        <%= ui_dropdown_menu_separator %>
        <%= ui_dropdown_menu_item do %>
          Profile
          <%= ui_dropdown_menu_shortcut { "⇧⌘P" } %>
        <% end %>
      <% end %>
    <% end %>
  ERB

  DROPDOWN_MENU_USAGE_COMPONENT = <<~ERB
    <%= render Ui::DropdownMenuComponent.new do %>
      <%= render Ui::DropdownMenu::TriggerComponent.new do %>
        Open
      <% end %>
      <%= render Ui::DropdownMenu::ContentComponent.new do %>
        <%= render Ui::DropdownMenu::ItemComponent.new(variant: :destructive) do %>
          Delete
        <% end %>
      <% end %>
    <% end %>
  ERB

  DROPDOWN_MENU_COMPOSITION = <<~TEXT
    DropdownMenu (data-controller="ui-dropdown-menu")
    |-- DropdownMenu::Trigger (Button, aria-haspopup="menu")
    `-- DropdownMenu::Content (role="menu")
        |-- DropdownMenu::Label
        |-- DropdownMenu::Separator
        |-- DropdownMenu::Group
        |   `-- DropdownMenu::Item (button/link) > DropdownMenu::Shortcut
        `-- DropdownMenu::Item (variant: :destructive)

    CheckboxItem, RadioItem and submenus are out of scope for this version.
  TEXT

  def dropdown_menu
    @examples = examples_for(DROPDOWN_MENU_EXAMPLES)
    @usage_helper = DROPDOWN_MENU_USAGE_HELPER
    @usage_component = DROPDOWN_MENU_USAGE_COMPONENT
    @composition = DROPDOWN_MENU_COMPOSITION
  end

  SELECT_EXAMPLES = %w[select_default select_groups select_form].freeze

  SELECT_USAGE_HELPER = <<~ERB
    <%= ui_select(name: "fruit", placeholder: "Select") do %>
      <%= ui_select_trigger { ui_select_value } %>
      <%= ui_select_content do %>
        <%= ui_select_item(value: "apple") { "Apple" } %>
        <%= ui_select_item(value: "banana") { "Banana" } %>
      <% end %>
    <% end %>
  ERB

  SELECT_USAGE_COMPONENT = <<~ERB
    <%= render Ui::SelectComponent.new(name: "fruit", value: "banana") do %>
      <%= render Ui::Select::TriggerComponent.new do %>
        <%= render Ui::Select::ValueComponent.new %>
      <% end %>
      <%= render Ui::Select::ContentComponent.new do %>
        <%= render Ui::Select::ItemComponent.new(value: "banana") do %>
          Banana
        <% end %>
      <% end %>
    <% end %>
  ERB

  SELECT_COMPOSITION = <<~TEXT
    Select (data-controller="ui-select", hidden input)
    |-- Select::Trigger (role="combobox") > Select::Value + chevron
    `-- Select::Content (role="listbox")
        `-- Select::Group > Select::Label + Select::Item (role="option")
            Select::Separator
  TEXT

  def select
    @examples = examples_for(SELECT_EXAMPLES)
    @usage_helper = SELECT_USAGE_HELPER
    @usage_component = SELECT_USAGE_COMPONENT
    @composition = SELECT_COMPOSITION
  end

  def input
    @examples = examples_for(INPUT_EXAMPLES)
    @usage_helper = INPUT_USAGE_HELPER
    @usage_component = INPUT_USAGE_COMPONENT
  end

  def label
    @examples = examples_for(LABEL_EXAMPLES)
    @usage_helper = LABEL_USAGE_HELPER
    @usage_component = LABEL_USAGE_COMPONENT
  end

  def textarea
    @examples = examples_for(TEXTAREA_EXAMPLES)
    @usage_helper = TEXTAREA_USAGE_HELPER
    @usage_component = TEXTAREA_USAGE_COMPONENT
  end

  def accordion
    @examples = examples_for(ACCORDION_EXAMPLES)
    @usage_helper = ACCORDION_USAGE_HELPER
    @usage_component = ACCORDION_USAGE_COMPONENT
    @composition = ACCORDION_COMPOSITION
  end

  def scroll_area
    @examples = examples_for(SCROLL_AREA_EXAMPLES)
    @usage_helper = SCROLL_AREA_USAGE_HELPER
    @usage_component = SCROLL_AREA_USAGE_COMPONENT
    @composition = SCROLL_AREA_COMPOSITION
    @usage_horizontal = SCROLL_AREA_USAGE_HORIZONTAL
    @rtl_usage = SCROLL_AREA_RTL
  end

  SIDEBAR_EXAMPLES = %w[sidebar_basic].freeze

  SIDEBAR_USAGE_HELPER = <<~ERB
    <%= ui_sidebar_provider do %>
      <%= ui_sidebar do %>
        <%= ui_sidebar_content do %>
          <%= ui_sidebar_group do %>
            <%= ui_sidebar_group_label { "Application" } %>
            <%= ui_sidebar_group_content do %>
              <%= ui_sidebar_menu do %>
                <%= ui_sidebar_menu_item do %>
                  <%= ui_sidebar_menu_button(tag: :a, href: "#", is_active: true) { "Home" } %>
                <% end %>
              <% end %>
            <% end %>
          <% end %>
        <% end %>
        <%= ui_sidebar_rail %>
      <% end %>
      <%= ui_sidebar_inset do %>
        <%= ui_sidebar_trigger %>
      <% end %>
    <% end %>
  ERB

  SIDEBAR_USAGE_COMPONENT = <<~ERB
    <%= render Ui::Sidebar::ProviderComponent.new do %>
      <%= render Ui::SidebarComponent.new(collapsible: :icon) do %>
        <%= render Ui::Sidebar::ContentComponent.new do %>
          <%= render Ui::Sidebar::MenuComponent.new do %>
            <%= render Ui::Sidebar::MenuItemComponent.new do %>
              <%= render Ui::Sidebar::MenuButtonComponent.new(tooltip: "Home") { "Home" } %>
            <% end %>
          <% end %>
        <% end %>
      <% end %>
      <%= render Ui::Sidebar::InsetComponent.new do %>
        <%= render Ui::Sidebar::TriggerComponent.new %>
      <% end %>
    <% end %>
  ERB

  SIDEBAR_COMPOSITION = <<~TEXT
    Sidebar::Provider (data-controller="ui-sidebar"; sets the widths as CSS vars)
    |-- Sidebar (peer/group; data-state/collapsible/side/variant/mobile)
    |   |-- Sidebar::Header  (e.g. a switcher + Sidebar::Input)
    |   |-- Sidebar::Content
    |   |   `-- Sidebar::Group > Sidebar::GroupLabel + Sidebar::GroupContent
    |   |       `-- Sidebar::Menu > Sidebar::MenuItem
    |   |           > Sidebar::MenuButton (+ MenuAction / MenuBadge / MenuSub)
    |   |-- Sidebar::Footer
    |   `-- Sidebar::Rail
    `-- Sidebar::Inset (Sidebar::Trigger opens/closes; Cmd/Ctrl+B toggles)
  TEXT

  def sidebar
    @examples = examples_for(SIDEBAR_EXAMPLES)
    @usage_helper = SIDEBAR_USAGE_HELPER
    @usage_component = SIDEBAR_USAGE_COMPONENT
    @composition = SIDEBAR_COMPOSITION
  end

  def aspect_ratio
    @page_title = "Aspect Ratio"
    @page_subtitle = t("components.pages.aspect_ratio.subtitle")
    @usage_helper = <<~ERB
      <%= ui_aspect_ratio(ratio: "16 / 9") do %>
        <%= image_tag "cover.jpg", class: "h-full w-full object-cover" %>
      <% end %>
    ERB
    @examples = examples_for(%w[aspect_ratio_default])
    render "doc_page"
  end

  def spinner
    @page_title = "Spinner"
    @page_subtitle = t("components.pages.spinner.subtitle")
    @usage_helper = <<~ERB
      <%= ui_spinner %>
      <%= ui_button(disabled: true) { ui_spinner(label: nil) + " Saving" } %>
    ERB
    @examples = examples_for(%w[spinner_default])
    render "doc_page"
  end

  def kbd
    @page_title = "Kbd"
    @page_subtitle = t("components.pages.kbd.subtitle")
    @usage_helper = <<~ERB
      <%= ui_kbd_group do %>
        <%= ui_kbd { "⌘" } %>
        <%= ui_kbd { "K" } %>
      <% end %>
    ERB
    @examples = examples_for(%w[kbd_default])
    render "doc_page"
  end

  def empty
    @page_title = "Empty"
    @page_subtitle = t("components.pages.empty.subtitle")
    @usage_helper = <<~ERB
      <%= ui_empty do %>
        <%= ui_empty_header do %>
          <%= ui_empty_media(variant: :icon) { ui_icon("inbox") } %>
          <%= ui_empty_title { "No messages" } %>
          <%= ui_empty_description { "New messages show up here." } %>
        <% end %>
        <%= ui_empty_content do %>
          <%= ui_button(size: :sm) { "Refresh" } %>
        <% end %>
      <% end %>
    ERB
    @examples = examples_for(%w[empty_default])
    render "doc_page"
  end

  def item
    @page_title = "Item"
    @page_subtitle = t("components.pages.item.subtitle")
    @usage_helper = <<~ERB
      <%= ui_item(variant: :outline) do %>
        <%= ui_item_media(variant: :icon) { ui_icon("file-text") } %>
        <%= ui_item_content do %>
          <%= ui_item_title { "Report.pdf" } %>
          <%= ui_item_description { "2.4 MB" } %>
        <% end %>
      <% end %>
    ERB
    @examples = examples_for(%w[item_default])
    render "doc_page"
  end

  def input_group
    @page_title = "Input Group"
    @page_subtitle = t("components.pages.input_group.subtitle")
    @usage_helper = <<~ERB
      <%= ui_input_group do %>
        <%= ui_input_group_addon { ui_icon("search") } %>
        <%= ui_input_group_input(placeholder: "Search...") %>
        <%= ui_input_group_addon(align: :inline_end) { ui_kbd { "⌘K" } } %>
      <% end %>
    ERB
    @examples = examples_for(%w[input_group_default])
    render "doc_page"
  end

  def button_group
    @page_title = "Button Group"
    @page_subtitle = t("components.pages.button_group.subtitle")
    @usage_helper = <<~ERB
      <%= ui_button_group do %>
        <%= ui_button(variant: :outline) { "Previous" } %>
        <%= ui_button(variant: :outline) { "Next" } %>
      <% end %>
    ERB
    @examples = examples_for(%w[button_group_default])
    render "doc_page"
  end

  def field
    @page_title = "Field"
    @page_subtitle = t("components.pages.field.subtitle")
    @usage_helper = <<~ERB
      <%= ui_field do %>
        <%= ui_field_label(for: "email") { "Email" } %>
        <%= ui_input(type: :email, id: "email") %>
        <%= ui_field_description { "We never share your email." } %>
      <% end %>
    ERB
    @examples = examples_for(%w[field_default])
    render "doc_page"
  end

  def native_select
    @page_title = "Native Select"
    @page_subtitle = t("components.pages.native_select.subtitle")
    @usage_helper = <<~ERB
      <%= ui_native_select(name: "fruit") do %>
        <option value="apple">Apple</option>
        <option value="banana">Banana</option>
      <% end %>
    ERB
    @examples = examples_for(%w[native_select_default])
    render "doc_page"
  end

  def collapsible
    @page_title = "Collapsible"
    @page_subtitle = t("components.pages.collapsible.subtitle")
    @usage_helper = <<~ERB
      <%= ui_collapsible do %>
        <%= ui_collapsible_trigger { "Show more" } %>
        <%= ui_collapsible_content { "Hidden content." } %>
      <% end %>
    ERB
    @examples = examples_for(%w[collapsible_default])
    render "doc_page"
  end

  def toggle
    @page_title = "Toggle"
    @page_subtitle = t("components.pages.toggle.subtitle")
    @usage_helper = <<~ERB
      <%= ui_toggle(variant: :outline, "aria-label": "Bold") { ui_icon("bold") } %>
    ERB
    @examples = examples_for(%w[toggle_default])
    render "doc_page"
  end

  def toggle_group
    @page_title = "Toggle Group"
    @page_subtitle = t("components.pages.toggle_group.subtitle")
    @usage_helper = <<~ERB
      <%= ui_toggle_group(type: :single) do %>
        <%= ui_toggle_group_item(value: "left") { ui_icon("align-left") } %>
        <%= ui_toggle_group_item(value: "center") { ui_icon("align-center") } %>
      <% end %>
    ERB
    @examples = examples_for(%w[toggle_group_default])
    render "doc_page"
  end

  def slider
    @page_title = "Slider"
    @page_subtitle = t("components.pages.slider.subtitle")
    @usage_helper = <<~ERB
      <%= ui_slider(min: 0, max: 100, value: 50, name: "volume", label: "Volume") %>
    ERB
    @examples = examples_for(%w[slider_default])
    render "doc_page"
  end

  def hover_card
    @page_title = "Hover Card"
    @page_subtitle = t("components.pages.hover_card.subtitle")
    @usage_helper = <<~ERB
      <%= ui_hover_card do %>
        <%= ui_hover_card_trigger(href: "#") { "@shadwire" } %>
        <%= ui_hover_card_content { "Profile details." } %>
      <% end %>
    ERB
    @examples = examples_for(%w[hover_card_default])
    render "doc_page"
  end

  def input_otp
    @page_title = "Input OTP"
    @page_subtitle = t("components.pages.input_otp.subtitle")
    @usage_helper = <<~ERB
      <%= ui_input_otp(name: "code") do %>
        <%= ui_input_otp_group do %>
          <%= ui_input_otp_slot %>
          <%= ui_input_otp_slot %>
        <% end %>
      <% end %>
    ERB
    @examples = examples_for(%w[input_otp_default])
    render "doc_page"
  end

  def drawer
    @page_title = "Drawer"
    @page_subtitle = t("components.pages.drawer.subtitle")
    @usage_helper = <<~ERB
      <%= ui_drawer do %>
        <%= ui_drawer_trigger { "Open" } %>
        <%= ui_drawer_content do %>
          <%= ui_drawer_header do %>
            <%= ui_drawer_title { "Title" } %>
          <% end %>
        <% end %>
      <% end %>
    ERB
    @examples = examples_for(%w[drawer_default])
    render "doc_page"
  end

  def context_menu
    @page_title = "Context Menu"
    @page_subtitle = t("components.pages.context_menu.subtitle")
    @usage_helper = <<~ERB
      <%= ui_context_menu do %>
        <%= ui_context_menu_trigger { "Right-click here" } %>
        <%= ui_context_menu_content do %>
          <%= ui_context_menu_item { "Voltar" } %>
        <% end %>
      <% end %>
    ERB
    @examples = examples_for(%w[context_menu_default])
    render "doc_page"
  end

  def menubar
    @page_title = "Menubar"
    @page_subtitle = t("components.pages.menubar.subtitle")
    @usage_helper = <<~ERB
      <%= ui_menubar do %>
        <%= ui_menubar_menu do %>
          <%= ui_menubar_trigger { "File" } %>
          <%= ui_menubar_content do %>
            <%= ui_menubar_item { "New" } %>
          <% end %>
        <% end %>
      <% end %>
    ERB
    @examples = examples_for(%w[menubar_default])
    render "doc_page"
  end

  def navigation_menu
    @page_title = "Navigation Menu"
    @page_subtitle = t("components.pages.navigation_menu.subtitle")
    @usage_helper = <<~ERB
      <%= ui_navigation_menu do %>
        <%= ui_navigation_menu_list do %>
          <%= ui_navigation_menu_item do %>
            <%= ui_navigation_menu_trigger { "Produtos" } %>
            <%= ui_navigation_menu_content do %>
              <%= ui_navigation_menu_link(href: "#") { "Item" } %>
            <% end %>
          <% end %>
        <% end %>
      <% end %>
    ERB
    @examples = examples_for(%w[navigation_menu_default])
    render "doc_page"
  end

  def command
    @page_title = "Command"
    @page_subtitle = t("components.pages.command.subtitle")
    @usage_helper = <<~ERB
      <%= ui_command do %>
        <%= ui_command_input(placeholder: "Search...") %>
        <%= ui_command_list do %>
          <%= ui_command_empty { "No results found." } %>
          <%= ui_command_group(heading: "Suggestions") do %>
            <%= ui_command_item(value: "profile") { "Profile" } %>
          <% end %>
        <% end %>
      <% end %>
    ERB
    @examples = examples_for(%w[command_default])
    render "doc_page"
  end

  def combobox
    @page_title = "Combobox"
    @page_subtitle = t("components.pages.combobox.subtitle")
    @usage_helper = <<~ERB
      <%= ui_popover do %>
        <%= ui_popover_trigger(variant: :outline) { "Select" } %>
        <%= ui_popover_content(class: "!p-0") do %>
          <%= ui_command do %>
            <%= ui_command_input(placeholder: "Search...") %>
            <%= ui_command_list do %>
              <%= ui_command_item(value: "rails") { "Rails" } %>
            <% end %>
          <% end %>
        <% end %>
      <% end %>
    ERB
    @examples = examples_for(%w[combobox_default])
    render "doc_page"
  end

  CALENDAR_EXAMPLES = %w[calendar_default calendar_range calendar_dropdown].freeze

  CALENDAR_USAGE_HELPER = <<~ERB
    <%= ui_calendar(selected: Date.current, name: "date", class: "border") %>

    <%# Range: two dates, two inputs, two months. %>
    <%= ui_calendar(
          mode: :range,
          selected: Date.current..(Date.current + 7),
          number_of_months: 2,
          name: "trip[starts_on]",
          end_name: "trip[ends_on]"
        ) %>
  ERB

  def calendar
    @examples = examples_for(CALENDAR_EXAMPLES)
    @usage_helper = CALENDAR_USAGE_HELPER
  end

  DATE_PICKER_EXAMPLES = %w[date_picker_default date_picker_field date_picker_range date_picker_dob date_picker_input date_picker_time date_picker_natural date_picker_rtl].freeze

  DATE_PICKER_USAGE_HELPER = <<~ERB
    <div data-controller="ui-date-picker" data-ui-date-picker-format-value="long">
      <%= ui_popover do %>
        <%= ui_popover_trigger(variant: :outline, class: "w-[212px] justify-between font-normal") do %>
          <span data-ui-date-picker-target="label" data-empty="true"
                class="data-[empty=true]:text-muted-foreground">Pick a date</span>
          <%= ui_icon("chevron-down", class: "opacity-50") %>
        <% end %>
        <%= ui_popover_content(align: :start, class: "w-auto! p-0!") do %>
          <%= ui_calendar(name: "due_on") %>
        <% end %>
      <% end %>
    </div>
  ERB

  DATE_PICKER_COMPOSITION = <<~TEXT
    data-controller="ui-date-picker"   the wiring: formats the label, parses what is typed, closes the popover
    `-- Popover
        |-- Popover::Trigger           the visible field: a Button or an InputGroup
        |   `-- [data-ui-date-picker-target="label" | "input"]
        `-- Popover::Content (w-auto! p-0!)
            `-- Calendar               name:/end_name: write the value into the form
  TEXT

  def date_picker
    @examples = examples_for(DATE_PICKER_EXAMPLES)
    @usage_helper = DATE_PICKER_USAGE_HELPER
    @composition = DATE_PICKER_COMPOSITION
  end

  def resizable
    @page_title = "Resizable"
    @page_subtitle = t("components.pages.resizable.subtitle")
    @usage_helper = <<~ERB
      <%= ui_resizable_panel_group(direction: :horizontal) do %>
        <%= ui_resizable_panel(default_size: 50) { "One" } %>
        <%= ui_resizable_handle %>
        <%= ui_resizable_panel(default_size: 50) { "Two" } %>
      <% end %>
    ERB
    @examples = examples_for(%w[resizable_default])
    render "doc_page"
  end

  def carousel
    @page_title = "Carousel"
    @page_subtitle = t("components.pages.carousel.subtitle")
    @usage_helper = <<~ERB
      <%= ui_carousel do %>
        <%= ui_carousel_content do %>
          <%= ui_carousel_item { "Slide 1" } %>
          <%= ui_carousel_item { "Slide 2" } %>
        <% end %>
        <%= ui_carousel_previous %>
        <%= ui_carousel_next %>
      <% end %>
    ERB
    @examples = examples_for(%w[carousel_default])
    render "doc_page"
  end

  def sonner
    @page_title = "Sonner"
    @page_subtitle = t("components.pages.sonner.subtitle")
    @usage_helper = <<~ERB
      <%# Put one toaster in the layout… %>
      <%= ui_sonner %>

      <%# …and fire it from anywhere. %>
      <%= ui_button(data: { action: "click->ui-sonner#toast",
            "ui-sonner-title-param": "Event created",
            "ui-sonner-description-param": "Sunday at 9:00 PM." }) { "Show toast" } %>
    ERB
    @examples = examples_for(%w[sonner_default])
    render "doc_page"
  end

  def chart
    @first_chart = examples_for(%w[chart_bar]).first
    @examples = examples_for(CHART_EXAMPLES)
    @snippets = CHART_SNIPPETS.merge(
      layer_controller: Rails.root.join("app/javascript/controllers/chart_goal_controller.js").read
    )
  end

  def data_table
    @page_title = "Data Table"
    @page_subtitle = t("components.pages.data_table.subtitle")
    @usage_helper = <<~ERB
      <%= ui_data_table(
            filter_key: :email,
            columns: [
              { key: :status, label: "Status" },
              { key: :email, label: "E-mail", sortable: true },
              { key: :amount, label: "Valor", sortable: true }
            ],
            rows: [
              { id: 1, status: "Success", email: "ada@example.com", amount: 316 }
            ]) %>
    ERB
    @examples = examples_for(%w[data_table_default])
    render "doc_page"
  end

  private

  # Example captions are prose, so they live in the locale files and are looked
  # up per request. The controller keeps only the order and the partial names,
  # which are the same in every language.
  def examples_for(names)
    names.map do |name|
      { name: name,
        title: t("components.examples.#{name}.title"),
        description: t("components.examples.#{name}.description") }
    end
  end
end
