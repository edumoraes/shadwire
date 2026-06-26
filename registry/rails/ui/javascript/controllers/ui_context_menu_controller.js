import { Controller } from "@hotwired/stimulus"

// A right-click menu. Opens at the pointer on `contextmenu`, then follows the
// WAI-ARIA menu pattern: roving focus across enabled items, Home/End, typeahead,
// and Escape/outside-click to dismiss.
export default class extends Controller {
  static targets = ["content", "item"]

  connect() {
    this.isOpen = false
    this.typeahead = ""
  }

  disconnect() {
    clearTimeout(this.typeaheadTimer)
  }

  open(event) {
    event.preventDefault()
    if (!this.hasContentTarget) return

    const rect = this.element.getBoundingClientRect()
    this.contentTarget.style.left = `${event.clientX - rect.left}px`
    this.contentTarget.style.top = `${event.clientY - rect.top}px`
    this.contentTarget.hidden = false
    this.contentTarget.dataset.state = "open"
    this.isOpen = true

    const first = this.enabledItems()[0]
    if (first) first.focus()
  }

  close() {
    if (!this.isOpen) return
    this.contentTarget.hidden = true
    delete this.contentTarget.dataset.state
    this.isOpen = false
  }

  outsideClick(event) {
    if (!this.isOpen || this.contentTarget.contains(event.target)) return
    this.close()
  }

  select(event) {
    const item = event.currentTarget
    if (item.hasAttribute("data-disabled")) {
      event.preventDefault()
      return
    }
    this.dispatch("select", { detail: { item } })
    this.close()
  }

  keydown(event) {
    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.focusRelative(1)
        break
      case "ArrowUp":
        event.preventDefault()
        this.focusRelative(-1)
        break
      case "Home":
        event.preventDefault()
        this.focusEdge("first")
        break
      case "End":
        event.preventDefault()
        this.focusEdge("last")
        break
      case "Escape":
        event.preventDefault()
        this.close()
        break
      default:
        if (event.key.length === 1 && !event.metaKey && !event.ctrlKey) this.handleTypeahead(event.key)
    }
  }

  enabledItems() {
    return this.itemTargets.filter((item) => !item.hasAttribute("data-disabled"))
  }

  focusRelative(delta) {
    const items = this.enabledItems()
    if (items.length === 0) return
    const current = items.indexOf(document.activeElement)
    const next = current === -1 ? 0 : (current + delta + items.length) % items.length
    items[next].focus()
  }

  focusEdge(edge) {
    const items = this.enabledItems()
    if (items.length === 0) return
    ;(edge === "last" ? items[items.length - 1] : items[0]).focus()
  }

  handleTypeahead(char) {
    this.typeahead += char.toLowerCase()
    clearTimeout(this.typeaheadTimer)
    this.typeaheadTimer = setTimeout(() => { this.typeahead = "" }, 500)
    const match = this.enabledItems().find((item) => item.textContent.trim().toLowerCase().startsWith(this.typeahead))
    if (match) match.focus()
  }
}
