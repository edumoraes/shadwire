import { Controller } from "@hotwired/stimulus"

// A calendar grid, built client-side so month navigation needs no server
// round-trip. Handles single dates and ranges, one or more months side by side,
// a text or dropdown caption, RTL, and arrow-key roving across days (WAI-ARIA
// grid pattern). The selection is mirrored into hidden inputs and announced as
// `ui-calendar:change` with `{ date, from, to }`.
export default class extends Controller {
  static targets = ["months", "input", "endInput"]
  static values = {
    month: String,
    selected: String,
    from: String,
    to: String,
    min: String,
    max: String,
    mode: { type: String, default: "single" },
    numberOfMonths: { type: Number, default: 1 },
    captionLayout: { type: String, default: "label" },
    firstYear: Number,
    lastYear: Number,
    weekStart: { type: Number, default: 0 },
    monthNames: { type: Array, default: [] },
    dayNames: { type: Array, default: [] },
  }

  static MONTH_NAMES = [
    "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
    "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro",
  ]
  static DAY_NAMES = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]
  // `appearance-none` is not cosmetic: a UA-painted select keeps the light
  // widget chrome inside a dark popover, so the control has to draw itself.
  static SELECT_CLASS =
    "h-7 appearance-none rounded-md border border-input bg-transparent pl-1.5 pr-5 " +
    "text-sm font-medium text-popover-foreground " +
    "focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none"
  // Lucide's chevron-down, inlined: the caption is built here, not in Ruby.
  static CHEVRON =
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" ` +
    `stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" ` +
    `class="pointer-events-none absolute top-1/2 right-1.5 size-3.5 -translate-y-1/2 opacity-50">` +
    `<path d="m6 9 6 6 6-6"></path></svg>`
  static DAY_CLASS =
    "size-9 rounded-md text-sm font-normal transition-colors " +
    "hover:bg-accent hover:text-accent-foreground " +
    "focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none " +
    "disabled:pointer-events-none disabled:opacity-40 " +
    "data-[today=true]:bg-accent data-[today=true]:text-accent-foreground " +
    "data-[range-middle=true]:rounded-none data-[range-middle=true]:bg-accent data-[range-middle=true]:text-accent-foreground " +
    "data-[range-start=true]:rounded-s-md data-[range-end=true]:rounded-e-md " +
    "data-[selected=true]:bg-primary data-[selected=true]:text-primary-foreground data-[selected=true]:hover:bg-primary"
  // A calendar is a fixed-size widget: fixed 2.25rem (size-9) columns keep its
  // natural width even inside a shrink-to-fit container (e.g. a w-auto popover).
  static COLUMNS = "grid-template-columns:repeat(7,2.25rem)"

  connect() {
    this.selected = this.selectedValue || null
    this.from = this.fromValue || null
    this.to = this.toValue || null
    this.previewDate = null
    this.focusDate = null
    this.view = this.startOfMonth(this.monthValue || this.selected || this.from)
    this.render()
    // Announced on connect so an outer controller (the date picker) can paint
    // the seeded selection without the server having to format it too.
    this.dispatch("connect", { detail: this.detail })
  }

  previous() {
    this.shift(-1)
  }

  next() {
    this.shift(1)
  }

  changeMonth(event) {
    this.view = new Date(this.view.getFullYear(), Number(event.target.value), 1)
    this.focusDate = null
    this.render()
  }

  changeYear(event) {
    this.view = new Date(Number(event.target.value), this.view.getMonth(), 1)
    this.focusDate = null
    this.render()
  }

  selectDay(event) {
    const button = event.currentTarget
    if (button.disabled) return

    const iso = button.dataset.date
    if (this.isRange) {
      if (!this.from || this.to) {
        this.from = iso
        this.to = null
      } else if (iso < this.from) {
        this.to = this.from
        this.from = iso
      } else {
        this.to = iso
      }
    } else {
      this.selected = iso
    }

    this.previewDate = null
    this.focusDate = iso
    this.writeInputs()
    this.dispatch("change", { detail: this.detail })
    this.paint()
  }

  keydown(event) {
    const button = event.target.closest("[data-date]")
    if (!button) return

    const date = this.parse(button.dataset.date)
    const steps = { ArrowLeft: this.rtl ? 1 : -1, ArrowRight: this.rtl ? -1 : 1, ArrowUp: -7, ArrowDown: 7 }
    if (event.key in steps) {
      date.setDate(date.getDate() + steps[event.key])
    } else if (event.key === "Home") {
      date.setDate(date.getDate() - this.weekdayOffset(date))
    } else if (event.key === "End") {
      date.setDate(date.getDate() + 6 - this.weekdayOffset(date))
    } else if (event.key === "PageUp") {
      date.setMonth(date.getMonth() - 1)
    } else if (event.key === "PageDown") {
      date.setMonth(date.getMonth() + 1)
    } else {
      return
    }

    event.preventDefault()
    this.focusDate = this.iso(date)
    if (!this.isVisible(date)) this.view = new Date(date.getFullYear(), date.getMonth(), 1)
    this.render()
  }

  // Hovering after the first click of a range paints the span it would create.
  preview(event) {
    if (!this.isRange || !this.from || this.to) return

    const iso = event.target.closest("[data-date]")?.dataset.date || null
    if (iso === this.previewDate) return

    this.previewDate = iso
    this.paint()
  }

  clearPreview() {
    if (!this.previewDate) return

    this.previewDate = null
    this.paint()
  }

  // Action form of `goTo`, for wiring another controller's event straight in:
  // `data-action="ui-date-picker:navigate->ui-calendar#setDate"`.
  setDate(event) {
    this.goTo(event?.detail?.date)
  }

  // Select `iso` and bring its month into view *without* announcing a change:
  // the caller (a date picker input, say) already knows — re-announcing it
  // would echo back and fight whatever the user is typing.
  goTo(iso) {
    if (!iso) return

    if (this.isRange) {
      this.from = iso
      this.to = null
    } else {
      this.selected = iso
    }
    this.view = this.startOfMonth(iso)
    this.focusDate = null
    this.writeInputs()
    this.render()
  }

  get detail() {
    return { date: this.isRange ? this.from : this.selected, from: this.from, to: this.to }
  }

  get isRange() {
    return this.modeValue === "range"
  }

  get monthCount() {
    return Math.max(1, this.numberOfMonthsValue)
  }

  get monthLabels() {
    return this.monthNamesValue.length ? this.monthNamesValue : this.constructor.MONTH_NAMES
  }

  get dayLabels() {
    return this.dayNamesValue.length ? this.dayNamesValue : this.constructor.DAY_NAMES
  }

  get rtl() {
    return getComputedStyle(this.element).direction === "rtl"
  }

  render() {
    const blocks = []
    for (let index = 0; index < this.monthCount; index++) {
      blocks.push(this.monthBlock(new Date(this.view.getFullYear(), this.view.getMonth() + index, 1)))
    }
    this.monthsTarget.innerHTML = blocks.join("")
    this.paint()

    if (this.focusDate) this.monthsTarget.querySelector(`[data-date='${this.focusDate}']`)?.focus()
  }

  monthBlock(view) {
    const year = view.getFullYear()
    const month = view.getMonth()
    const dropdown = this.captionLayoutValue === "dropdown" && this.monthCount === 1
    const caption = dropdown ? this.dropdownCaption(year, month) : this.labelCaption(year, month)
    const columns = this.constructor.COLUMNS

    const head = this.dayLabels
      .map((_, index) => this.dayLabels[(index + this.weekStartValue) % 7])
      .map((name) => `<div role="columnheader" class="text-muted-foreground size-9 text-center text-[0.8rem] font-normal">${name}</div>`)
      .join("")

    return (
      `<div class="w-fit">${caption}` +
      `<div role="grid" class="mt-2 text-sm">` +
      `<div role="row" class="grid" style="${columns}">${head}</div>` +
      `<div role="rowgroup" class="mt-1 grid gap-y-1" style="${columns}">${this.cells(year, month)}</div>` +
      `</div></div>`
    )
  }

  labelCaption(year, month) {
    return `<div class="flex h-7 items-center justify-center text-sm font-medium">${this.monthLabels[month]} ${year}</div>`
  }

  dropdownCaption(year, month) {
    const months = this.monthLabels
      .map((name, index) => `<option value="${index}"${index === month ? " selected" : ""}>${name}</option>`)
      .join("")

    const first = this.firstYearValue || new Date().getFullYear() - 100
    const last = this.lastYearValue || new Date().getFullYear() + 10
    let years = ""
    for (let value = last; value >= first; value--) {
      years += `<option value="${value}"${value === year ? " selected" : ""}>${value}</option>`
    }

    return (
      `<div class="flex h-7 items-center justify-center gap-1">` +
      this.dropdown("Mês", "changeMonth", months) +
      this.dropdown("Ano", "changeYear", years) +
      `</div>`
    )
  }

  dropdown(label, action, options) {
    return (
      `<span class="relative inline-flex items-center">` +
      `<select aria-label="${label}" class="${this.constructor.SELECT_CLASS}" ` +
      `data-action="change->ui-calendar#${action}">${options}</select>` +
      this.constructor.CHEVRON +
      `</span>`
    )
  }

  cells(year, month) {
    const lead = (new Date(year, month, 1).getDay() - this.weekStartValue + 7) % 7
    const daysInMonth = new Date(year, month + 1, 0).getDate()

    let cells = ""
    for (let index = 0; index < lead; index++) cells += `<div role="gridcell" aria-hidden="true" class="size-9"></div>`
    for (let day = 1; day <= daysInMonth; day++) {
      const date = new Date(year, month, day)
      const iso = this.iso(date)
      cells +=
        `<div role="gridcell" class="p-0">` +
        `<button type="button" data-date="${iso}" data-action="click->ui-calendar#selectDay" ` +
        `aria-label="${this.longDate.format(date)}" ${this.isDisabled(iso) ? "disabled" : ""} ` +
        `class="${this.constructor.DAY_CLASS}">${day}</button></div>`
    }
    return cells
  }

  // Selection state lives in attributes so a hover or a click only repaints the
  // cells — rebuilding the grid would drop focus mid-interaction.
  paint() {
    const [start, end] = this.bounds
    const pending = this.isRange && Boolean(start) && !this.to
    const focus = this.focusDate || this.selected || this.from
    const cells = this.monthsTarget.querySelectorAll("[data-date]")
    let focused = false

    cells.forEach((cell) => {
      const iso = cell.dataset.date
      const selected = this.isRange ? iso === this.from || iso === this.to : iso === this.selected
      const middle = Boolean(start && end && ((iso > start && iso < end) || (pending && iso === end && iso !== start)))

      cell.setAttribute("aria-selected", selected ? "true" : "false")
      cell.dataset.selected = selected ? "true" : "false"
      // Only one background wins per cell, so today defers to the selection
      // rather than relying on which variant Tailwind happens to emit last.
      cell.dataset.today = iso === this.today && !selected && !middle ? "true" : "false"
      // Rounding follows the committed picks; a hovered preview stays square so
      // it never fights `rounded-none` from the middle of the span.
      cell.dataset.rangeStart = this.isRange && iso === this.from && this.to ? "true" : "false"
      cell.dataset.rangeEnd = this.isRange && iso === this.to ? "true" : "false"
      cell.dataset.rangeMiddle = middle ? "true" : "false"
      if (iso === this.today) cell.setAttribute("aria-current", "date")

      const focusable = iso === focus
      cell.tabIndex = focusable ? 0 : -1
      focused ||= focusable
    })

    // Nothing selected in view — the grid still needs one tab stop to enter by.
    if (!focused) {
      const first = [...cells].find((cell) => !cell.disabled)
      if (first) first.tabIndex = 0
    }
  }

  // The span to paint: the committed range, or the one the pointer is proposing.
  get bounds() {
    let [start, end] = [this.from, this.to]
    if (start && !end && this.previewDate) {
      end = this.previewDate
      if (end < start) [start, end] = [end, start]
    }
    return [start, end]
  }

  writeInputs() {
    this.write(this.hasInputTarget ? this.inputTarget : null, this.isRange ? this.from : this.selected)
    if (this.isRange) this.write(this.hasEndInputTarget ? this.endInputTarget : null, this.to)
  }

  write(input, value) {
    if (!input) return

    input.value = value || ""
    input.dispatchEvent(new Event("change", { bubbles: true }))
  }

  shift(delta) {
    this.view = new Date(this.view.getFullYear(), this.view.getMonth() + delta, 1)
    this.focusDate = null
    this.render()
  }

  isVisible(date) {
    const months = date.getFullYear() * 12 + date.getMonth() - (this.view.getFullYear() * 12 + this.view.getMonth())
    return months >= 0 && months < this.monthCount
  }

  isDisabled(iso) {
    if (this.minValue && iso < this.minValue) return true
    if (this.maxValue && iso > this.maxValue) return true
    return false
  }

  weekdayOffset(date) {
    return (date.getDay() - this.weekStartValue + 7) % 7
  }

  get longDate() {
    this.formatter ||= new Intl.DateTimeFormat(this.element.closest("[lang]")?.lang || undefined, { dateStyle: "long" })
    return this.formatter
  }

  get today() {
    return this.iso(new Date())
  }

  // Local-time parsing: `new Date("2026-06-15")` is UTC midnight, which reads
  // back as the 14th anywhere west of Greenwich.
  parse(value) {
    const [year, month, day] = value.split("-").map(Number)
    return new Date(year, month - 1, day || 1)
  }

  startOfMonth(value) {
    const date = value ? this.parse(value) : new Date()
    return new Date(date.getFullYear(), date.getMonth(), 1)
  }

  iso(date) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, "0")
    const day = String(date.getDate()).padStart(2, "0")
    return `${year}-${month}-${day}`
  }
}
