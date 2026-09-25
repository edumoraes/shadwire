import { Controller } from "@hotwired/stimulus"

// A series of bars, one per row, grown from the baseline — or from the bar
// below it in a stack. `radius` rounds the corners: one number for all four,
// or [top-left, top-right, bottom-right, bottom-left] as on screen.
export default class extends Controller {
  connect() {
    this.dispatch("connect", { prefix: "ui-chart" })
  }

  render({ detail: { chart, options } }) {
    const { d3, rows, vertical, categoryScale, valueScale } = chart
    const layer = chart.layer(this.element)
    const series = chart.seriesOf(this.element)
    if (!series || !(categoryScale.bandwidth?.() > 0)) {
      layer.selectAll("*").remove()
      return
    }

    const radius = options.radius ?? 0
    const bars = chart.indices.flatMap((index) => {
      const value = series.values[index]
      if (!value) return []

      const [ from, to ] = [ valueScale(value[0]), valueScale(value[1]) ]
      const along = categoryScale(index) + series.offset
      const box = vertical
        ? { x: Math.min(from, to), y: along, width: Math.abs(to - from), height: series.size }
        : { x: along, y: Math.min(from, to), width: series.size, height: Math.abs(to - from) }
      return [ { ...box, base: from, index, row: rows[index], value: chart.value(rows[index], series.key) } ]
    })

    const paths = layer.selectAll("path").data(bars, (bar) => bar.index)
      .join("path")
      .attr("data-chart-index", (bar) => bar.index)
      .attr("data-chart-key", series.key)
      .attr("fill", (bar) => bar.row.fill || series.color)

    const transition = chart.transition(paths, !this.drawn)
    if (transition) {
      transition.attrTween("d", function (bar) {
        const start = this.box ?? (vertical ? { ...boxOf(bar), x: bar.base, width: 0 } : { ...boxOf(bar), y: bar.base, height: 0 })
        const interpolate = d3.interpolateObject(start, boxOf(bar))
        return (t) => shape((this.box = interpolate(t)), radius)
      })
    } else {
      paths.attr("d", (bar) => shape(bar, radius)).property("box", (bar) => boxOf(bar))
    }
    this.drawn = true

    chart.renderChildren(this.element, { type: "bar", shape: "rect", series, points: bars })
  }
}

function boxOf({ x, y, width, height }) {
  return { x, y, width, height }
}

// A rectangle with each corner rounded on its own, drawn with every arc even
// at radius 0, so any two shapes interpolate into each other.
function shape({ x, y, width, height }, radius) {
  const radii = Array.isArray(radius) ? radius : [ radius, radius, radius, radius ]
  const most = Math.max(0, Math.min(width, height) / 2)
  const [ tl, tr, br, bl ] = [ 0, 1, 2, 3 ].map((corner) => Math.max(0, Math.min(Number(radii[corner]) || 0, most)))

  return `M${x + tl},${y}` +
    `H${x + width - tr}A${tr},${tr} 0 0 1 ${x + width},${y + tr}` +
    `V${y + height - br}A${br},${br} 0 0 1 ${x + width - br},${y + height}` +
    `H${x + bl}A${bl},${bl} 0 0 1 ${x},${y + height - bl}` +
    `V${y + tl}A${tl},${tl} 0 0 1 ${x + tl},${y}Z`
}
