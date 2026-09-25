import { Controller } from "@hotwired/stimulus"

// The chart. It draws nothing itself: it works out what every part shares —
// the size, the room the axes and the legend take, the scales, the stacks, the
// category the tooltip is on — and hands it to each part, which has its own
// controller and draws its own layer with D3. Three events, in this order:
//
//   ui-chart:layout     detail { chart, options, reserve(side, px) }: before
//                       the plot is sized, a part claims room at an edge
//   ui-chart:render     detail { chart, options }: the scales are ready, draw
//   ui-chart:highlight  detail { chart, active }: `active` is { index } or null
//
// A part is any element in the chart with data-ui-chart-target="part", its
// options as JSON in data-chart-options. Your own is one ui_chart_layer away:
// a Stimulus controller with a render(event) method, drawing into its <svg>
// with event.detail.chart.d3 and the scales beside it.
//
// D3 is imported on first connect, so a page without a chart never loads it.
// It needs the pin the registry adds to config/importmap.rb:
//   pin "d3", to: "https://cdn.jsdelivr.net/npm/d3@7.9.0/+esm"

let loadingD3
const loadD3 = () => (loadingD3 ||= import("d3"))

const DURATION = 600

// The series parts: what the value domain, the stacks, the tooltip and the
// legend are made of.
const MARKS = new Set([ "bar", "line", "area", "pie", "radial-bar", "radar" ])
const CARTESIAN = new Set([ "bar", "line", "area" ])
const STACKABLE = new Set([ "bar", "area", "radial-bar" ])

let charts = 0

export default class extends Controller {
  static targets = [ "part", "icon" ]
  static values = {
    rows: { type: Array, default: [] },
    config: { type: Object, default: {} },
    layout: { type: String, default: "horizontal" },
    stackOffset: { type: String, default: "none" },
    margin: { type: Object, default: {} },
    innerRadius: { type: String, default: "0" },
    outerRadius: { type: String, default: "80%" },
    startAngle: { type: Number, default: 0 },
    endAngle: { type: Number, default: 360 },
    locale: { type: Object, default: {} }
  }

  connect() {
    this.uid = `ui-chart-${++charts}`
    this.active = null
    this.pending = true
    this.resizeObserver = new ResizeObserver(() => this.refresh())
    this.resizeObserver.observe(this.element)

    loadD3().then(
      (d3) => {
        this.d3 = d3
        this.refresh()
      },
      (error) => console.error("ui-chart: D3 did not load. Is it pinned in config/importmap.rb?", error)
    )
  }

  disconnect() {
    this.resizeObserver?.disconnect()
    if (this.frame) cancelAnimationFrame(this.frame)
    this.frame = null
    this.chart = null
  }

  // Anything a drawing depends on changed: draw on the next frame, once.
  refresh() {
    if (this.frame) return

    this.frame = requestAnimationFrame(() => {
      this.frame = null
      this.render()
    })
  }

  // New rows or settings animate into place; a resize does not.
  rowsValueChanged() { this.changed() }
  configValueChanged() { this.changed() }
  layoutValueChanged() { this.changed() }
  stackOffsetValueChanged() { this.changed() }
  marginValueChanged() { this.changed() }
  innerRadiusValueChanged() { this.changed() }
  outerRadiusValueChanged() { this.changed() }
  startAngleValueChanged() { this.changed() }
  endAngleValueChanged() { this.changed() }

  changed() {
    this.pending = true
    this.refresh()
  }

  partTargetConnected() { this.refresh() }
  partTargetDisconnected() { this.refresh() }

  render() {
    const d3 = this.d3
    const width = this.element.clientWidth
    const height = this.element.clientHeight
    if (!d3 || !this.element.isConnected || width <= 0 || height <= 0) return

    const parts = this.partTargets.map((element) => ({ element, type: element.dataset.chartPart, options: optionsOf(element) }))
    const chart = this.build(d3, parts, width, height)
    this.chart = chart

    this.interactive = parts.some((part) => part.type === "tooltip")
    this.focusable(this.interactive)
    if (!this.opened) this.openAtDefault(parts, chart)

    parts.forEach((part) => this.send(part.element, "render", { chart, options: part.options }))
    this.pending = false
    this.highlight()
  }

