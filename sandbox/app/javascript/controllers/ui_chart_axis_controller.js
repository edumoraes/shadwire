import { Controller } from "@hotwired/stimulus"

const TICK = 6

// An x or a y axis. The category axis — x, unless the layout is vertical —
// labels each category with the chart's category field, dropping the labels
// that would collide; the value axis labels the ticks the grid draws at. In
// `layout` it measures its labels and claims the room they need, unless
// `size` says how much.
export default class extends Controller {
  connect() {
    this.dispatch("connect", { prefix: "ui-chart" })
  }

  layout({ detail: { chart, options, reserve } }) {
    if (options.hide) return

    const room = options.size ?? this.measure(chart, options) + this.gap(options)
    reserve(this.horizontal ? "bottom" : "left", room)
  }

  render({ detail: { chart, options } }) {
    const { d3, plot } = chart
    const svg = d3.select(this.element)
    if (options.hide) {
      svg.selectAll("*").remove()
      return
    }

    const horizontal = this.horizontal
    const tickSize = options.tickLine ? TICK : 0
    const gap = this.gap(options)
    const labels = this.labels(chart, options)

    const ticks = svg.selectAll("g[data-tick]").data(labels, (label) => label.key)
      .join((enter) => enter.append("g").attr("data-tick", "").call((tick) => {
        tick.append("line")
        tick.append("text")
      }))
      .attr("display", null)
      .attr("transform", (label) => horizontal
        ? `translate(${label.position},${plot.bottom})`
        : `translate(${plot.left},${label.position})`)

    ticks.select("line")
      .attr("display", tickSize ? null : "none")
      .attr("x2", horizontal ? 0 : -tickSize)
      .attr("y2", horizontal ? tickSize : 0)

    ticks.select("text")
      .text((label) => label.text)
      .attr("x", horizontal ? 0 : -gap)
      .attr("y", horizontal ? gap : 0)
      .attr("dy", horizontal ? "0.71em" : "0.32em")
      .attr("text-anchor", horizontal ? "middle" : "end")

    if (this.categorical(chart)) this.thin(d3, ticks, horizontal, options.minTickGap ?? 5)

    svg.selectAll("line[data-axis-line]").data(options.axisLine ? [ null ] : []).join("line")
      .attr("data-axis-line", "")
      .attr("x1", plot.left)
      .attr("y1", horizontal ? plot.bottom : plot.top)
      .attr("x2", horizontal ? plot.right : plot.left)
      .attr("y2", plot.bottom)
  }

  get horizontal() {
    return this.element.dataset.chartPart !== "y-axis"
  }

  // x carries the categories, unless the chart runs vertical.
  categorical(chart) {
    return this.horizontal !== chart.vertical
  }

  gap(options) {
    return (options.tickLine ? TICK : 0) + (options.tickMargin ?? 8)
  }

  labels(chart, options) {
    const format = chart.format(options.tickFormat ?? (!this.categorical(chart) && chart.expanded ? ".0%" : null))

    if (this.categorical(chart)) {
      return chart.indices.map((index) => ({
        key: `category-${index}`,
        text: format(chart.categories[index]),
        position: chart.center?.(index)
      }))
    }
    return chart.valueTicks.map((tick) => ({
      key: `value-${tick}`,
      text: format(tick),
      position: chart.valueScale(tick)
    }))
  }

  // The widest label, or the tallest: what the axis needs across itself.
  measure(chart, options) {
    const texts = this.labels(chart, options).map((label) => label.text).filter(Boolean)
    if (!texts.length) return 0

    const probe = chart.d3.select(this.element).append("g").attr("visibility", "hidden")
    probe.selectAll("text").data(texts).join("text").text((text) => text)
    let size = 0
    probe.selectAll("text").each((_, index, nodes) => {
      const box = nodes[index].getBBox()
      size = Math.max(size, this.horizontal ? box.height : box.width)
    })
    probe.remove()
    return Math.ceil(size)
  }

  // Keeps a category label only when it clears the last one kept by `gap`.
  thin(d3, ticks, horizontal, gap) {
    let end = -Infinity
    ticks.each((label, index, nodes) => {
      const box = nodes[index].querySelector("text").getBBox()
      const half = (horizontal ? box.width : box.height) / 2
      const fits = label.position - half >= end + gap
      d3.select(nodes[index]).attr("display", fits ? null : "none")
      if (fits) end = label.position + half
    })
  }
}
