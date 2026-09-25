import { Controller } from "@hotwired/stimulus"

// Lines across the plot at the value axis' ticks and, when asked, one at each
// category: Recharts' CartesianGrid. `horizontal` and `vertical` are the lines'
// direction on screen; left unset, only the value lines are drawn, whichever
// way the layout runs them.
export default class extends Controller {
  connect() {
    this.dispatch("connect", { prefix: "ui-chart" })
  }

  render({ detail: { chart, options } }) {
    const { d3, plot, vertical, valueScale, valueTicks, indices } = chart
    const across = valueTicks.map((tick) => valueScale(tick))
    const along = indices.map((index) => chart.center(index))
    const rows = (options.horizontal ?? !vertical) ? (vertical ? along : across) : []
    const columns = (options.vertical ?? vertical) ? (vertical ? across : along) : []
    const svg = d3.select(this.element).attr("shape-rendering", "crispEdges")

    svg.selectAll("line[data-horizontal]").data(rows).join("line")
      .attr("data-horizontal", "")
      .attr("x1", plot.left).attr("x2", plot.right)
      .attr("y1", (y) => y).attr("y2", (y) => y)

    svg.selectAll("line[data-vertical]").data(columns).join("line")
      .attr("data-vertical", "")
      .attr("y1", plot.top).attr("y2", plot.bottom)
      .attr("x1", (x) => x).attr("x2", (x) => x)
  }
}