  // Everything the parts are drawn from.
  build(d3, parts, width, height) {
    const rows = this.rowsValue.filter((row) => row && typeof row === "object")
    const config = this.configValue
    const vertical = this.layoutValue === "vertical"
    const find = (type) => parts.find((part) => part.type === type)
    const categoryAxis = find(vertical ? "y-axis" : "x-axis")
    const valueAxis = find(vertical ? "x-axis" : "y-axis")
    const categoryKey = categoryAxis?.options.dataKey ?? find("polar-angle-axis")?.options.dataKey ?? null
    const indices = d3.range(rows.length)
    const series = this.series(d3, parts, rows)
    const cartesian = series.filter((entry) => CARTESIAN.has(entry.type))
    const motion = !window.matchMedia?.("(prefers-reduced-motion: reduce)").matches
    const animate = this.pending

    const chart = {
      d3,
      element: this.element,
      id: this.uid,
      rows,
      config,
      vertical,
      width,
      height,
      indices,
      categoryKey,
      categories: indices.map((index) => (categoryKey == null ? index : rows[index][categoryKey])),
      series,
      expanded: this.stackOffsetValue === "expand" && cartesian.some((entry) => entry.stackId != null),
      active: this.active,

      value: (row, key) => numberOf(row?.[key]),
      label: (name) => labelOf(config, name),
      seriesOf: (element) => series.find((entry) => entry.element === element),
      format: formatter(d3, this.localeValue),

      // A slice's or a ring's own color: the row's fill, the config's color for
      // its name, or the palette.
      datumColor: (row, name, index) =>
        row?.fill || `var(--color-${cssKey(name)}, var(--chart-${(index % 5) + 1}))`,

      // The config's icon for a key, as a fresh <svg>, or null.
      icon: (key) => this.iconTargets.find((template) => template.dataset.chartKey === String(key))
        ?.content.firstElementChild?.cloneNode(true) ?? null,

      curve: (name) => curveOf(d3, name, vertical),

      // The <g> a part draws its marks into, below the label lists inside it.
      layer: (element) => d3.select(element).selectAll(":scope > g[data-chart-layer]").data([ null ])
        .join((enter) => enter.insert("g", ":first-child").attr("data-chart-layer", "")),

      // A transition when the drawing should animate — the first draw of a
      // part, or new rows — and null, having stopped any running one, when it
      // should not.
      transition: (selection, first = false) => {
        selection.interrupt()
        return motion && (animate || first) ? selection.transition().duration(DURATION).ease(d3.easeCubicOut) : null
      },

      // Draws the parts inside a series — its label lists — with its geometry.
      renderChildren: (element, parent) => {
        for (const child of element.children) {
          if (child.hasAttribute("data-chart-part")) this.send(child, "render", { chart, options: optionsOf(child), parent })
        }
      }
    }
    chart.items = (query) => itemsOf(chart, query)

    // Values: the extent of every cartesian series, from zero, made nice.
    let [ min, max ] = [ 0, 0 ]
    for (const entry of cartesian) {
      for (const value of entry.values) {
        if (!value) continue
        min = Math.min(min, value[0], value[1])
        max = Math.max(max, value[0], value[1])
      }
    }
    if (min === max) max = min + 1
    const tickCount = numberOf(valueAxis?.options.tickCount) ?? 5
    const given = Array.isArray(valueAxis?.options.domain) ? valueAxis.options.domain.map(numberOf) : []
    chart.valueScale = d3.scaleLinear().domain([ given[0] ?? min, given[1] ?? max ])
    if (given[0] == null || given[1] == null) chart.valueScale.nice(tickCount)
    const [ low, high ] = chart.valueScale.domain()
    chart.valueScale.domain([ given[0] ?? low, given[1] ?? high ])
    chart.valueTicks = chart.valueScale.ticks(tickCount)

    // Room: the margin, plus what the axes and the legend claim.
    const margin = { top: 5, right: 5, bottom: 5, left: 5 }
    for (const side of Object.keys(margin)) margin[side] = numberOf(this.marginValue[side]) ?? margin[side]
    const claimed = { top: 0, right: 0, bottom: 0, left: 0 }
    const reserve = (side, size) => {
      if (side in claimed) claimed[side] += Math.max(0, numberOf(size) ?? 0)
    }
    chart.margin = margin
    parts.forEach((part) => this.send(part.element, "layout", { chart, options: part.options, reserve }))

    const left = margin.left + claimed.left
    const top = margin.top + claimed.top
    const right = Math.max(left, width - margin.right - claimed.right)
    const bottom = Math.max(top, height - margin.bottom - claimed.bottom)
    chart.plot = { left, top, right, bottom, width: right - left, height: bottom - top }

    // Categories: bands when there are bars, points otherwise.
    const along = vertical ? [ top, bottom ] : [ left, right ]
    chart.categoryScale = cartesian.some((entry) => entry.type === "bar")
      ? d3.scaleBand().domain(indices).range(along).paddingInner(0.2).paddingOuter(0.1)
      : d3.scalePoint().domain(indices).range(along)
    chart.valueScale.range(vertical ? [ left, right ] : [ bottom, top ])
    chart.center = (index) => chart.categoryScale(index) + (chart.categoryScale.bandwidth?.() ?? 0) / 2
    chart.point = (index, value) => {
      const [ category, amount ] = [ chart.center(index), chart.valueScale(value) ]
      return vertical ? [ amount, category ] : [ category, amount ]
    }
    this.slotBars(cartesian, chart.categoryScale)

    chart.polar = this.polar(d3, chart, series)
    return chart
  }

