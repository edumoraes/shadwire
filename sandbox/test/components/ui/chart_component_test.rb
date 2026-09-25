# frozen_string_literal: true

require "test_helper"

class ChartComponentTest < ViewComponent::TestCase
  CONFIG = {
    desktop: { label: "Desktop", color: "var(--chart-1)" },
    mobile: { label: "Mobile", theme: { light: "#2563eb", dark: "#dc2626" } }
  }.freeze

  ROWS = [
    { month: Date.new(2024, 1), desktop: 186, mobile: 80 },
    { month: Date.new(2024, 2), desktop: 305, mobile: 200 }
  ].freeze

  class ComposedChartComponent < ViewComponent::Base
    include Ui::ChartHelper

    def call
      ui_chart(config: CONFIG, rows: ROWS, label: "Visitors per month") do
        safe_join([
          ui_chart_grid,
          ui_chart_x_axis(data_key: :month, tick_format: "%b"),
          ui_chart_tooltip,
          ui_chart_legend,
          ui_chart_bar(data_key: :desktop, radius: 4) { ui_chart_label_list(position: :top) },
          ui_chart_line(data_key: :mobile)
        ])
      end
    end
  end

  def chart_element
    page.find("figure[data-slot='chart']", visible: :all)
  end

  def json(attribute)
    JSON.parse(chart_element[attribute])
  end

  # Capybara parses as HTML4, which drops what a <template> holds.
  def templates
    Nokogiri::HTML5.fragment(rendered_content).css("template")
  end

  test "the container holds the rows, the labels and the layout for the ui-chart controller" do
    render_inline(Ui::ChartComponent.new(config: CONFIG, rows: ROWS, layout: :vertical, stack_offset: :expand))

    assert_selector "figure[data-slot='chart'][data-controller='ui-chart']"
    assert_equal [ "2024-01-01", 186, 80 ], json("data-ui-chart-rows-value").first.values_at("month", "desktop", "mobile")
    assert_equal({ "desktop" => { "label" => "Desktop" }, "mobile" => { "label" => "Mobile" } }, json("data-ui-chart-config-value"))
    assert_equal "vertical", chart_element["data-ui-chart-layout-value"]
    assert_equal "expand", chart_element["data-ui-chart-stack-offset-value"]
  end

  test "an unknown layout or stack offset falls back to the default" do
    render_inline(Ui::ChartComponent.new(layout: :sideways, stack_offset: :sideways))

    assert_equal "horizontal", chart_element["data-ui-chart-layout-value"]
    assert_equal "none", chart_element["data-ui-chart-stack-offset-value"]
  end

  # Rows go in as rows:, so data: is what it is everywhere else.
  test "data: stays the HTML data attributes, and the controller keeps its own" do
    render_inline(Ui::ChartComponent.new(rows: ROWS, data: { controller: "dashboard", turbo_permanent: true }))

    assert_equal "dashboard ui-chart", chart_element["data-controller"]
    assert_equal "true", chart_element["data-turbo-permanent"]
    assert_includes chart_element["data-action"], "pointermove->ui-chart#pointer"
  end

  test "each configured color becomes a custom property scoped to the chart" do
    render_inline(Ui::ChartComponent.new(config: CONFIG, id: "visits"))

    style = page.find("style", visible: :all).text(:all)
    assert_equal "chart-visits", chart_element["data-chart"]
    assert_includes style, "[data-chart=chart-visits] { --color-desktop: var(--chart-1); --color-mobile: #2563eb; }"
    assert_includes style, ".dark [data-chart=chart-visits] { --color-mobile: #dc2626; }"
  end

  test "a color that could end the rule is dropped, and keys are made safe" do
    config = { "a b" => { color: "red" }, evil: { color: "red; } body { display: none" } }
    render_inline(Ui::ChartComponent.new(config: config, id: "x"))

    style = page.find("style", visible: :all).text(:all)
    assert_includes style, "--color-a-b: red;"
    assert_not_includes style, "display"
  end

  test "a config without colors writes no stylesheet" do
    render_inline(Ui::ChartComponent.new(config: { visitors: { label: "Visitors" } }))

    assert_no_selector "style", visible: :all
  end

  test "configured icons are rendered once, as templates the legend and tooltip copy" do
    render_inline(Ui::ChartComponent.new(config: { desktop: { label: "Desktop", icon: "monitor" } }))

    assert_selector "template[data-ui-chart-target='icon'][data-chart-key='desktop']", visible: :all
  end

  test "the label names the chart" do
    render_inline(Ui::ChartComponent.new(label: "Visitors per month"))

    assert_selector "figure[aria-label='Visitors per month']"
  end

  test "the names and separators D3 formats with come from the app's translations" do
    render_inline(Ui::ChartComponent.new)
    assert_equal "Feb", json("data-ui-chart-locale-value")["shortMonths"][1]
    assert_equal ",", json("data-ui-chart-locale-value")["thousands"]

    I18n.with_locale(:pt) { render_inline(Ui::ChartComponent.new) }
    locale = json("data-ui-chart-locale-value")
    assert_equal "Fev", locale["shortMonths"][1]
    assert_equal "Janeiro", locale["months"][0]
    assert_equal [ ".", "," ], locale.values_at("thousands", "decimal")
    assert_equal [ "R$ ", "" ], locale["currency"]
  end

  test "every part is a layer the chart finds, with its options as JSON" do
    render_inline(Ui::Chart::BarComponent.new(data_key: :desktop, stack_id: :a, radius: [ 0, 0, 4, 4 ]))

    bar = page.find("svg[data-slot='chart-bar']", visible: :all)
    assert_equal "part", bar["data-ui-chart-target"]
    assert_equal "bar", bar["data-chart-part"]
    assert_equal "ui-chart-bar", bar["data-controller"]
    assert_equal "ui-chart:render->ui-chart-bar#render", bar["data-action"]
    assert_equal "true", bar["aria-hidden"]
    assert_equal({ "dataKey" => "desktop", "stackId" => "a", "radius" => [ 0, 0, 4, 4 ] }, JSON.parse(bar["data-chart-options"]))
  end

  test "the parts that follow the tooltip listen for highlight too" do
    render_inline(Ui::Chart::LineComponent.new(data_key: :mobile))

    line = page.find("svg[data-slot='chart-line']", visible: :all)
    assert_equal "ui-chart:render->ui-chart-line#render ui-chart:highlight->ui-chart-line#highlight", line["data-action"]
    assert_equal({ "dataKey" => "mobile", "curve" => "natural", "strokeWidth" => 2, "dot" => false, "connectNulls" => false },
                 JSON.parse(line["data-chart-options"]))
  end

  test "the axes claim their room in layout" do
    render_inline(Ui::Chart::YAxisComponent.new(data_key: :month, width: 40))

    axis = page.find("svg[data-slot='chart-y-axis']", visible: :all)
    assert_equal "y-axis", axis["data-chart-part"]
    assert_includes axis["data-action"], "ui-chart:layout->ui-chart-axis#layout"
    assert_equal 40, JSON.parse(axis["data-chart-options"])["size"]
  end

  test "a label list is drawn by its series, not found by the chart" do
    render_inline(ComposedChartComponent.new)

    label_list = page.find("svg[data-slot='chart-bar'] g[data-slot='chart-label-list']", visible: :all)
    assert_nil label_list["data-ui-chart-target"]
    assert_equal "ui-chart-label-list", label_list["data-controller"]
  end

  test "the helper composes a chart from its parts, in order" do
    render_inline(ComposedChartComponent.new)

    slots = page.all("figure[data-slot='chart'] > [data-chart-part]", visible: :all).map { |part| part["data-slot"] }
    assert_equal %w[chart-grid chart-x-axis chart-tooltip chart-legend chart-bar chart-line], slots
    assert_selector "figure[aria-label='Visitors per month']"
  end

  test "the tooltip's markup is the component's: an item template per indicator" do
    render_inline(Ui::Chart::TooltipComponent.new(indicator: :dashed))

    assert_selector "[data-slot='chart-tooltip'] [data-slot='chart-tooltip-content'][hidden]", visible: :all
    item = templates.find { |template| template["data-ui-chart-tooltip-target"] == "item" }
    assert item, "no item template"
    assert_includes item.at_css("[data-indicator]")[:class], "border-dashed"
    assert item.at_css("[data-name]") && item.at_css("[data-value]") && item.at_css("[data-nested-label]")
    assert_selector "[role='status'][aria-live='polite']", visible: :all
  end

  test "hide_indicator leaves the indicator out of the template" do
    render_inline(Ui::Chart::TooltipComponent.new(hide_indicator: true))

    assert templates.first.at_css("[data-value]")
    assert_nil templates.first.at_css("[data-indicator]")
  end

  test "the legend sits at the edge it is aligned to" do
    render_inline(Ui::Chart::LegendComponent.new(vertical_align: :top))

    legend = page.find("[data-slot='chart-legend']", visible: :all)
    assert_includes legend[:class], "top-0"
    assert_equal "ui-chart:layout->ui-chart-legend#layout", legend["data-action"]
    assert templates.first.at_css("[data-slot='chart-legend-item'] [data-swatch] + [data-label]")
  end

  test "a layer of your own is wired to the controller you name" do
    render_inline(Ui::Chart::LayerComponent.new(controller: "chart-goal", options: { value: 250 }))

    layer = page.find("svg[data-slot='chart-layer']", visible: :all)
    assert_equal "chart-goal", layer["data-controller"]
    assert_equal "ui-chart:render->chart-goal#render", layer["data-action"]
    assert_equal({ "value" => 250 }, JSON.parse(layer["data-chart-options"]))
  end

  test "a layer without a controller is still a part, and wires nothing" do
    render_inline(Ui::Chart::LayerComponent.new)

    layer = page.find("svg[data-slot='chart-layer']", visible: :all)
    assert_equal "part", layer["data-ui-chart-target"]
    assert_nil layer["data-controller"]
    assert_nil layer["data-action"]
  end
end
