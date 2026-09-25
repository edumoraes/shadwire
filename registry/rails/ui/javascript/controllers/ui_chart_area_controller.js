import { Controller } from "@hotwired/stimulus"

let gradients = 0

// The area between a line and its baseline — or the series below it, in a
// stack — rising from the baseline on first sight. Filled with the series
// color at `fillOpacity`, or with a fade of it when `gradient` is set.
export default class extends Controller {
  connect() {
    this.gradient = `ui-chart-area-gradient-${++gradients}`
    this.dispatch("connect", { prefix: "ui-chart" })
  }

  render({ detail: { chart, options } }) {
    const { d3, rows, vertical } = chart
    const layer = chart.layer(this.element)
    const series = chart.seriesOf(this.element)
    if (!series) {
      layer.selectAll("*").remove()
      return
    }

    const points = chart.indices.map((index) => {
      const value = series.values[index]
      if (!value) return null

      const [ x0, y0 ] = chart.point(index, value[0])
      const [ x1, y1 ] = chart.point(index, value[1])
      return { x0, y0, x1, y1, x: x1, y: y1, index, row: rows[index], value: chart.value(rows[index], series.key) }
    })
    const shown = options.connectNulls ? points.filter(Boolean) : points
    const curve = chart.curve(options.curve)
    const area = (vertical
      ? d3.area().y((point) => point.y1).x0((point) => point.x0).x1((point) => point.x1)
      : d3.area().x((point) => point.x1).y0((point) => point.y0).y1((point) => point.y1)).defined(Boolean).curve(curve)
    const line = d3.line().defined(Boolean).x((point) => point.x1).y((point) => point.y1).curve(curve)

    this.defineGradient(d3, series.color, options.gradient, vertical)
    const fill = layer.selectAll("path[data-area]").data([ null ]).join("path")
      .attr("data-area", "")
      .attr("fill", options.gradient ? `url(#${this.gradient})` : series.color)
      .attr("fill-opacity", options.fillOpacity ?? 0.4)
      .attr("stroke", "none")
    const edge = layer.selectAll("path[data-line]").data([ null ]).join("path")
      .attr("data-line", "")
      .attr("fill", "none")
      .attr("stroke", series.color)
      .attr("stroke-width", options.strokeWidth ?? 1)

    // First sight rises from the baseline; new rows reshape from the old ones.
    const start = this.shown ?? shown.map((point) => point && { ...point, x1: point.x0, y1: point.y0 })
    const transition = chart.transition(fill, !this.drawn)
    if (transition) {
      const interpolate = d3.interpolate(start, shown)
      transition.attrTween("d", () => (t) => area(interpolate(t)))
      chart.transition(edge, !this.drawn).attrTween("d", () => (t) => line(interpolate(t)))
    } else {
      fill.attr("d", area(shown))
      edge.attr("d", line(shown))
    }
    this.shown = shown

    const drawn = points.filter(Boolean)
    layer.selectAll("circle[data-dot]").data(options.dot ? drawn : [], (point) => point.index).join("circle")
      .attr("data-dot", "")
      .attr("r", 4)
      .attr("fill", series.color)
      .attr("cx", (point) => point.x)
      .attr("cy", (point) => point.y)

    this.drawn = true
    chart.renderChildren(this.element, { type: "area", shape: "point", series, points: drawn })
  }

  highlight({ detail: { chart, active } }) {
    const series = chart.seriesOf(this.element)
    const value = series && active ? series.values[active.index] : null
    const point = value ? chart.point(active.index, value[1]) : null

    chart.layer(this.element).selectAll("circle[data-active]").data(point ? [ point ] : []).join("circle")
      .attr("data-active", "")
      .attr("r", 4)
      .attr("fill", series?.color)
      .attr("stroke", "var(--background)")
      .attr("stroke-width", 2)
      .attr("cx", ([ x ]) => x)
      .attr("cy", ([ , y ]) => y)
  }

  // shadcn's fade: the color at 80% where the area is highest, 10% at its base.
  defineGradient(d3, color, enabled, vertical) {
    const defs = d3.select(this.element).selectAll(":scope > defs").data(enabled ? [ null ] : []).join("defs")
    const gradient = defs.selectAll("linearGradient").data(enabled ? [ null ] : []).join("linearGradient")
      .attr("id", this.gradient)
      .attr("x1", 0).attr("y1", 0)
      .attr("x2", vertical ? 1 : 0).attr("y2", vertical ? 0 : 1)
    gradient.selectAll("stop").data(vertical ? [ [ "5%", 0.1 ], [ "95%", 0.8 ] ] : [ [ "5%", 0.8 ], [ "95%", 0.1 ] ]).join("stop")
      .attr("offset", ([ offset ]) => offset)
      .attr("stop-color", color)
      .attr("stop-opacity", ([ , opacity ]) => opacity)
  }
}
