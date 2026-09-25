import { Controller } from "@hotwired/stimulus"

// shadcn's ChartLegendContent: a swatch — or the config's icon — and a label
// per series, per slice of a pie, or per row named by `nameKey`. It fills
// itself in during `layout`, before the plot is sized, so it can claim the
// height it turned out to need.
export default class extends Controller {
  static targets = [ "item" ]

  connect() {
    this.dispatch("connect", { prefix: "ui-chart" })
  }

  layout({ detail: { chart, options, reserve } }) {
    const seen = new Set()
    const items = chart.items({ nameKey: options.nameKey }).filter((item) => !seen.has(item.key) && seen.add(item.key))

    this.element.querySelectorAll(":scope > [data-slot='chart-legend-item']").forEach((entry) => entry.remove())
    this.element.append(...items.map((item) => {
      const entry = this.itemTarget.content.firstElementChild.cloneNode(true)
      const swatch = entry.querySelector("[data-swatch]")
      const icon = options.hideIcon ? null : chart.icon(item.key)

      if (icon) swatch.replaceWith(icon)
      else swatch.style.setProperty("--color-bg", item.color)
      entry.querySelector("[data-label]").textContent = item.label
      return entry
    }))

    reserve(options.verticalAlign === "top" ? "top" : "bottom", this.element.offsetHeight)
  }
}
