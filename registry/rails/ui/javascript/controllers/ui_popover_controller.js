import { Controller } from "@hotwired/stimulus"

// A non-modal popover. Opens on the trigger, moves focus into the content,
// closes on outside click or Escape, and returns focus to the trigger when
// dismissed by keyboard.
export default class extends Controller {
  static targets = ["trigger", "content"]

  connect() {
    this.isOpen = false
    // A Turbo snapshot taken while the popover is open restores the markup open
    // but this controller closed, and every dismissal path checks isOpen first.
    // Close before the snapshot is taken so the two never disagree.
    this.closeBeforeCache = () => this.close()
    document.addEventListener("turbo:before-cache", this.closeBeforeCache)
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.closeBeforeCache)
  }

  toggle(event) {
    event.preventDefault()
    this.isOpen ? this.close() : this.open()
  }

  open() {
    if (!this.hasContentTarget || this.isOpen) return

    this.contentTarget.hidden = false
    this.contentTarget.dataset.state = "open"
    if (this.hasTriggerTarget) this.triggerTarget.setAttribute("aria-expanded", "true")
    this.isOpen = true
    this.contentTarget.focus()
  }

  close({ focusTrigger = false } = {}) {
    if (!this.isOpen) return

    if (this.hasContentTarget) {
      this.contentTarget.hidden = true
      delete this.contentTarget.dataset.state
    }
    if (this.hasTriggerTarget) this.triggerTarget.setAttribute("aria-expanded", "false")
    this.isOpen = false
    if (focusTrigger && this.hasTriggerTarget) this.triggerTarget.focus()
  }

  outsideClick(event) {
    if (!this.isOpen || this.element.contains(event.target)) return

    this.close()
  }

  closeOnEscape(event) {
    if (!this.isOpen) return

    event.preventDefault()
    this.close({ focusTrigger: true })
  }
}
