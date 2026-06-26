import { Controller } from "@hotwired/stimulus"

// A hover card: rich content that opens when the trigger is hovered or focused
// after `openDelay` and closes after `closeDelay`. The listeners live on the
// root so the pointer can travel onto the card without dismissing it.
export default class extends Controller {
  static targets = ["trigger", "content"]
  static values = {
    openDelay: { type: Number, default: 700 },
    closeDelay: { type: Number, default: 300 },
  }

  disconnect() {
    this.clearTimer()
  }

  scheduleOpen() {
    this.clearTimer()
    this.timer = setTimeout(() => this.open(), this.openDelayValue)
  }

  scheduleClose() {
    this.clearTimer()
    this.timer = setTimeout(() => this.close(), this.closeDelayValue)
  }

  open() {
    this.clearTimer()
    if (!this.hasContentTarget) return
    this.contentTarget.hidden = false
    this.contentTarget.dataset.state = "open"
  }

  close() {
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
}
