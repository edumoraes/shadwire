import { Controller } from "@hotwired/stimulus"

// A navigation menu: a row of triggers that disclose content panels. One panel
// is open at a time; opens on click or pointer/focus, closes on pointer-leave,
// Escape, or outside click.
export default class extends Controller {
  static targets = ["trigger", "content"]

  connect() {
    this.openIndex = null
  }

  disconnect() {
    clearTimeout(this.closeTimer)
  }

  toggle(event) {
    const index = this.triggerTargets.indexOf(event.currentTarget)
    this.openIndex === index ? this.close() : this.open(index)
  }

  openOn(event) {
    clearTimeout(this.closeTimer)
    const index = this.triggerTargets.indexOf(event.currentTarget)
    if (index !== -1) this.open(index)
  }

  scheduleClose() {
    clearTimeout(this.closeTimer)
    this.closeTimer = setTimeout(() => this.close(), 150)
  }

  cancelClose() {
    clearTimeout(this.closeTimer)
  }

  closeOnEscape(event) {
    if (this.openIndex === null) return
    event.preventDefault()
    const trigger = this.triggerTargets[this.openIndex]
    this.close()
    trigger?.focus()
  }

  open(index) {
    this.contentTargets.forEach((content, i) => {
      const active = i === index
      content.hidden = !active
      if (active) content.dataset.state = "open"
      else delete content.dataset.state
      this.triggerTargets[i]?.setAttribute("aria-expanded", active ? "true" : "false")
    })
    this.openIndex = index
  }

  close() {
    this.contentTargets.forEach((content, i) => {
      content.hidden = true
      delete content.dataset.state
      this.triggerTargets[i]?.setAttribute("aria-expanded", "false")
    })
    this.openIndex = null
  }

  outsideClick(event) {
    if (this.openIndex === null || this.element.contains(event.target)) return
    this.close()
  }
}
