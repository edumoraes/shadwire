import { Controller } from "@hotwired/stimulus"

// A group of toggle buttons. `type` is "single" (radio-like, at most one on) or
// "multiple" (each independent). Implements roving tabindex with arrow-key
// navigation per the WAI-ARIA toolbar pattern.
export default class extends Controller {
  static targets = ["item"]
  static values = { type: { type: String, default: "single" } }

  connect() {
    this.refreshTabIndex()
  }

  select(event) {
    const item = event.currentTarget
    const pressed = item.dataset.state === "on"

    if (this.typeValue === "single") {
      this.itemTargets.forEach((candidate) => this.setPressed(candidate, candidate === item && !pressed))
    } else {
      this.setPressed(item, !pressed)
    }

    this.refreshTabIndex()
    this.dispatch("change", { detail: { value: this.value } })
  }

  keydown(event) {
    const items = this.enabledItems()
    const index = items.indexOf(event.currentTarget)
    if (index === -1) return

    let next = null
    switch (event.key) {
      case "ArrowRight":
      case "ArrowDown":
        next = items[(index + 1) % items.length]
        break
      case "ArrowLeft":
      case "ArrowUp":
        next = items[(index - 1 + items.length) % items.length]
        break
      case "Home":
        next = items[0]
        break
      case "End":
        next = items[items.length - 1]
        break
      default:
        return
    }

    event.preventDefault()
    next.focus()
    this.refreshTabIndex(next)
  }

  setPressed(item, pressed) {
    item.dataset.state = pressed ? "on" : "off"
    item.setAttribute("aria-pressed", pressed ? "true" : "false")
  }

  refreshTabIndex(active) {
    const items = this.itemTargets
    const focusable = active || items.find((item) => item.dataset.state === "on") || items[0]
    items.forEach((item) => {
      item.tabIndex = item === focusable ? 0 : -1
    })
  }

  enabledItems() {
    return this.itemTargets.filter((item) => !item.disabled)
  }

  get value() {
    const on = this.itemTargets.filter((item) => item.dataset.state === "on").map((item) => item.dataset.value)
    return this.typeValue === "single" ? on[0] ?? null : on
  }
}