  // One entry per series part, with its values as [from, to] per row: from the
  // baseline, from the series below in a stack, or [v, v] for a line.
  series(d3, parts, rows) {
    const series = parts
      .filter((part) => MARKS.has(part.type) && part.options.dataKey != null)
      .map((part, index) => ({
        element: part.element,
        type: part.type,
        options: part.options,
        key: String(part.options.dataKey),
        stackId: part.options.stackId ?? null,
        nameKey: part.options.nameKey ?? null,
        perDatum: part.type === "pie" || (part.type === "radial-bar" && part.options.nameKey != null),
        color: part.options.color || `var(--color-${cssKey(part.options.dataKey)}, var(--chart-${(index % 5) + 1}))`
      }))

    const offsets = {
      none: d3.stackOffsetNone,
      expand: d3.stackOffsetExpand,
      diverging: d3.stackOffsetDiverging,
      silhouette: d3.stackOffsetSilhouette,
      wiggle: d3.stackOffsetWiggle
    }
    const stacks = d3.group(
      series.filter((entry) => STACKABLE.has(entry.type) && entry.stackId != null),
      (entry) => `${entry.type}:${entry.stackId}`
    )
    for (const stack of stacks.values()) {
      const layers = d3.stack()
        .keys(stack.map((entry) => entry.key))
        .value((row, key) => numberOf(row[key]) ?? 0)
        .offset(offsets[this.stackOffsetValue] ?? d3.stackOffsetNone)(rows)
      layers.forEach((layer, position) => {
        stack[position].values = layer.map(([ from, to ]) => [ from, to ])
      })
    }

    for (const entry of series) {
      entry.label = labelOf(this.configValue, entry.key)
      entry.values ||= rows.map((row) => {
        const value = numberOf(row[entry.key])
        if (value == null) return null
        return entry.type === "line" ? [ value, value ] : [ 0, value ]
      })
    }
    return series
  }

  // Bars of one category stand side by side, a slot per series — or per stack.
  slotBars(cartesian, scale) {
    const bars = cartesian.filter((entry) => entry.type === "bar")
    const slots = []
    for (const entry of bars) {
      const slot = entry.stackId != null ? `stack:${entry.stackId}` : `series:${entry.key}`
      if (!slots.includes(slot)) slots.push(slot)
      entry.slot = slots.indexOf(slot)
    }

    const band = scale.bandwidth?.() ?? 0
    const gap = slots.length > 1 ? Math.min(4, band / slots.length / 4) : 0
    const size = slots.length ? (band - gap * (slots.length - 1)) / slots.length : band
    for (const entry of bars) {
      entry.offset = entry.slot * (size + gap)
      entry.size = size
    }
  }

  // What pies, radial bars and radars share: the center, the radii, a spoke
  // angle per category, and the scales every radar and every ring is read on.
  // Angles are D3's: radians, clockwise from twelve o'clock.
  polar(d3, chart, series) {
    const { plot, indices } = chart
    const room = Math.max(0, Math.min(plot.width, plot.height) / 2)
    const polar = {
      cx: plot.left + plot.width / 2,
      cy: plot.top + plot.height / 2,
      room,
      innerRadius: radiusOf(this.innerRadiusValue, room, 0),
      outerRadius: radiusOf(this.outerRadiusValue, room, room * 0.8),
      startAngle: radians(this.startAngleValue),
      endAngle: radians(this.endAngleValue),
      radius: (value, fallback) => radiusOf(value, room, fallback)
    }

    const span = polar.endAngle - polar.startAngle
    const closed = Math.abs(span) >= 2 * Math.PI - 1e-6
    const steps = closed ? indices.length : indices.length - 1
    polar.angle = (index) => polar.startAngle + (steps > 0 ? (span * index) / steps : 0)

    const peak = (type) => d3.max(series.filter((entry) => entry.type === type), (entry) => d3.max(entry.values, (value) => value?.[1]))
    polar.radiusScale = d3.scaleLinear().domain([ 0, peak("radar") > 0 ? peak("radar") : 1 ])
      .range([ polar.innerRadius, polar.outerRadius ])
    polar.angleScale = d3.scaleLinear().domain([ 0, peak("radial-bar") > 0 ? peak("radial-bar") : 1 ])
      .range([ polar.startAngle, polar.endAngle ])
    polar.ringScale = d3.scaleBand().domain(indices).range([ polar.innerRadius, polar.outerRadius ]).paddingInner(0.2)
    return polar
  }

