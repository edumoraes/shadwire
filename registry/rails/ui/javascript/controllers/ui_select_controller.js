import { Controller } from "@hotwired/stimulus"

// The APG select-only combobox. Focus stays on the trigger; the active
// option is tracked with aria-activedescendant and data-highlighted while
// the listbox is open. Enter/Space are handled in keydown (preventDefault
// stops the native button click), so they never reach #toggle. Selection
// updates a hidden input and dispatches native input/change for forms.
export default class extends Controller {
  static targets = ["trigger", "value", "content", "item", "input"]
  static values = { value: String, placeholder: String }

  connect() {
    this.isOpen = false
    this.typeahead = ""
    this.typeaheadTimer = null
    this.highlighted = null
    this.assignIds()
    this.selectedValue = this.valueValue || ""
    this.renderSelection()
  }

  disconnect() {
    clearTimeout(this.typeaheadTimer)
  }

  toggle(event) {
    event.preventDefault()
    this.isOpen ? this.close() : this.open()
  }

  keydown(event) {
    if (!this.isOpen) {
      if ([ "ArrowDown", "ArrowUp", "Enter", " " ].includes(event.key)) {
        event.preventDefault()
        this.open()
      }
      return
    }

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.highlightRelative(1)
        break
      case "ArrowUp":
        event.preventDefault()
        this.highlightRelative(-1)
        break
      case "Home":
        event.preventDefault()
        this.highlightEdge("first")
        break
      case "End":
        event.preventDefault()
        this.highlightEdge("last")
        break
      case "Enter":
      case " ":
        event.preventDefault()
        if (this.highlighted) this.commit(this.highlighted)
        break
      case "Escape":
        event.preventDefault()
        this.close()
        break
      case "Tab":
        this.close({ focusTrigger: false })
        break
      default:
        if (event.key.length === 1) {
          event.preventDefault()
          this.handleTypeahead(event.key)
        }
    }
  }

  open() {
    if (!this.hasContentTarget || this.isOpen) return

    this.contentTarget.hidden = false
    this.contentTarget.dataset.state = "open"
    this.triggerTarget.setAttribute("aria-expanded", "true")
    this.isOpen = true

    const selected = this.itemTargets.find((item) => item.dataset.value === this.selectedValue)
    this.setHighlighted(selected && !this.itemDisabled(selected) ? selected : this.enabledItems()[0])
  }

  close({ focusTrigger = true } = {}) {
    if (!this.isOpen) return

    this.contentTarget.hidden = true
    delete this.contentTarget.dataset.state
    this.triggerTarget.setAttribute("aria-expanded", "false")
    this.triggerTarget.removeAttribute("aria-activedescendant")
    this.clearHighlight()
    this.isOpen = false
    if (focusTrigger) this.triggerTarget.focus()
  }

  select(event) {
    const item = event.currentTarget
    if (this.itemDisabled(item)) return

    this.commit(item)
  }

  highlight(event) {
    const item = event.currentTarget
    if (this.itemDisabled(item)) return

    this.setHighlighted(item)
  }

  commit(item) {
    this.selectedValue = item.dataset.value
    this.renderSelection()

    if (this.hasInputTarget) {
      this.inputTarget.value = this.selectedValue
      this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }))
      this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
    }

    this.dispatch("change", { detail: { value: this.selectedValue } })
    this.close()
  }

  renderSelection() {
    let label = this.placeholderValue
    let hasValue = false

    this.itemTargets.forEach((item) => {
      const selected = this.selectedValue !== "" && item.dataset.value === this.selectedValue
      item.setAttribute("aria-selected", selected ? "true" : "false")

      if (selected) {
        item.dataset.state = "checked"
        label = this.itemLabel(item)
        hasValue = true
      } else {
        delete item.dataset.state
      }
    })

    if (this.hasValueTarget) this.valueTarget.textContent = label

    if (hasValue) {
      delete this.triggerTarget.dataset.placeholder
    } else {
      this.triggerTarget.dataset.placeholder = ""
    }

    if (this.hasInputTarget) this.inputTarget.value = this.selectedValue
  }

  setHighlighted(item) {
    if (!item) return

    this.clearHighlight()
    this.highlighted = item
    item.dataset.highlighted = ""
    this.triggerTarget.setAttribute("aria-activedescendant", item.id)
    item.scrollIntoView({ block: "nearest" })
  }

  clearHighlight() {
    if (this.highlighted) delete this.highlighted.dataset.highlighted
    this.highlighted = null
  }

  highlightRelative(delta) {
    const items = this.enabledItems()
    if (items.length === 0) return

    const current = items.indexOf(this.highlighted)
    const next = Math.min(Math.max(current + delta, 0), items.length - 1)
    this.setHighlighted(items[next])
  }

  highlightEdge(edge) {
    const items = this.enabledItems()
    if (items.length === 0) return

    this.setHighlighted(edge === "last" ? items[items.length - 1] : items[0])
  }

  handleTypeahead(char) {
    this.typeahead += char.toLowerCase()
    clearTimeout(this.typeaheadTimer)
    this.typeaheadTimer = setTimeout(() => { this.typeahead = "" }, 500)

    const match = this.enabledItems().find(
      (item) => this.itemLabel(item).toLowerCase().startsWith(this.typeahead)
    )
    if (match) this.setHighlighted(match)
  }

  outsideClick(event) {
    if (!this.isOpen || this.element.contains(event.target)) return

    this.close({ focusTrigger: false })
  }

  enabledItems() {
    return this.itemTargets.filter((item) => !this.itemDisabled(item))
  }

  itemDisabled(item) {
    return item.hasAttribute("data-disabled")
  }

  itemLabel(item) {
    return item.textContent.replace(/\s+/g, " ").trim()
  }

  assignIds() {
    if (this.hasContentTarget && !this.contentTarget.id) {
      this.contentTarget.id = `${this.baseId()}-listbox`
    }
    if (this.hasTriggerTarget && this.hasContentTarget) {
      this.triggerTarget.setAttribute("aria-controls", this.contentTarget.id)
    }
    this.itemTargets.forEach((item, index) => {
      if (!item.id) item.id = `${this.baseId()}-option-${index}`
    })
  }

  baseId() {
    return this.element.id || "select"
  }
}
