import { Controller } from "@hotwired/stimulus"

// A hover/focus tooltip. The content lives inside the controller element so
// the pointer can move onto it without dismissing (WCAG 1.4.13 hoverable);
// Escape dismisses without moving focus (WCAG 1.4.13 dismissible).
export default class extends Controller {
  static targets = ["trigger", "content"]
  static values = { openDelay: { type: Number, default: 300 } }

  connect() {
    this.wireAria()
  }

  disconnect() {
    this.clearTimer()
  }

  scheduleShow() {
    this.clearTimer()
    this.timer = setTimeout(() => this.show(), this.openDelayValue)
  }

  show() {
    this.clearTimer()
    if (!this.hasContentTarget) return

    this.contentTarget.hidden = false
    this.contentTarget.dataset.state = "open"
  }

  hide() {
    this.clearTimer()
    if (!this.hasContentTarget) return

    this.contentTarget.hidden = true
    delete this.contentTarget.dataset.state
  }

  clearTimer() {
    if (!this.timer) return

    clearTimeout(this.timer)
    this.timer = null
  }

  wireAria() {
    if (!this.hasTriggerTarget || !this.hasContentTarget) return

    if (!this.contentTarget.id) this.contentTarget.id = `${this.baseId()}-content`
    this.triggerTarget.setAttribute("aria-describedby", this.contentTarget.id)
  }

  baseId() {
    return this.element.id || "tooltip"
  }
}
