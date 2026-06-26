import { Controller } from "@hotwired/stimulus"

// Resizable panels. Each handle resizes the two panels it sits between by
// transferring flex-grow proportional to the drag distance; Arrow keys on a
// focused handle nudge the split. `direction` is horizontal or vertical.
export default class extends Controller {
  static targets = ["panel", "handle"]
  static values = { direction: { type: String, default: "horizontal" } }

  connect() {
    this.panelTargets.forEach((panel) => {
      const size = parseFloat(panel.dataset.defaultSize || "") || 100 / this.panelTargets.length
      panel.style.flexGrow = String(size)
      panel.style.flexBasis = "0"
    })
  }

  start(event) {
    event.preventDefault()
    const handle = event.currentTarget
    const index = this.handleTargets.indexOf(handle)
    this.before = this.panelTargets[index]
    this.after = this.panelTargets[index + 1]
    if (!this.before || !this.after) return

    this.startPos = this.pointerPos(event)
    this.startBefore = parseFloat(this.before.style.flexGrow) || 1
    this.startAfter = parseFloat(this.after.style.flexGrow) || 1
    this.total = this.horizontal ? this.element.clientWidth : this.element.clientHeight

    this.onMove = (e) => this.move(e)
    this.onUp = () => this.stop()
    window.addEventListener("pointermove", this.onMove)
    window.addEventListener("pointerup", this.onUp)
  }

  move(event) {
    if (!this.before || !this.after || !this.total) return
    const delta = this.pointerPos(event) - this.startPos
    const ratio = (delta / this.total) * (this.startBefore + this.startAfter)
    const before = Math.max(0.05, this.startBefore + ratio)
    const after = Math.max(0.05, this.startAfter - ratio)
    this.before.style.flexGrow = String(before)
    this.after.style.flexGrow = String(after)
  }

  stop() {
    window.removeEventListener("pointermove", this.onMove)
    window.removeEventListener("pointerup", this.onUp)
    this.before = null
    this.after = null
  }

  keydown(event) {
    const decKey = this.horizontal ? "ArrowLeft" : "ArrowUp"
    const incKey = this.horizontal ? "ArrowRight" : "ArrowDown"
    if (event.key !== decKey && event.key !== incKey) return
    event.preventDefault()

    const index = this.handleTargets.indexOf(event.currentTarget)
    const before = this.panelTargets[index]
    const after = this.panelTargets[index + 1]
    if (!before || !after) return

    const step = event.key === incKey ? 0.05 : -0.05
    const b = Math.max(0.05, (parseFloat(before.style.flexGrow) || 1) + step)
    const a = Math.max(0.05, (parseFloat(after.style.flexGrow) || 1) - step)
    before.style.flexGrow = String(b)
    after.style.flexGrow = String(a)
  }

  pointerPos(event) {
    return this.horizontal ? event.clientX : event.clientY
  }

  get horizontal() {
    return this.directionValue !== "vertical"
  }
}