  // The tooltip's category.

  pointer(event) {
    const chart = this.chart
    if (!chart || !this.interactive) return

    const [ x, y ] = chart.d3.pointer(event, this.element)
    const shape = event.target.closest?.("[data-chart-index]")
    const index = shape && this.element.contains(shape) ? Number(shape.dataset.chartIndex) : this.indexAt(chart, x, y)
    this.activate(index == null || Number.isNaN(index) ? null : { index, x, y, source: "pointer" })
  }

  leave() {
    if (this.active) this.activate(null)
  }

  blur(event) {
    if (this.active?.source === "keyboard" && !this.element.contains(event.relatedTarget)) this.activate(null)
  }

  keydown(event) {
    const chart = this.chart
    if (!chart || !this.interactive || event.target !== this.element) return

    const last = chart.rows.length - 1
    const current = this.active?.index
    let index
    switch (event.key) {
      case "ArrowRight":
      case "ArrowDown":
        index = current == null ? 0 : Math.min(last, current + 1)
        break
      case "ArrowLeft":
      case "ArrowUp":
        index = current == null ? last : Math.max(0, current - 1)
        break
      case "Home":
        index = 0
        break
      case "End":
        index = last
        break
      case "Escape":
        if (this.active) {
          event.preventDefault()
          this.activate(null)
        }
        return
      default:
        return
    }
    if (last < 0) return

    event.preventDefault()
    this.activate({ index, source: "keyboard" })
  }

  // The category under the pointer: the nearest one along a cartesian plot, or
  // the nearest spoke of a radar. Pies and rings are pointed at directly.
  indexAt(chart, x, y) {
    const { d3, plot, series, polar, indices } = chart
    if (!indices.length) return null

    if (series.some((entry) => CARTESIAN.has(entry.type))) {
      if (x < plot.left || x > plot.right || y < plot.top || y > plot.bottom) return null
      const along = chart.vertical ? y : x
      return d3.least(indices, (index) => Math.abs(chart.center(index) - along))
    }

    if (series.some((entry) => entry.type === "radar")) {
      if (Math.hypot(x - polar.cx, y - polar.cy) > polar.outerRadius + 16) return null
      const angle = Math.atan2(x - polar.cx, polar.cy - y)
      return d3.least(indices, (index) => angularDistance(angle, polar.angle(index)))
    }
    return null
  }

  activate(active) {
    this.active = active
    this.highlight()
  }

  highlight() {
    const chart = this.chart
    if (!chart) return

    chart.active = this.active
    this.partTargets.forEach((element) => this.send(element, "highlight", { chart, active: this.active }))
  }

  openAtDefault(parts, chart) {
    const index = numberOf(parts.find((part) => part.type === "tooltip")?.options.defaultIndex)
    if (index == null) return

    this.opened = true
    if (Number.isInteger(index) && index >= 0 && index < chart.rows.length) this.active = { index, source: "default" }
  }

  // With a tooltip, the chart takes focus and the arrow keys move it.
  focusable(interactive) {
    if (interactive && !this.element.hasAttribute("tabindex")) {
      this.element.setAttribute("tabindex", "0")
      this.tabindexAdded = true
    } else if (!interactive && this.tabindexAdded) {
      this.element.removeAttribute("tabindex")
      this.tabindexAdded = false
    }
  }

  send(element, name, detail) {
    element.dispatchEvent(new CustomEvent(`ui-chart:${name}`, { detail }))
  }
}

function optionsOf(element) {
  try {
    return JSON.parse(element.dataset.chartOptions || "{}")
  } catch {
    return {}
  }
}

// A number, or null for anything that is not one. JSON carries decimals as
// strings when they come from a BigDecimal.
function numberOf(value) {
  if (value == null || value === "" || typeof value === "boolean") return null
  const number = Number(value)
  return Number.isFinite(number) ? number : null
}

function cssKey(key) {
  return String(key).replace(/[^A-Za-z0-9_-]/g, "-")
}

