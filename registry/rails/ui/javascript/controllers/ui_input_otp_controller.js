import { Controller } from "@hotwired/stimulus"

// A one-time-password input: a row of single-character slots that auto-advance,
// backspace to the previous slot, support pasting a full code, and mirror the
// combined value into a hidden input for form submission.
export default class extends Controller {
  static targets = ["slot", "value"]

  connect() {
    this.sync()
  }

  input(event) {
    const slot = event.currentTarget
    slot.value = slot.value.replace(/\s/g, "").slice(-1)
    if (slot.value) this.focusOffset(slot, 1)
    this.sync()
  }

  keydown(event) {
    const slot = event.currentTarget
    if (event.key === "Backspace" && !slot.value) {
      event.preventDefault()
      const prev = this.focusOffset(slot, -1)
      if (prev) {
        prev.value = ""
        this.sync()
      }
    } else if (event.key === "ArrowLeft") {
      event.preventDefault()
      this.focusOffset(slot, -1)
    } else if (event.key === "ArrowRight") {
      event.preventDefault()
      this.focusOffset(slot, 1)
    }
  }

  paste(event) {
    event.preventDefault()
    const text = (event.clipboardData || window.clipboardData).getData("text").replace(/\s/g, "")
    const slots = this.slotTargets
    const start = slots.indexOf(event.currentTarget)
    const offset = start === -1 ? 0 : start
    text.split("").forEach((char, index) => {
      const slot = slots[offset + index]
      if (slot) slot.value = char
    })
    const lastFilled = Math.min(offset + text.length, slots.length) - 1
    if (slots[lastFilled]) slots[lastFilled].focus()
    this.sync()
  }

  focusOffset(slot, delta) {
    const slots = this.slotTargets
    const index = slots.indexOf(slot)
    const next = slots[index + delta]
    if (next) {
      next.focus()
      next.select()
    }
    return next
  }

  sync() {
    const value = this.slotTargets.map((slot) => slot.value || "").join("")
    if (this.hasValueTarget) {
      this.valueTarget.value = value
      this.valueTarget.dispatchEvent(new Event("input", { bubbles: true }))
    }
    this.dispatch("change", { detail: { value } })
  }
}
