import { Controller } from "@hotwired/stimulus"

// A label at the end of each spoke of a radar, set clear of the outer radius
// and anchored away from the center.
export default class extends Controller {
  connect() {
    this.dispatch("connect", { prefix: "ui-chart" })
  }

  render({ detail: { chart, options } }) {
    const { d3, polar, indices } = chart
    const format = chart.format(options.tickFormat)
    const radius = polar.outerRadius + (options.tickMargin ?? 8)
    const labels = indices.map((index) => {
      const angle = polar.angle(index)
      const [ sin, cos ] = [ Math.sin(angle), Math.cos(angle) ]
      return {
        index,
        text: format(chart.categories[index]),
        x: polar.cx + radius * sin,
        y: polar.cy - radius * cos,
        anchor: sin > 0.1 ? "start" : sin < -0.1 ? "end" : "middle",
        baseline: cos > 0.1 ? "auto" : cos < -0.1 ? "hanging" : "central"
      }
    })

    d3.select(this.element).selectAll("text").data(labels, (label) => label.index).join("text")
      .text((label) => label.text)
      .attr("x", (label) => label.x)
      .attr("y", (label) => label.y)
      .attr("text-anchor", (label) => label.anchor)
      .attr("dominant-baseline", (label) => label.baseline)
  }
}
