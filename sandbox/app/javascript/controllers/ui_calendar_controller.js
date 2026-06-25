import { Controller } from "@hotwired/stimulus"

// A single-month calendar. Builds the day grid client-side so month navigation
// needs no server round-trip; supports single-date selection, prev/next month,
// and arrow-key roving across days (WAI-ARIA grid pattern). The selected ISO
// date is mirrored into a hidden input.
export default class extends Controller {
  static targets = ["grid", "label", "input"]
  static values = {
    month: String,
    selected: String,
    min: String,
    max: String,
    weekStart: { type: Number, default: 0 },
  }

  static WEEKDAYS = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]
  static MONTHS = [
    "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
    "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro",
  ]

  connect() {
    const base = this.selectedValue || this.monthValue || this.today()
    const [y, m] = base.split("-").map(Number)
    this.view = new Date(y, m - 1, 1)
    this.selected = this.selectedValue || null
    this.render()
  }

  previous() {
    this.view = new Date(this.view.getFullYear(), this.view.getMonth() - 1, 1)
    this.render()
  }

  next() {
    this.view = new Date(this.view.getFullYear(), this.view.getMonth() + 1, 1)
    this.render()
  }

  selectDay(event) {
    const button = event.currentTarget
    if (button.disabled) return
    this.selected = button.dataset.date
    if (this.hasInputTarget) {
      this.inputTarget.value = this.selected
      this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
    }
    this.dispatch("change", { detail: { date: this.selected } })
    this.render()
  }

  keydown(event) {
    const button = event.target.closest("[data-date]")
    if (!button) return
    const deltas = { ArrowLeft: -1, ArrowRight: 1, ArrowUp: -7, ArrowDown: 7 }
    if (!(event.key in deltas)) return
    event.preventDefault()
    const date = new Date(button.dataset.date)
    date.setDate(date.getDate() + deltas[event.key])
    if (date.getMonth() !== this.view.getMonth() || date.getFullYear() !== this.view.getFullYear()) {
      this.view = new Date(date.getFullYear(), date.getMonth(), 1)
    }
    this.focusDate = this.iso(date)
    this.render()
  }

  render() {
    const year = this.view.getFullYear()
    const month = this.view.getMonth()
    const ctor = this.constructor
    if (this.hasLabelTarget) this.labelTarget.textContent = `${ctor.MONTHS[month]} ${year}`

    const first = new Date(year, month, 1)
    const lead = (first.getDay() - this.weekStartValue + 7) % 7
    const daysInMonth = new Date(year, month + 1, 0).getDate()

    const head = ctor.WEEKDAYS
      .map((_, i) => ctor.WEEKDAYS[(i + this.weekStartValue) % 7])
      .map((name) => `<div role="columnheader" class="text-muted-foreground size-9 text-center text-[0.8rem] font-normal">${name}</div>`)
      .join("")

    let cells = ""
    for (let i = 0; i < lead; i++) cells += `<div role="gridcell" aria-hidden="true" class="size-9"></div>`
    for (let day = 1; day <= daysInMonth; day++) {
      const iso = this.iso(new Date(year, month, day))
      const selected = iso === this.selected
      const disabled = this.isDisabled(iso)
      const isFocus = iso === (this.focusDate || this.selected || this.iso(this.firstFocusable(year, month)))
      cells +=
        `<div role="gridcell" class="p-0">` +
        `<button type="button" data-date="${iso}" data-action="click->ui-calendar#selectDay" ` +
        `tabindex="${isFocus ? 0 : -1}" ${disabled ? "disabled" : ""} ` +
        `aria-selected="${selected ? "true" : "false"}" data-selected="${selected ? "true" : "false"}" ` +
        `class="size-9 rounded-md text-sm font-normal transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:ring-2 focus-visible:ring-ring focus-visible:outline-none disabled:pointer-events-none disabled:opacity-40 aria-selected:bg-primary aria-selected:text-primary-foreground aria-selected:hover:bg-primary">` +
        `${day}</button></div>`
    }

    this.gridTarget.innerHTML =
      `<div role="row" class="grid grid-cols-7">${head}</div>` +
      `<div role="rowgroup" class="grid grid-cols-7 gap-y-1 mt-1">${cells}</div>`

    if (this.focusDate) {
      const target = this.gridTarget.querySelector(`[data-date='${this.focusDate}']`)
      if (target) target.focus()
    }
  }

  firstFocusable(year, month) {
    return new Date(year, month, 1)
  }

  isDisabled(iso) {
    if (this.minValue && iso < this.minValue) return true
    if (this.maxValue && iso > this.maxValue) return true
    return false
  }

  iso(date) {
    const y = date.getFullYear()
    const m = String(date.getMonth() + 1).padStart(2, "0")
    const d = String(date.getDate()).padStart(2, "0")
    return `${y}-${m}-${d}`
  }

  today() {
    return this.iso(new Date())
  }
}
