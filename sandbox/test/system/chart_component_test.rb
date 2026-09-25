# frozen_string_literal: true

require "application_system_test_case"

# The chart only exists once D3 has drawn it: the component renders empty
# layers and the ui-chart controllers fill them in, so this is the one place the
# drawing, the tooltip and the keyboard are exercised.
class ChartComponentTest < ApplicationSystemTestCase
  FIRST_CHART = "#example-chart_bar"

  # D3 is imported on connect, from the CDN the importmap pins; the first
  # assertion on a page gives it time to arrive.
  def assert_drawn(scope, selector, **options)
    using_wait_time(15) { assert_selector "#{scope} #{selector}", visible: :all, **options }
  end

  def status(scope)
    find("#{scope} [role='status']", visible: :all).text(:all)
  end

  test "D3 draws every part of a composed chart" do
    visit components_chart_path

    assert_drawn FIRST_CHART, "svg[data-slot='chart-bar'] path[data-chart-index]", count: 12
    assert_selector "#{FIRST_CHART} svg[data-slot='chart-grid'] line", minimum: 3, visible: :all
    assert_selector "#{FIRST_CHART} svg[data-slot='chart-x-axis'] text", text: "Jan"
    assert_selector "#{FIRST_CHART} svg[data-slot='chart-x-axis'] text", text: "Jun"
    assert_selector "#{FIRST_CHART} [data-slot='chart-legend-item']", text: "Desktop"
    assert_selector "#{FIRST_CHART} [data-slot='chart-legend-item']", text: "Mobile"
  end

  test "the tooltip lists each series at the category under the pointer" do
    visit components_chart_path
    assert_drawn FIRST_CHART, "svg[data-slot='chart-bar'] path[data-chart-index='1']", count: 2

    find("#{FIRST_CHART} svg[data-slot='chart-bar'] path[data-chart-index='1']", match: :first, visible: :all).hover

    assert_selector "#{FIRST_CHART} [data-slot='chart-tooltip-content']", text: "February"
    assert_selector "#{FIRST_CHART} [data-slot='chart-tooltip-item']", text: /Desktop\s*305/
    assert_selector "#{FIRST_CHART} [data-slot='chart-tooltip-item']", text: /Mobile\s*200/
    # The cursor shades the band behind the bars.
    assert_selector "#{FIRST_CHART} [data-ui-chart-tooltip-target='cursor'] rect", visible: :all
  end

  test "the arrow keys move the tooltip from category to category, and it is announced" do
    visit components_chart_path
    assert_drawn FIRST_CHART, "[data-slot='chart'][tabindex='0']"

    chart = find("#{FIRST_CHART} [data-slot='chart']")
    chart.execute_script("this.focus()")
    chart.send_keys :right, :right

    assert_selector "#{FIRST_CHART} [data-slot='chart-tooltip-content']", text: "February"
    assert_equal "February: Desktop 305, Mobile 200", status(FIRST_CHART)

    chart.send_keys :end
    assert_selector "#{FIRST_CHART} [data-slot='chart-tooltip-content']", text: "June"

    chart.send_keys :escape
    assert_no_selector "#{FIRST_CHART} [data-slot='chart-tooltip-content']"
  end

  test "a pie names the slice under the pointer" do
    visit components_chart_path
    assert_drawn "#example-chart_pie", "svg[data-slot='chart-pie'] path[data-chart-index]", count: 5

    find("#example-chart_pie svg[data-slot='chart-pie'] path[data-chart-index='0']", visible: :all).hover

    assert_selector "#example-chart_pie [data-slot='chart-tooltip-item']", text: /Chrome\s*275/
  end

  test "every kind of series draws" do
    visit components_chart_path

    assert_drawn "#example-chart_line", "svg[data-slot='chart-line'] path[data-line]", count: 2
    assert_drawn "#example-chart_area", "svg[data-slot='chart-area'] path[data-area]", count: 2
    assert_drawn "#example-chart_radar", "svg[data-slot='chart-radar'] path[data-radar]", count: 2
    assert_drawn "#example-chart_radar", "svg[data-slot='chart-polar-grid'] polygon", count: 5
    assert_drawn "#example-chart_radial", "svg[data-slot='chart-radial-bar'] path[data-chart-index]", count: 5
    assert_drawn "#example-chart_bar_horizontal", "g[data-slot='chart-label-list'] text", text: "February"
  end

  test "default_index opens the tooltip before anyone points" do
    visit components_chart_path

    assert_drawn "#example-chart_tooltip", "[data-slot='chart-tooltip-content']", text: "Tuesday", count: 3
  end

  test "a layer of your own draws from the chart's scales" do
    visit components_chart_path

    assert_drawn "#example-chart_layer", "svg[data-slot='chart-layer'] line[stroke-dasharray]"
    assert_selector "#example-chart_layer svg[data-slot='chart-layer'] text", text: "Goal", visible: :all
  end

  test "the Portuguese page writes dates and names in Portuguese" do
    visit "/pt/components/chart"

    assert_drawn FIRST_CHART, "svg[data-slot='chart-x-axis'] text", text: "Fev"
    assert_selector "#{FIRST_CHART} [data-slot='chart-legend-item']", text: "Computador"
    assert_selector "#example-chart_area svg[data-slot='chart-x-axis'] text", text: /Abr/, visible: :all
  end
end