function labelOf(config, name) {
  if (name == null) return ""
  return config[name]?.label ?? String(name)
}

function radians(degrees) {
  return ((numberOf(degrees) ?? 0) * Math.PI) / 180
}

// Pixels, or a percentage of the room there is.
function radiusOf(value, room, fallback) {
  if (value == null || value === "") return fallback
  const text = String(value).trim()
  const number = parseFloat(text)
  if (!Number.isFinite(number)) return fallback
  return text.endsWith("%") ? (room * number) / 100 : number
}

function angularDistance(a, b) {
  const turn = 2 * Math.PI
  return Math.abs((((a - b) % turn) + turn + Math.PI) % turn - Math.PI)
}

function curveOf(d3, name, vertical) {
  const curves = {
    natural: d3.curveNatural,
    linear: d3.curveLinear,
    monotone: vertical ? d3.curveMonotoneY : d3.curveMonotoneX,
    step: d3.curveStep,
    step_before: d3.curveStepBefore,
    step_after: d3.curveStepAfter,
    basis: d3.curveBasis,
    cardinal: d3.curveCardinal,
    catmull_rom: d3.curveCatmullRom
  }
  return curves[String(name ?? "natural").replace(/-/g, "_")] ?? d3.curveNatural
}

// What a tooltip lists at a category, or a legend lists at all: one entry per
// series — or per slice, for a pie, a named ring, or when `nameKey` names the
// rows.
function itemsOf(chart, { index = null, nameKey = null } = {}) {
  const { rows, series } = chart
  const items = []

  for (const entry of series) {
    const key = nameKey ?? entry.nameKey
    if (entry.perDatum || nameKey != null) {
      for (const at of index == null ? chart.indices : [ index ]) {
        const row = rows[at]
        if (!row) continue

        const name = key != null ? row[key] : at
        items.push({
          key: String(name),
          label: chart.label(name),
          value: chart.value(row, entry.key),
          color: entry.perDatum ? chart.datumColor(row, name, at) : row.fill || entry.color,
          series: entry,
          index: at
        })
      }
    } else {
      const row = index == null ? null : rows[index]
      if (index != null && !row) continue

      items.push({
        key: entry.key,
        label: entry.label,
        value: row ? chart.value(row, entry.key) : null,
        color: row?.fill || entry.color,
        series: entry,
        index
      })
    }
  }
  return items
}

// A formatter for a d3 specifier: a d3-format one for numbers, a
// d3-time-format one for dates (read as UTC, so a date without a time stays on
// its day), or none, for the page's own number format. Names and separators
// come from the app's translations.
function formatter(d3, locale) {
  const lang = locale.lang || document.documentElement.lang || undefined
  let numbers
  try {
    numbers = new Intl.NumberFormat(lang)
  } catch {
    numbers = new Intl.NumberFormat()
  }

  const numberLocale = d3.formatLocale({
    decimal: locale.decimal || ".",
    thousands: locale.thousands || ",",
    grouping: [ 3 ],
    currency: Array.isArray(locale.currency) && locale.currency.length === 2 ? locale.currency : [ "$", "" ]
  })

  const named = (list, size) => Array.isArray(list) && list.length === size
  const timeLocale = named(locale.months, 12) && named(locale.shortMonths, 12) && named(locale.days, 7) && named(locale.shortDays, 7)
    ? d3.timeFormatLocale({
      dateTime: "%x, %X",
      date: "%-m/%-d/%Y",
      time: "%-I:%M:%S %p",
      periods: [ "AM", "PM" ],
      days: locale.days,
      shortDays: locale.shortDays,
      months: locale.months,
      shortMonths: locale.shortMonths
    })
    : d3

  const cache = new Map()
  return (specifier) => {
    const spec = specifier ?? ""
    if (!cache.has(spec)) cache.set(spec, build(spec))
    return cache.get(spec)
  }

  function build(spec) {
    if (!spec) return (value) => (typeof value === "number" ? numbers.format(value) : value == null ? "" : String(value))

    if (/%[a-zA-Z]/.test(spec)) {
      const format = timeLocale.utcFormat(spec)
      return (value) => {
        const date = value instanceof Date ? value : value == null ? null : d3.isoParse(String(value))
        return date && !Number.isNaN(date.getTime()) ? format(date) : String(value ?? "")
      }
    }

    let format
    try {
      format = numberLocale.format(spec)
    } catch {
      format = null
    }
    return (value) => {
      const number = numberOf(value)
      return number == null || !format ? String(value ?? "") : format(number)
    }
  }
}
