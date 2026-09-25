import { Controller } from "@hotwired/stimulus"

// A pie, or a donut with an inner radius: one slice per row, swept in from
// the start angle on first sight. Slices are what the tooltip points at, so
// they take the pointer events the rest of the chart lets through.
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

    const innerRadius = polar.radius(options.innerRadius, polar.innerRadius)
    const outerRadius = polar.radius(options.outerRadius, polar.outerRadius)
    const arc = d3.arc().innerRadius(innerRadius).outerRadius(outerRadius).cornerRadius(options.cornerRadius ?? 0)
    const slices = d3.pie()
      .sort(null)
      .value((row) => Math.max(0, chart.value(row, series.key) ?? 0))
      .startAngle(polar.startAngle)
      .endAngle(polar.endAngle)
      .padAngle(((options.paddingAngle ?? 0) * Math.PI) / 180)(rows)
    const name = (slice) => (series.nameKey != null ? slice.data[series.nameKey] : slice.index)

    layer.attr("transform", `translate(${polar.cx},${polar.cy})`)
    const paths = layer.selectAll("path").data(slices, (slice) => slice.index)
      .join("path")
      .attr("data-chart-index", (slice) => slice.index)
      .attr("data-chart-key", (slice) => name(slice))
      .attr("pointer-events", "auto")
      .attr("fill", (slice) => chart.datumColor(slice.data, name(slice), slice.index))
      .attr("stroke-width", options.strokeWidth ?? 0)

    const transition = chart.transition(paths, !this.drawn)
    if (transition) {
      transition.attrTween("d", function (slice) {
        const start = this.angles ?? { startAngle: slice.startAngle, endAngle: slice.startAngle, padAngle: slice.padAngle }
        const interpolate = d3.interpolateObject(start, anglesOf(slice))
        return (t) => arc((this.angles = interpolate(t)))
      })
    } else {
      paths.attr("d", arc).property("angles", anglesOf)
    }
    this.drawn = true

    chart.renderChildren(this.element, {
      type: "pie",
      shape: "arc",
      series,
      points: slices.map((slice) => ({
        ...anglesOf(slice),
        cx: polar.cx,
        cy: polar.cy,
        innerRadius,
        outerRadius,
        index: slice.index,
        row: slice.data,
        value: slice.value
      }))
    })
  }
}

function anglesOf({ startAngle, endAngle, padAngle }) {
  return { startAngle, endAngle, padAngle }
}
