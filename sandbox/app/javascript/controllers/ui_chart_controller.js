import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

// Instantiates a Chart.js chart from JSON data/options passed as values.
// Requires Chart.js in the importmap:
//   pin "chart.js/auto", to: "https://cdn.jsdelivr.net/npm/chart.js@4.4.6/auto/+esm"
//
// Everything the chart paints comes from the theme: datasets that don't set
// their own colors take --chart-1..5, and the axes, grid, legend and tooltip —
// which Chart.js would otherwise draw in fixed greys — take --muted-foreground,
// --border and the popover pair. The canvas can't be reached by CSS, so a theme
// change repaints it here.
export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    type: { type: String, default: "bar" },
    data: Object,
    options: Object
  }

  connect() {
    this.themeObserver = new MutationObserver(() => this.repaint())
    this.themeObserver.observe(document.documentElement, { attributes: true, attributeFilter: [ "class" ] })

    this.applyThemeDefaults()
    const data = this.palettize(structuredClone(this.dataValue))
    const options = { responsive: true, maintainAspectRatio: false, ...this.optionsValue }
    this.chart = new Chart(this.canvasTarget, { type: this.typeValue, data, options })
  }

  disconnect() {
    if (this.themeObserver) {
      this.themeObserver.disconnect()
      this.themeObserver = null
    }
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }

  // The theme is a class on <html>, so nothing tells a canvas to redraw. Colors
  // are re-read from the pristine values, not from the mounted chart, so the
  // previous theme's palette isn't mistaken for a caller's explicit choice.
  repaint() {
    if (!this.chart) return

    this.applyThemeDefaults()
    this.chart.data = this.palettize(structuredClone(this.dataValue))
    this.chart.update()
  }

  // Chart.js draws its chrome from global defaults — `#666` text and black at
  // 10% for lines — which are invisible on a dark surface and unreachable from
  // CSS. Point them at the theme instead.
  applyThemeDefaults() {
    Chart.defaults.color = this.token("--muted-foreground")
    Chart.defaults.borderColor = this.token("--border")

    const tooltip = Chart.defaults.plugins.tooltip
    tooltip.backgroundColor = this.token("--popover")
    tooltip.titleColor = this.token("--popover-foreground")
    tooltip.bodyColor = this.token("--popover-foreground")
    tooltip.footerColor = this.token("--popover-foreground")
    tooltip.borderColor = this.token("--border")
    tooltip.borderWidth = 1
  }

  palette() {
    return [ 1, 2, 3, 4, 5 ].map((n) => this.token(`--chart-${n}`)).filter(Boolean)
  }

  palettize(data) {
    if (!data || !Array.isArray(data.datasets)) return data

    const colors = this.palette()
    if (colors.length === 0) return data

    const spread = [ "pie", "doughnut", "polarArea" ].includes(this.typeValue)
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

  token(name) {
    const value = getComputedStyle(this.element).getPropertyValue(name).trim()
    return value ? this.toRgb(value) : ""
  }

  // Chart.js parses colors with @kurkle/color, which reads hex, rgb and hsl but
  // not oklch — the format every token here uses. It returns undefined for what
  // it cannot parse, which is why derived colors (a hovered bar) came out
  // blank. Rather than port a color-space conversion, let the canvas do it:
  // paint one pixel and read it back as sRGB.
  toRgb(color) {
    this.probe ||= document.createElement("canvas").getContext("2d", { willReadFrequently: true })
    this.probe.clearRect(0, 0, 1, 1)
    this.probe.fillStyle = color
    this.probe.fillRect(0, 0, 1, 1)

    const [ r, g, b, a ] = this.probe.getImageData(0, 0, 1, 1).data
    return a === 255 ? `rgb(${r} ${g} ${b})` : `rgb(${r} ${g} ${b} / ${(a / 255).toFixed(3)})`
  }
}
