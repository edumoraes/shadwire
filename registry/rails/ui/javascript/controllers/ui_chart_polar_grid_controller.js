import { Controller } from "@hotwired/stimulus"

const RINGS = 5

// The web behind a radar: rings at even steps out to the outer radius —
// polygons through the spokes, or circles — and a spoke per category.
export default class extends Controller {
  connect() {
    this.dispatch("connect", { prefix: "ui-chart" })
  }

  render({ detail: { chart, options } }) {
    const { d3, polar, indices } = chart
    const svg = d3.select(this.element)
    const radii = d3.range(1, RINGS + 1).map((step) => polar.innerRadius + ((polar.outerRadius - polar.innerRadius) * step) / RINGS)
    const spoke = (index, radius) => {
      const angle = polar.angle(index)
      return [ polar.cx + radius * Math.sin(angle), polar.cy - radius * Math.cos(angle) ]
    }
    const polygons = options.gridType !== "circle" && indices.length > 2

    svg.selectAll("polygon").data(polygons ? radii : []).join("polygon")
      .attr("points", (radius) => indices.map((index) => spoke(index, radius).join(",")).join(" "))

    svg.selectAll("circle").data(polygons ? [] : radii).join("circle")
      .attr("cx", polar.cx)
      .attr("cy", polar.cy)
      .attr("r", (radius) => radius)

    svg.selectAll("line").data(options.radialLines === false ? [] : indices).join("line")
      .attr("x1", (index) => spoke(index, polar.innerRadius)[0])
      .attr("y1", (index) => spoke(index, polar.innerRadius)[1])
      .attr("x2", (index) => spoke(index, polar.outerRadius)[0])
      .attr("y2", (index) => spoke(index, polar.outerRadius)[1])
  }
}
