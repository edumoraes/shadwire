import { Controller } from "@hotwired/stimulus"

// Glue for the date picker recipe: Popover + Calendar with a field around them.
// It keeps a trigger label, a text input and a preview line in sync with the
// calendar, parses what the user types back into a date, and dismisses the
// popover once the pick is complete. The calendar still owns the value — this
// controller never writes the form input itself.
//
// Wire it on the element wrapping both the popover and the field:
//
//   data-controller="ui-date-picker" data-ui-date-picker-format-value="long"
//   data-ui-date-picker-target="label"   → element showing the formatted date
//   data-ui-date-picker-target="input"   → text input the user can type into
//   data-ui-date-picker-target="preview" → optional echo of the parsed date
//
// `natural-language-value="true"` accepts phrases such as "amanhã", "em 2
// semanas" or "próxima sexta". The vocabulary is a plain table below — this is
// your code now, so extend it for the locales you ship.
export default class extends Controller {
  static targets = ["label", "input", "preview"]
  static values = {
    format: { type: String, default: "long" },
    locale: { type: String, default: "" },
    separator: { type: String, default: " – " },
    dateOrder: { type: String, default: "dmy" },
    closeOnSelect: { type: Boolean, default: true },
    naturalLanguage: { type: Boolean, default: false },
  }

  static DATE_STYLES = ["full", "long", "medium", "short"]
  static OFFSETS = {
    hoje: [0, "day"],
    today: [0, "day"],
    amanha: [1, "day"],
    tomorrow: [1, "day"],
    ontem: [-1, "day"],
    yesterday: [-1, "day"],
    "depois de amanha": [2, "day"],
    "proxima semana": [1, "week"],
    "semana que vem": [1, "week"],
    "next week": [1, "week"],
    "proximo mes": [1, "month"],
    "mes que vem": [1, "month"],
    "next month": [1, "month"],
    "proximo ano": [1, "year"],
    "ano que vem": [1, "year"],
    "next year": [1, "year"],
  }
  static UNITS = { dia: "day", semana: "week", mes: "month", ano: "year" }

  initialize() {
    this.onCalendarChange = this.onCalendarChange.bind(this)
    this.onCalendarConnect = this.onCalendarConnect.bind(this)
    this.onInput = this.onInput.bind(this)
    this.onKeydown = this.onKeydown.bind(this)
  }

  connect() {
    this.element.addEventListener("ui-calendar:change", this.onCalendarChange)
    this.element.addEventListener("ui-calendar:connect", this.onCalendarConnect)
    // Controllers connect in registration order, not DOM order, so the calendar
    // may already be up and its connect event long gone. Read it directly then.
    if (this.calendar) this.seed(this.calendar.detail)
  }

  disconnect() {
    this.element.removeEventListener("ui-calendar:change", this.onCalendarChange)
    this.element.removeEventListener("ui-calendar:connect", this.onCalendarConnect)
  }

  onCalendarConnect(event) {
    this.seed(event.detail)
  }

  // The calendar boots with whatever the server seeded it with; show that
  // straight away instead of leaving the placeholder up. A field the user has
  // already filled — a natural language phrase, say — is left alone.
  seed(detail) {
    const text = this.display(detail)
    if (!text) return

    this.setLabel(text)
    if (this.hasPreviewTarget) this.previewTarget.textContent = text
    if (this.hasInputTarget && !this.inputTarget.value) this.inputTarget.value = text
  }

  inputTargetConnected(input) {
    input.addEventListener("input", this.onInput)
    input.addEventListener("keydown", this.onKeydown)
  }

  inputTargetDisconnected(input) {
    input.removeEventListener("input", this.onInput)
    input.removeEventListener("keydown", this.onKeydown)
  }

  onCalendarChange(event) {
    const { from, to } = event.detail
    this.show(this.display(event.detail))
    // A range is only worth dismissing the popover for once both ends are in.
    if (this.closeOnSelectValue && !(from && !to)) this.popover?.close()
  }

  onInput() {
    const iso = this.parseText(this.inputTarget.value)
    if (iso) this.calendar?.goTo(iso)
    if (this.hasPreviewTarget) this.previewTarget.textContent = iso ? this.formatDate(iso) : ""
  }

  onKeydown(event) {
    if (event.key !== "ArrowDown") return

    event.preventDefault()
    this.popover?.open()
  }

  show(text) {
    this.setLabel(text)
    if (this.hasInputTarget) this.inputTarget.value = text
    if (this.hasPreviewTarget) this.previewTarget.textContent = text
  }

  setLabel(text) {
    if (!this.hasLabelTarget) return

    this.labelTarget.textContent = text
    this.labelTarget.dataset.empty = text ? "false" : "true"
  }

  display({ date, from, to }) {
    if (from && to) return `${this.formatDate(from)}${this.separatorValue}${this.formatDate(to)}`
    return this.formatDate(from || to || date)
  }

