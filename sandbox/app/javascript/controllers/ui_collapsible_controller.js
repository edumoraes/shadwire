import { Controller } from "@hotwired/stimulus"

// An expand/collapse disclosure. The trigger toggles a single content region;
// `data-state` drives the height animation (the controller measures the
// natural height into a CSS variable, mirroring the accordion).
export default class extends Controller {
  static targets = ["content", "trigger"]
  static values = { open: { type: Boolean, default: false } }

  connect() {
    this.render(this.openValue)
  }

  toggle(event) {
    if (event) event.preventDefault()
    this.openValue = !this.openValue
    this.render(this.openValue)
  }

  open() {
    this.openValue = true
    this.render(true)
  }

  close() {
    this.openValue = false
    this.render(false)
  }

  render(open) {
    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", open ? "true" : "false")
      this.triggerTarget.dataset.state = open ? "open" : "closed"
    }

    this.contentTargets.forEach((content) => {
      if (open) {
        content.hidden = false
        content.style.setProperty("--radix-collapsible-content-height", `${content.scrollHeight}px`)
        content.dataset.state = "open"
      } else {
        content.dataset.state = "closed"
        content.hidden = true
      }
    })

    this.element.dataset.state = open ? "open" : "closed"
  }
}
