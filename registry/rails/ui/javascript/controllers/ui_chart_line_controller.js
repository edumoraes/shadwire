import { Controller } from "@hotwired/stimulus"

// A line through one value per row, drawn from the start on first sight and
// reshaped when the rows change. Marks each point with `dot`, and the point
// the tooltip is on with a larger one.
export default class extends Controller {
  connect() {
    this.dispatch("connect", { prefix: "ui-chart" })
  }

  render({ detail: { chart, options } }) {
    const { d3, rows } = chart
    const layer = chart.layer(this.element)
    const series = chart.seriesOf(this.element)
    if (!series) {
      layer.selectAll("*").remove()
      return
    }

    const points = chart.indices.map((index) => {
      const value = series.values[index]
      if (!value) return null

      const [ x, y ] = chart.point(index, value[1])
      return { x, y, index, row: rows[index], value: value[1] }
    })
    const drawn = points.filter(Boolean)
    const line = d3.line().defined(Boolean).x((point) => point.x).y((point) => point.y).curve(chart.curve(options.curve))
    const d = line(options.connectNulls ? drawn : points)

    const path = layer.selectAll("path[data-line]").data([ null ]).join("path")
      .attr("data-line", "")
      .attr("fill", "none")
      .attr("stroke", series.color)
      .attr("stroke-width", options.strokeWidth ?? 2)
      .attr("stroke-linecap", "round")
      .attr("stroke-linejoin", "round")

    const transition = chart.transition(path, !this.drawn)
    if (transition && !this.drawn) {
      // First sight: draw the line from its start.
      path.attr("d", d)
      const length = path.node().getTotalLength()
      path.attr("stroke-dasharray", `${length} ${length}`).attr("stroke-dashoffset", length)
      transition.attr("stroke-dashoffset", 0)
        .on("end interrupt", () => path.attr("stroke-dasharray", null).attr("stroke-dashoffset", null))
    } else if (transition) {
      transition.attr("d", d)
    } else {
      path.attr("d", d).attr("stroke-dasharray", null).attr("stroke-dashoffset", null)
    }

    layer.selectAll("circle[data-dot]").data(options.dot ? drawn : [], (point) => point.index).join("circle")
      .attr("data-dot", "")
      .attr("r", 4)
      .attr("fill", series.color)
      .attr("cx", (point) => point.x)
      .attr("cy", (point) => point.y)

    this.drawn = true
    chart.renderChildren(this.element, { type: "line", shape: "point", series, points: drawn })
  }

  // A dot on the point the tooltip is on.
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
}