  formatDate(iso) {
    if (!iso) return ""
    if (this.formatValue === "iso") return iso

    return this.formatter.format(this.parseIso(iso))
  }

  get formatter() {
    const style = this.constructor.DATE_STYLES.includes(this.formatValue) ? this.formatValue : "long"
    this.intl ||= new Intl.DateTimeFormat(this.localeValue || undefined, { dateStyle: style })
    return this.intl
  }

  // Typed text → ISO date, or null when it means nothing yet. Order matters:
  // the unambiguous machine formats are tried before anything guessy.
  parseText(raw) {
    const text = this.normalize(raw)
    if (!text) return null

    const iso = text.match(/^(\d{4})-(\d{1,2})-(\d{1,2})$/)
    if (iso) return this.buildIso(Number(iso[1]), Number(iso[2]) - 1, Number(iso[3]))

    const numeric = text.match(/^(\d{1,2})[/.-](\d{1,2})[/.-](\d{2,4})$/)
    if (numeric) {
      const [first, second] = [Number(numeric[1]), Number(numeric[2])]
      const [day, month] = this.dateOrderValue === "mdy" ? [second, first] : [first, second]
      return this.buildIso(this.fullYear(Number(numeric[3])), month - 1, day)
    }

    if (this.naturalLanguageValue) {
      const relative = this.parseRelative(text)
      if (relative) return relative
    }

    return this.parseNamed(text)
  }

  parseRelative(text) {
    const offset = this.constructor.OFFSETS[text]
    if (offset) return this.shiftToday(...offset)

    const amount = text.match(/^(?:em|in|daqui a)\s+(\d+)\s+(dia|semana|mes|ano|day|week|month|year)s?$/)
    if (amount) return this.shiftToday(Number(amount[1]), this.constructor.UNITS[amount[2]] || amount[2])

    return this.parseWeekday(text)
  }

  parseWeekday(text) {
    const token = text.replace(/^(?:proximas?|proximos?|next|na|no)\s+/, "").replace(/-?feira$/, "").trim()
    if (token.length < 3) return null

    const index = this.dayLabels.findIndex((name) => {
      const label = this.normalize(name)
      return label.length >= 3 && (token.startsWith(label) || label.startsWith(token))
    })
    if (index < 0) return null

    const date = new Date()
    // Bare weekday names mean the next one, never today.
    date.setDate(date.getDate() + ((index - date.getDay() + 7) % 7 || 7))
    return this.iso(date)
  }

  // "1 de agosto de 2026", "agosto 1 2026", "1 ago" — a month name plus the
  // numbers around it. Without a year, the month's own year is assumed.
  parseNamed(text) {
    if (!/[a-z]/.test(text)) return null

    const month = this.monthLabels.findIndex((name) => {
      const label = this.normalize(name).slice(0, 3)
      return label.length === 3 && text.includes(label)
    })
    if (month < 0) return null

    const numbers = (text.match(/\d+/g) || []).map(Number)
    const day = numbers.find((value) => value <= 31) ?? 1
    const year = numbers.find((value) => value > 31) ?? (numbers.length > 1 ? numbers.at(-1) : new Date().getFullYear())
    return this.buildIso(this.fullYear(year), month, day)
  }

  shiftToday(amount, unit) {
    const date = new Date()
    if (unit === "week") date.setDate(date.getDate() + amount * 7)
    else if (unit === "month") date.setMonth(date.getMonth() + amount)
    else if (unit === "year") date.setFullYear(date.getFullYear() + amount)
    else date.setDate(date.getDate() + amount)
    return this.iso(date)
  }

  // Rejects the 31st of February instead of silently rolling into March.
  buildIso(year, month, day) {
    const date = new Date(year, month, day)
    if (date.getFullYear() !== year || date.getMonth() !== month || date.getDate() !== day) return null

    return this.iso(date)
  }

  fullYear(year) {
    return year < 100 ? 2000 + year : year
  }

  normalize(value) {
    return String(value || "")
      .trim()
      .toLowerCase()
      .normalize("NFD")
      .replace(/\p{Diacritic}/gu, "")
      .replace(/\s+/g, " ")
  }

  // Month and day names come from the calendar, so localizing it localizes the
  // parser too.
  get monthLabels() {
    return this.calendar?.monthLabels || []
  }

  get dayLabels() {
    return this.calendar?.dayLabels || []
  }

  get popover() {
    return this.controllerFor("ui-popover")
  }

  get calendar() {
    return this.controllerFor("ui-calendar")
  }

  controllerFor(identifier) {
    const element = this.element.querySelector(`[data-controller~='${identifier}']`)
    return element ? this.application.getControllerForElementAndIdentifier(element, identifier) : null
  }

  parseIso(value) {
    const [year, month, day] = value.split("-").map(Number)
    return new Date(year, month - 1, day)
  }

  iso(date) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, "0")
    const day = String(date.getDate()).padStart(2, "0")
    return `${year}-${month}-${day}`
  }
}
