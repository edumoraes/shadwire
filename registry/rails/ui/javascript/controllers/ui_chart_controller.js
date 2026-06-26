import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

// Instantiates a Chart.js chart from JSON data/options passed as values.
// Requires Chart.js in the importmap:
//   pin "chart.js/auto", to: "https://cdn.jsdelivr.net/npm/chart.js@4.4.6/auto/+esm"
// Datasets that don't set their own colors inherit the --chart-1..5 theme
// palette, resolved from the element's computed styles at connect time.
export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    type: { type: String, default: "bar" },
    data: Object,
    options: Object
  }

  connect() {
    const data = this.palettize(structuredClone(this.dataValue))
    const options = { responsive: true, maintainAspectRatio: false, ...this.optionsValue }
    this.chart = new Chart(this.canvasTarget, { type: this.typeValue, data, options })
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }

  palette() {
    const styles = getComputedStyle(this.element)
    return [1, 2, 3, 4, 5]
      .map((n) => styles.getPropertyValue(`--chart-${n}`).trim())
      .filter(Boolean)
  }

  palettize(data) {
    if (!data || !Array.isArray(data.datasets)) return data

    const colors = this.palette()
    if (colors.length === 0) return data

    const spread = ["pie", "doughnut", "polarArea"].includes(this.typeValue)
    data.datasets.forEach((dataset, index) => {
      if (spread) {
        if (dataset.backgroundColor == null) {
          dataset.backgroundColor = (data.labels || []).map((_, i) => colors[i % colors.length])
        }
      } else {
        const color = colors[index % colors.length]
        if (dataset.backgroundColor == null) dataset.backgroundColor = color
        if (dataset.borderColor == null) dataset.borderColor = color
      }
    })
    return data
  }
}
