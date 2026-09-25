import { Controller } from "@hotwired/stimulus"

// shadcn's ChartTooltipContent, for the category the chart is on: a label, and
// a row per series with its indicator, name and value. The markup is the
// component's; this fills in copies of its item template, places the box by
// the pointer — or by the category, from the keyboard — and shades what the
// pointer is on. What the keyboard reaches is also said in `status`.
export default class extends Controller {
  static targets = [ "cursor", "content", "label", "list", "item", "status" ]

  connect() {
    this.dispatch("connect", { prefix: "ui-chart" })
  }

  render({ detail: { chart, options } }) {
    this.chart = chart
    this.options = options
  }

  highlight({ detail: { chart, active } }) {
    this.chart = chart
    const items = active ? chart.items({ index: active.index, nameKey: this.options?.nameKey }).filter((item) => item.value != null) : []
    if (!items.length) {
      this.hide()
      return
    }

    this.fill(chart, active, items)
    this.place(chart, active)
    this.drawCursor(chart, active)
    if (active.source === "keyboard") this.statusTarget.textContent = this.summary(chart, active, items)
  }

  hide() {
    this.contentTarget.hidden = true
    this.statusTarget.textContent = ""
    this.chart?.d3.select(this.cursorTarget).selectAll("*").remove()
  }

  fill(chart, active, items) {
    const options = this.options ?? {}
    const format = chart.format(options.valueFormat)
    const label = this.labelFor(chart, active, items)
    const nested = items.length === 1 && options.indicator && options.indicator !== "dot"

    this.labelTarget.textContent = label ?? ""
    this.labelTarget.hidden = !label || nested
    this.listTarget.replaceChildren(...items.map((item) => {
      const row = this.itemTarget.content.firstElementChild.cloneNode(true)
      const indicator = row.querySelector("[data-indicator]")
      const icon = chart.icon(item.key)

      if (icon && indicator) {
        indicator.replaceWith(icon)
      } else if (icon) {
        row.prepend(icon)
      } else if (indicator) {
        indicator.style.setProperty("--color-bg", item.color)
        indicator.style.setProperty("--color-border", item.color)
      }
      row.querySelector("[data-name]").textContent = item.label
      row.querySelector("[data-value]").textContent = format(item.value)

      if (nested && label) {
        const nestedLabel = row.querySelector("[data-nested-label]")
        nestedLabel.textContent = label
        nestedLabel.hidden = false
        row.querySelectorAll("[data-body], [data-indicator]").forEach((element) => element.setAttribute("data-nested", ""))
      }
      return row
    }))
  }

  // The category, run through `labelFormat` and the config; or `labelKey`'s
  // config label; or, for a pie, the config label of its value.
  labelFor(chart, active, items) {
    const options = this.options ?? {}
    if (options.hideLabel) return null

    if (options.labelKey != null) {
      const key = options.labelKey
      return chart.config[key]?.label ?? chart.rows[active.index]?.[key] ?? String(key)
    }
    if (chart.categoryKey != null) {
      const category = chart.categories[active.index]
      return chart.config[category]?.label ?? chart.format(options.labelFormat)(category)
    }
    const slice = items.find((item) => item.series.perDatum)
    return slice ? chart.config[slice.series.key]?.label ?? null : null
  }

  // Beside the pointer, flipped to stay inside the chart; from the keyboard,
  // beside the category.
  place(chart, active) {
    const box = this.contentTarget
    box.hidden = false

    const [ x, y ] = active.x != null ? [ active.x, active.y ] : anchorOf(chart, active.index)
    const [ width, height ] = [ box.offsetWidth, box.offsetHeight ]
    let left = x + 10
    let top = y + 10
    if (left + width > chart.width) left = x - width - 10
    if (top + height > chart.height) top = y - height - 10
    left = Math.max(0, Math.min(left, chart.width - width))
    top = Math.max(0, Math.min(top, chart.height - height))
    box.style.transform = `translate(${Math.round(left)}px, ${Math.round(top)}px)`
  }

  // A band behind the bars of the category, or a line through its points.
  drawCursor(chart, active) {
    const { d3, plot, vertical, categoryScale, series } = chart
    const cartesian = series.some((entry) => [ "bar", "line", "area" ].includes(entry.type))
    const svg = d3.select(this.cursorTarget)
    // A point scale has a bandwidth too, of zero: only bands shade a band.
    const band = categoryScale.bandwidth?.() > 0 ? categoryScale.step() : 0
    const at = cartesian && this.options?.cursor !== false ? chart.center(active.index) : null

    svg.selectAll("rect").data(at != null && band ? [ at ] : []).join("rect")
      .attr("stroke", "none")
      .attr("x", (center) => (vertical ? plot.left : center - band / 2))
      .attr("y", (center) => (vertical ? center - band / 2 : plot.top))
      .attr("width", vertical ? plot.width : band)
      .attr("height", vertical ? band : plot.height)

    svg.selectAll("line").data(at != null && !band ? [ at ] : []).join("line")
      .attr("fill", "none")
      .attr("x1", (center) => (vertical ? plot.left : center))
      .attr("x2", (center) => (vertical ? plot.right : center))
      .attr("y1", (center) => (vertical ? center : plot.top))
      .attr("y2", (center) => (vertical ? center : plot.bottom))
  }

  summary(chart, active, items) {
    const format = chart.format(this.options?.valueFormat)
    const label = this.labelFor(chart, active, items)
    const values = items.map((item) => `${item.label} ${format(item.value)}`).join(", ")
    return label ? `${label}: ${values}` : values
  }
}

function anchorOf(chart, index) {
  const { plot, polar, series } = chart
  if (series.some((entry) => [ "bar", "line", "area" ].includes(entry.type))) {
    return chart.vertical ? [ plot.left, chart.center(index) ] : [ chart.center(index), plot.top ]
  }
  if (series.some((entry) => entry.type === "radar")) {
    const angle = polar.angle(index)
    return [ polar.cx + polar.outerRadius * Math.sin(angle), polar.cy - polar.outerRadius * Math.cos(angle) ]
  }
  return [ polar.cx, polar.cy ]
}
