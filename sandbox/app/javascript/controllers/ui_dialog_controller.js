import { Controller } from "@hotwired/stimulus"

// Drives native <dialog> elements (dialog, alert dialog, and sheet).
// showModal() provides the focus trap, top layer, Escape handling, and
// focus restoration; this controller adds animated open/close states,
// optional backdrop dismissal, and aria wiring.
export default class extends Controller {
  static targets = ["dialog"]
  static values = {
    closeOnBackdrop: { type: Boolean, default: true },
    closeOnEscape: { type: Boolean, default: true },
  }

  disconnect() {
    this.clearCloseFallback()
  }

  open(event) {
    if (event) event.preventDefault()
    if (!this.hasDialogTarget || this.dialogTarget.open) return

    this.wireAria()
    this.dialogTarget.showModal()
    this.dialogTarget.dataset.state = "open"
    this.dispatch("open")
  }

  close(event) {
    if (event) event.preventDefault()
    if (!this.hasDialogTarget || !this.dialogTarget.open) return
    if (this.dialogTarget.dataset.state === "closed") return

    this.dialogTarget.dataset.state = "closed"
    this.dialogTarget.addEventListener("animationend", this.finishClose, { once: true })
    this.closeFallback = setTimeout(this.finishClose, 200)
  }

  backdropClick(event) {
    if (!this.closeOnBackdropValue) return
    if (event.target !== this.dialogTarget) return

    const rect = this.dialogTarget.getBoundingClientRect()
    const insidePanel =
      event.clientX >= rect.left && event.clientX <= rect.right &&
      event.clientY >= rect.top && event.clientY <= rect.bottom
    if (!insidePanel) this.close()
  }

  // Native cancel (Escape). Always prevented so closing goes through the
  // animated path; ignored entirely when closeOnEscape is off (alert dialog).
  cancel(event) {
    event.preventDefault()
    if (this.closeOnEscapeValue) this.close()
  }

  closed() {
    delete this.dialogTarget.dataset.state
    this.dispatch("close")
  }

  finishClose = () => {
    this.clearCloseFallback()
    if (this.hasDialogTarget && this.dialogTarget.open) this.dialogTarget.close()
  }

  clearCloseFallback() {
    if (!this.closeFallback) return

    clearTimeout(this.closeFallback)
    this.closeFallback = null
  }

  wireAria() {
    const dialog = this.dialogTarget
    const title = dialog.querySelector("[data-slot$='-title']")
    const description = dialog.querySelector("[data-slot$='-description']")

    if (title) {
      if (!title.id) title.id = `${this.baseId()}-title`
      dialog.setAttribute("aria-labelledby", title.id)
    }

    if (description) {
      if (!description.id) description.id = `${this.baseId()}-description`
      dialog.setAttribute("aria-describedby", description.id)
    }
  }

  baseId() {
    return this.element.id || "dialog"
  }
}
