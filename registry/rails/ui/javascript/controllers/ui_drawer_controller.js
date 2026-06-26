import { Controller } from "@hotwired/stimulus"

// A native <dialog> drawer anchored to an edge, with sheet-style animation and
// optional drag-to-dismiss from a handle. showModal() supplies the focus trap,
// top layer, Escape handling and focus restoration.
export default class extends Controller {
  static targets = ["dialog"]
  static values = { closeOnBackdrop: { type: Boolean, default: true } }

  disconnect() {
    this.clearFallback()
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
    this.closeFallback = setTimeout(this.finishClose, 320)
  }

  backdropClick(event) {
    if (!this.closeOnBackdropValue || event.target !== this.dialogTarget) return

    const rect = this.dialogTarget.getBoundingClientRect()
    const inside =
      event.clientX >= rect.left && event.clientX <= rect.right &&
      event.clientY >= rect.top && event.clientY <= rect.bottom
    if (!inside) this.close()
  }

  cancel(event) {
    event.preventDefault()
    this.close()
  }

  closed() {
    delete this.dialogTarget.dataset.state
    this.dispatch("close")
  }

  dragStart(event) {
    this.dragStartY = event.clientY
    this.dragging = true
    this.onMove = (e) => this.dragMove(e)
    this.onUp = (e) => this.dragEnd(e)
    window.addEventListener("pointermove", this.onMove)
    window.addEventListener("pointerup", this.onUp)
  }

  dragMove(event) {
    if (!this.dragging) return
    const delta = event.clientY - this.dragStartY
    if (delta > 0) this.dialogTarget.style.transform = `translateY(${delta}px)`
  }

  dragEnd(event) {
    this.dragging = false
    window.removeEventListener("pointermove", this.onMove)
    window.removeEventListener("pointerup", this.onUp)
    const delta = event.clientY - this.dragStartY
    this.dialogTarget.style.transform = ""
    if (delta > 120) this.close()
  }

  finishClose = () => {
    this.clearFallback()
    if (this.hasDialogTarget && this.dialogTarget.open) this.dialogTarget.close()
  }

  clearFallback() {
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
    return this.element.id || "drawer"
  }
}
