import { Controller } from "@hotwired/stimulus"

// A single-thumb slider following the WAI-ARIA slider pattern. Pointer drag and
// arrow/Home/End keys move the thumb; the value is mirrored into a hidden input
// for form submission and broadcast via `ui-slider:change`.
export default class extends Controller {
  static targets = ["track", "range", "thumb", "input"]
  static values = {
    min: { type: Number, default: 0 },
    max: { type: Number, default: 100 },
    step: { type: Number, default: 1 },
    value: { type: Number, default: 0 },
  }

  connect() {
    this.render()
  }

  trackPointerDown(event) {
    event.preventDefault()
    this.setFromPointer(event)
    if (this.hasThumbTarget) this.thumbTarget.focus()
    this.startDragging()
  }

  thumbPointerDown(event) {
    event.preventDefault()
    if (this.hasThumbTarget) this.thumbTarget.focus()
    this.startDragging()
  }

  startDragging() {
    this.onMove = (event) => this.setFromPointer(event)
    this.onUp = () => {
      window.removeEventListener("pointermove", this.onMove)
      window.removeEventListener("pointerup", this.onUp)
    }
    window.addEventListener("pointermove", this.onMove)
    window.addEventListener("pointerup", this.onUp)
  }

  setFromPointer(event) {
    if (!this.hasTrackTarget) return
    const rect = this.trackTarget.getBoundingClientRect()
    const ratio = rect.width ? (event.clientX - rect.left) / rect.width : 0
    const raw = this.minValue + ratio * (this.maxValue - this.minValue)
    this.commit(raw)
  }

  keydown(event) {
    let next = this.valueValue
    switch (event.key) {
      case "ArrowRight":
      case "ArrowUp":
        next += this.stepValue
        break
      case "ArrowLeft":
      case "ArrowDown":
        next -= this.stepValue
        break
      case "Home":
        next = this.minValue
        break
      case "End":
        next = this.maxValue
        break
      default:
        return
    }
    event.preventDefault()
    this.commit(next)
  }

  commit(raw) {
    const clamped = Math.min(this.maxValue, Math.max(this.minValue, raw))
    const stepped = Math.round((clamped - this.minValue) / this.stepValue) * this.stepValue + this.minValue
    const value = Math.min(this.maxValue, Math.max(this.minValue, Number(stepped.toFixed(6))))
    if (value === this.valueValue) return
    this.valueValue = value
    this.render()
    this.dispatch("change", { detail: { value } })
  }

  render() {
    const ratio = this.maxValue === this.minValue ? 0 : (this.valueValue - this.minValue) / (this.maxValue - this.minValue)
    const percent = `${ratio * 100}%`
    if (this.hasRangeTarget) this.rangeTarget.style.width = percent
    if (this.hasThumbTarget) {
      this.thumbTarget.style.left = percent
      this.thumbTarget.setAttribute("aria-valuenow", String(this.valueValue))
    }
    if (this.hasInputTarget) this.inputTarget.value = String(this.valueValue)
  }
}
