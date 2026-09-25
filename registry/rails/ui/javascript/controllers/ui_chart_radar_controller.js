import { Controller } from "@hotwired/stimulus"

// A radar: a polygon with a corner on each category's spoke, as far out as
// the value reaches on the radius scale every radar shares. It opens out from
// the center on first sight.
export default class extends Controller {
  connect() {
    this.dispatch("connect", { prefix: "ui-chart" })
  }

  render({ detail: { chart, options } }) {
    const { d3, rows, polar } = chart
    const layer = chart.layer(this.element)
    const series = chart.seriesOf(this.element)
    if (!series) {
      layer.selectAll("*").remove()
      return
    }

    const corners = chart.indices.map((index) => {
      const value = series.values[index]?.[1] ?? 0
      const [ x, y ] = cornerOf(polar, index, value)
      return { x, y, index, row: rows[index], value }
    })
    const outline = d3.line().x((corner) => corner.x).y((corner) => corner.y).curve(d3.curveLinearClosed)

    const path = layer.selectAll("path[data-radar]").data([ null ]).join("path")
      .attr("data-radar", "")
      .attr("fill", series.color)
      .attr("fill-opacity", options.fillOpacity ?? 0.6)
      .attr("stroke", options.strokeWidth ? series.color : "none")
      .attr("stroke-width", options.strokeWidth ?? 0)

    const start = this.corners ?? corners.map((corner) => ({ ...corner, x: polar.cx, y: polar.cy }))
    const transition = chart.transition(path, !this.drawn)
    if (transition) {
      const interpolate = d3.interpolate(start, corners)
      transition.attrTween("d", () => (t) => outline(interpolate(t)))
    } else {
      path.attr("d", outline(corners))
    }
    this.corners = corners

    layer.selectAll("circle[data-dot]").data(options.dot ? corners : [], (corner) => corner.index).join("circle")
      .attr("data-dot", "")
      .attr("r", 4)
      .attr("fill", series.color)
      .attr("cx", (corner) => corner.x)
      .attr("cy", (corner) => corner.y)

    this.drawn = true
    chart.renderChildren(this.element, { type: "radar", shape: "point", series, points: corners })
  }

  highlight({ detail: { chart, active } }) {
    const series = chart.seriesOf(this.element)
    const value = series && active ? series.values[active.index]?.[1] : null
    const corner = value != null ? cornerOf(chart.polar, active.index, value) : null

    chart.layer(this.element).selectAll("circle[data-active]").data(corner ? [ corner ] : []).join("circle")
      .attr("data-active", "")
      .attr("r", 4)
      .attr("fill", series?.color)
      .attr("stroke", "var(--background)")
      .attr("stroke-width", 2)
      .attr("cx", ([ x ]) => x)
      .attr("cy", ([ , y ]) => y)
  }
}

function cornerOf(polar, index, value) {
  const angle = polar.angle(index)
  const radius = polar.radiusScale(value)
  return [ polar.cx + radius * Math.sin(angle), polar.cy - radius * Math.cos(angle) ]
}
