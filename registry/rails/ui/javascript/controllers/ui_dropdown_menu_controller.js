import { Controller } from "@hotwired/stimulus"

// The WAI-ARIA menu button pattern. Focus roves across enabled menu items;
// arrows wrap, Home/End jump to the edges, typeahead matches by prefix, and
// Escape/Tab/outside-click dismiss. Enter and Space activate items through
// their native button click, so they are not handled here.
export default class extends Controller {
  static targets = ["trigger", "content", "item"]
  static values = { closeOnSelect: { type: Boolean, default: true } }

  connect() {
    this.isOpen = false
    this.typeahead = ""
    this.typeaheadTimer = null
  }

  disconnect() {
    clearTimeout(this.typeaheadTimer)
  }

  toggle(event) {
    event.preventDefault()
    this.isOpen ? this.close() : this.open()
  }

  triggerKeydown(event) {
    if (event.key === "ArrowDown") {
      event.preventDefault()
      this.open({ focus: "first" })
    } else if (event.key === "ArrowUp") {
      event.preventDefault()
      this.open({ focus: "last" })
    }
  }

  open({ focus = "first" } = {}) {
    if (!this.hasContentTarget || this.isOpen) return

    this.contentTarget.hidden = false
    this.contentTarget.dataset.state = "open"
    if (this.hasTriggerTarget) this.triggerTarget.setAttribute("aria-expanded", "true")
    this.isOpen = true

    const items = this.enabledItems()
    const target = focus === "last" ? items[items.length - 1] : items[0]
    if (target) target.focus()
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
        this.close({ focusTrigger: true })
        break
      case "Tab":
        this.close()
        break
      default:
        if (event.key.length === 1 && !event.metaKey && !event.ctrlKey) this.handleTypeahead(event.key)
    }
  }

  select(event) {
    const item = event.currentTarget
    if (item.hasAttribute("data-disabled")) {
      event.preventDefault()
      return
    }

    this.dispatch("select", { detail: { item } })
    if (this.closeOnSelectValue) this.close({ focusTrigger: true })
  }

  outsideClick(event) {
    if (!this.isOpen || this.element.contains(event.target)) return

    this.close()
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

    const match = this.enabledItems().find(
      (item) => item.textContent.trim().toLowerCase().startsWith(this.typeahead)
    )
    if (match) match.focus()
  }
}
