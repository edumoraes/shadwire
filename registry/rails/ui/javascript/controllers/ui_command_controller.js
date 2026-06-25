import { Controller } from "@hotwired/stimulus"

// A command palette. Typing in the input filters items (by `data-value` or text);
// empty groups and the empty state toggle automatically. Up/Down move the active
// option, Enter activates it, and the active option is mirrored via
// `aria-selected`/`data-active` and kept in view.
export default class extends Controller {
  static targets = ["input", "list", "item", "group", "empty"]

  connect() {
    this.filter()
  }

  filter() {
    const query = this.hasInputTarget ? this.inputTarget.value.trim().toLowerCase() : ""

    this.itemTargets.forEach((item) => {
      const haystack = (item.dataset.value || item.textContent).toLowerCase()
      item.hidden = query !== "" && !haystack.includes(query)
    })

    this.groupTargets.forEach((group) => {
      const items = [...group.querySelectorAll("[data-ui-command-target='item']")]
      group.hidden = items.length > 0 && items.every((item) => item.hidden)
    })

    const visible = this.visibleItems()
    if (this.hasEmptyTarget) this.emptyTarget.hidden = visible.length > 0
    this.setActive(visible[0] || null)
  }

  keydown(event) {
    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.move(1)
        break
      case "ArrowUp":
        event.preventDefault()
        this.move(-1)
        break
      case "Enter":
        event.preventDefault()
        if (this.active && !this.active.hidden) this.active.click()
        break
    }
  }

  select(event) {
    const item = event.currentTarget
    if (item.hasAttribute("data-disabled")) {
      event.preventDefault()
      return
    }
    this.dispatch("select", { detail: { value: item.dataset.value || item.textContent.trim(), item } })
  }

  move(delta) {
    const visible = this.visibleItems()
    if (visible.length === 0) return
    const current = visible.indexOf(this.active)
    const next = current === -1 ? 0 : (current + delta + visible.length) % visible.length
    this.setActive(visible[next])
  }

  setActive(item) {
    this.active = item
    this.itemTargets.forEach((candidate) => {
      const active = candidate === item
      candidate.dataset.active = active ? "true" : "false"
      candidate.setAttribute("aria-selected", active ? "true" : "false")
    })
    if (item) item.scrollIntoView({ block: "nearest" })
  }

  visibleItems() {
    return this.itemTargets.filter((item) => !item.hidden && !item.hasAttribute("data-disabled"))
  }
}
