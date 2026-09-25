import { Controller } from "@hotwired/stimulus"

// Labels on the points of the series it sits in. The series draws it, after
// itself, with its geometry in `event.detail.parent`: rectangles for bars,
// points for lines, areas and radars, arcs for slices and rings.
export default class extends Controller {
  connect() {
    this.dispatch("connect", { prefix: "ui-chart" })
  }

  render({ detail: { chart, options, parent } }) {
    if (!parent) return

    const format = chart.format(options.format)
    const offset = options.offset ?? 5
    const position = String(options.position ?? defaultPosition(parent, chart)).replace(/-/g, "_")
    // A value that names a config entry prints the entry's label.
    const text = (value) => (typeof value === "string" && chart.config[value] ? chart.label(value) : format(value))
    const labels = parent.points.map((point) => ({
      ...place(parent.shape, position, point, offset),
      index: point.index,
      text: text(options.dataKey != null ? point.row?.[options.dataKey] : point.value)
    }))

    const texts = chart.d3.select(this.element).selectAll("text").data(labels, (label) => label.index).join("text")
      .text((label) => label.text)
      .attr("x", (label) => label.x)
      .attr("y", (label) => label.y)
      .attr("text-anchor", (label) => label.anchor)
      .attr("dominant-baseline", (label) => label.baseline)
      .attr("transform", (label) => (label.rotate ? `rotate(${label.rotate},${label.x},${label.y})` : null))

    // Fades in while the series grows into place.
    const transition = chart.transition(texts, !this.drawn)
    if (transition) {
      texts.attr("opacity", 0)
      transition.attr("opacity", 1)
    } else {
      texts.attr("opacity", null)
    }
    this.drawn = true
  }
}

function defaultPosition(parent, chart) {
  if (parent.shape === "rect") return chart.vertical ? "right" : "top"
  if (parent.shape === "arc") return parent.type === "radial-bar" ? "inside_start" : "outside"
  return "top"
}

function place(shape, position, point, offset) {
  if (shape === "rect") return onRect(position, point, offset)
  if (shape === "arc") return onArc(position, point, offset)
  return onPoint(position, point, offset)
}

function onRect(position, { x, y, width, height }, offset) {
  const [ cx, cy ] = [ x + width / 2, y + height / 2 ]
  switch (position) {
    case "bottom": return { x: cx, y: y + height + offset, anchor: "middle", baseline: "hanging" }
    case "left": return { x: x - offset, y: cy, anchor: "end", baseline: "central" }
    case "right": return { x: x + width + offset, y: cy, anchor: "start", baseline: "central" }
    case "center":
    case "inside": return { x: cx, y: cy, anchor: "middle", baseline: "central" }
    case "inside_top": return { x: cx, y: y + offset, anchor: "middle", baseline: "hanging" }
    case "inside_bottom": return { x: cx, y: y + height - offset, anchor: "middle", baseline: "auto" }
    case "inside_left": return { x: x + offset, y: cy, anchor: "start", baseline: "central" }
    case "inside_right": return { x: x + width - offset, y: cy, anchor: "end", baseline: "central" }
    default: return { x: cx, y: y - offset, anchor: "middle", baseline: "auto" }
  }
}

function onPoint(position, { x, y }, offset) {
  switch (position) {
    case "bottom": return { x, y: y + offset, anchor: "middle", baseline: "hanging" }
    case "left": return { x: x - offset, y, anchor: "end", baseline: "central" }
    case "right": return { x: x + offset, y, anchor: "start", baseline: "central" }
    case "center":
    case "inside": return { x, y, anchor: "middle", baseline: "central" }
    default: return { x, y: y - offset, anchor: "middle", baseline: "auto" }
  }
}

// Angles are D3's: clockwise from twelve o'clock.
function onArc(position, { cx, cy, innerRadius, outerRadius, startAngle, endAngle }, offset) {
  const at = (radius, angle) => [ cx + radius * Math.sin(angle), cy - radius * Math.cos(angle) ]
  const middle = (startAngle + endAngle) / 2
  const band = (innerRadius + outerRadius) / 2

  switch (position) {
    case "center":
    case "inside": {
      const [ x, y ] = at(band, middle)
      return { x, y, anchor: "middle", baseline: "central" }
    }
    case "inside_start": {
      // Along the ring, just past where it starts, turned to follow it.
      const angle = startAngle + offset / Math.max(band, 1)
      const [ x, y ] = at(band, angle)
      return { x, y, anchor: "start", baseline: "central", rotate: (angle * 180) / Math.PI }
    }
    default: {
      const [ x, y ] = at(outerRadius + offset, middle)
      const sin = Math.sin(middle)
      return { x, y, anchor: sin > 0.1 ? "start" : sin < -0.1 ? "end" : "middle", baseline: "central" }
    }
  }
}
