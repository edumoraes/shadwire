import { Controller } from "@hotwired/stimulus"

// A layer of the docs' own, not a registry part: a dashed line across the
// chart at `options.value`, labelled `options.label`, drawn with D3 on the
// chart's value scale. Any layer is this shape — announce yourself on connect,
// then draw on every `ui-chart:render`.
export default class extends Controller {
  connect() {
    this.dispatch("connect", { prefix: "ui-chart" })
  }

  render({ detail: { chart, options } }) {
    const { d3, plot, valueScale } = chart
    const y = valueScale(options.value)
    const svg = d3.select(this.element)

    svg.selectAll("line").data([ y ]).join("line")
      .attr("x1", plot.left)
      .attr("x2", plot.right)
      .attr("y1", (at) => at)
      .attr("y2", (at) => at)
      .attr("stroke-dasharray", "4 4")

    svg.selectAll("text").data([ options.label ]).join("text")
      .attr("x", plot.right)
      .attr("y", y - 6)
      .attr("stroke", "none")
      .attr("text-anchor", "end")
      .text((label) => label)
  }
}
