import { Controller } from "@hotwired/stimulus"

// A carousel. Slides are laid out in a flex track; prev/next (and Arrow keys)
// translate the track one slide at a time. Prev/next disable at the ends.
export default class extends Controller {
  static targets = ["track", "slide", "previous", "next"]
  static values = { orientation: { type: String, default: "horizontal" } }

  connect() {
    this.index = 0
    this.update()
  }

  previous() {
    this.index = Math.max(0, this.index - 1)
    this.update()
  }

  next() {
    this.index = Math.min(this.slideTargets.length - 1, this.index + 1)
    this.update()
  }

  keydown(event) {
    const prevKey = this.orientationValue === "vertical" ? "ArrowUp" : "ArrowLeft"
    const nextKey = this.orientationValue === "vertical" ? "ArrowDown" : "ArrowRight"
    if (event.key === prevKey) {
      event.preventDefault()
      this.previous()
    } else if (event.key === nextKey) {
      event.preventDefault()
      this.next()
    }
  }

  update() {
    const offset = -this.index * 100
    const axis = this.orientationValue === "vertical" ? "Y" : "X"
    if (this.hasTrackTarget) this.trackTarget.style.transform = `translate${axis}(${offset}%)`
    if (this.hasPreviousTarget) this.previousTarget.disabled = this.index === 0
    if (this.hasNextTarget) this.nextTarget.disabled = this.index >= this.slideTargets.length - 1
  }
}
