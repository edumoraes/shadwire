import { Controller } from "@hotwired/stimulus"

// A horizontal menubar (WAI-ARIA menubar pattern). Triggers and their menus are
// paired by DOM order; only one menu is open at a time. Left/Right move between
// triggers, Down opens a menu, and once open the pointer can sweep across the
// bar to switch menus.
export default class extends Controller {
  static targets = ["trigger", "content"]

  connect() {
    this.openIndex = null
  }

  toggle(event) {
    const index = this.triggerTargets.indexOf(event.currentTarget)
    this.openIndex === index ? this.close() : this.open(index)
  }

  triggerEnter(event) {
    if (this.openIndex === null) return
    const index = this.triggerTargets.indexOf(event.currentTarget)
    if (index !== this.openIndex) this.open(index)
  }

  triggerKeydown(event) {
    const index = this.triggerTargets.indexOf(event.currentTarget)
    switch (event.key) {
      case "ArrowRight":
        event.preventDefault()
        this.focusTrigger(index + 1)
        break
      case "ArrowLeft":
        event.preventDefault()
        this.focusTrigger(index - 1)
        break
      case "ArrowDown":
      case "Enter":
      case " ":
        event.preventDefault()
        this.open(index)
        break
    }
  }

  contentKeydown(event) {
    const index = this.contentTargets.indexOf(event.currentTarget)
    const items = this.itemsFor(index)
    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.moveWithin(items, 1)
        break
      case "ArrowUp":
        event.preventDefault()
        this.moveWithin(items, -1)
        break
      case "Escape":
        event.preventDefault()
        this.close()
        this.triggerTargets[index]?.focus()
        break
      case "ArrowRight":
        event.preventDefault()
        this.open(this.wrap(index + 1))
        break
      case "ArrowLeft":
        event.preventDefault()
        this.open(this.wrap(index - 1))
        break
    }
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
    this.itemsFor(index)[0]?.focus()
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

  focusTrigger(index) {
    const trigger = this.triggerTargets[this.wrap(index)]
    if (!trigger) return
    trigger.focus()
    if (this.openIndex !== null) this.open(this.wrap(index))
  }

  moveWithin(items, delta) {
    if (items.length === 0) return
    const current = items.indexOf(document.activeElement)
    const next = current === -1 ? 0 : (current + delta + items.length) % items.length
    items[next].focus()
  }

  itemsFor(index) {
    const content = this.contentTargets[index]
    return content ? [...content.querySelectorAll("[role='menuitem']")].filter((i) => !i.hasAttribute("data-disabled")) : []
  }

  wrap(index) {
    const count = this.triggerTargets.length
    return (index + count) % count
  }
}
