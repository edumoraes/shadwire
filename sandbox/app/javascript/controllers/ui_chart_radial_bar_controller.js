import { Controller } from "@hotwired/stimulus"

// Bars bent into rings: a ring per row, swept from the chart's start angle as
// far as the value reaches on a scale every radial bar shares, over an optional
// muted track. Rings take the pointer events, like a pie's slices.
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

    const { ringScale, angleScale } = polar
    const arc = d3.arc().cornerRadius(options.cornerRadius ?? 0)
    const rings = chart.indices.flatMap((index) => {
      const value = series.values[index]
      if (!value) return []

      const name = series.nameKey != null ? rows[index][series.nameKey] : series.key
      return [ {
        index,
        name,
        row: rows[index],
        value: chart.value(rows[index], series.key),
        innerRadius: ringScale(index),
        outerRadius: ringScale(index) + ringScale.bandwidth(),
        startAngle: angleScale(value[0]),
        endAngle: angleScale(value[1])
      } ]
    })

    layer.attr("transform", `translate(${polar.cx},${polar.cy})`)
    layer.selectAll("path[data-chart-background]").data(options.background ? rings : [], (ring) => ring.index)
      .join((enter) => enter.insert("path", ":first-child"))
      .attr("data-chart-background", "")
      .attr("d", (ring) => arc({ ...ring, startAngle: polar.startAngle, endAngle: polar.endAngle }))

    const paths = layer.selectAll("path[data-chart-index]").data(rings, (ring) => ring.index)
      .join("path")
      .attr("data-chart-index", (ring) => ring.index)
      .attr("data-chart-key", (ring) => ring.name)
      .attr("pointer-events", "auto")
      .attr("fill", (ring) => (series.perDatum ? chart.datumColor(ring.row, ring.name, ring.index) : ring.row.fill || series.color))

    const transition = chart.transition(paths, !this.drawn)
    if (transition) {
      transition.attrTween("d", function (ring) {
        const start = this.ring ?? { ...ringOf(ring), endAngle: ring.startAngle }
        const interpolate = d3.interpolateObject(start, ringOf(ring))
        return (t) => arc((this.ring = interpolate(t)))
      })
    } else {
      paths.attr("d", arc).property("ring", ringOf)
    }
    this.drawn = true

    chart.renderChildren(this.element, {
      type: "radial-bar",
      shape: "arc",
      series,
      points: rings.map((ring) => ({ ...ring, cx: polar.cx, cy: polar.cy }))
    })
  }
}

function ringOf({ innerRadius, outerRadius, startAngle, endAngle }) {
  return { innerRadius, outerRadius, startAngle, endAngle }
}
