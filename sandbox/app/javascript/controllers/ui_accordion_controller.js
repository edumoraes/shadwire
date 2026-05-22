import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "trigger", "content"]
  static values = {
    multiple: Boolean,
    defaultValue: Array,
    loopFocus: { type: Boolean, default: true },
    disabled: Boolean,
  }

  connect() {
    this.assignRuntimeValues()
    this.openValues = new Set(this.defaultValueValue.map((value) => String(value)))
    this.refresh()
  }

  toggle(event) {
    event.preventDefault()

    const item = this.itemFor(event.currentTarget)
    if (!item || this.itemDisabled(item)) return

    const value = item.dataset.uiAccordionValue
    if (this.openValues.has(value)) {
      this.openValues.delete(value)
    } else {
      if (!this.multipleValue) this.openValues.clear()
      this.openValues.add(value)
    }

    this.refresh()
  }

  navigate(event) {
    const keys = this.navigationKeys()
    if (!keys.includes(event.key) && event.key !== "Home" && event.key !== "End") return

    const enabledTriggers = this.triggerTargets.filter((trigger) => !this.itemDisabled(this.itemFor(trigger)))
    if (enabledTriggers.length === 0) return

    const currentIndex = enabledTriggers.indexOf(event.currentTarget)
    if (currentIndex === -1) return

    event.preventDefault()

    if (event.key === "Home") {
      enabledTriggers[0].focus()
      return
    }

    if (event.key === "End") {
      enabledTriggers[enabledTriggers.length - 1].focus()
      return
    }

    const delta = this.forwardKeys().includes(event.key) ? 1 : -1
    const nextIndex = this.nextIndex(currentIndex, delta, enabledTriggers.length)
    if (nextIndex !== currentIndex) enabledTriggers[nextIndex].focus()
  }

  refresh() {
    this.itemTargets.forEach((item, index) => {
      const trigger = this.triggerFor(item)
      const content = this.contentFor(item)
      const disabled = this.itemDisabled(item)
      const open = this.openValues.has(item.dataset.uiAccordionValue) && !disabled

      item.dataset.state = open ? "open" : "closed"
      this.toggleDataFlag(item, "open", open)
      this.toggleDataFlag(item, "disabled", disabled)
      item.setAttribute("aria-disabled", disabled ? "true" : "false")

      if (trigger) this.refreshTrigger(trigger, item, content, open, disabled)
      if (content) this.refreshContent(content, item, trigger, open, index)
    })
  }

  refreshTrigger(trigger, item, content, open, disabled) {
    trigger.dataset.state = open ? "open" : "closed"
    this.toggleDataFlag(trigger, "open", open)
    this.toggleDataFlag(trigger, "disabled", disabled)
    trigger.setAttribute("aria-expanded", open ? "true" : "false")
    trigger.setAttribute("aria-disabled", disabled ? "true" : "false")
    trigger.disabled = disabled

    if (!trigger.id) trigger.id = `${this.identifierFor(item)}-trigger`
    if (content) trigger.setAttribute("aria-controls", this.contentId(content, item))
  }

  refreshContent(content, item, trigger, open, index) {
    content.dataset.state = open ? "open" : "closed"
    this.toggleDataFlag(content, "open", open)
    content.hidden = !open
    content.style.setProperty("--radix-accordion-content-height", `${content.scrollHeight}px`)

    if (!content.id) content.id = `${this.identifierFor(item, index)}-content`
    if (trigger) content.setAttribute("aria-labelledby", trigger.id)
  }

  assignRuntimeValues() {
    this.itemTargets.forEach((item, index) => {
      if (!item.dataset.uiAccordionValue) item.dataset.uiAccordionValue = String(index)
    })
  }

  itemFor(element) {
    return element.closest("[data-ui-accordion-target~='item']")
  }

  triggerFor(item) {
    return item.querySelector("[data-ui-accordion-target~='trigger']")
  }

  contentFor(item) {
    return item.querySelector("[data-ui-accordion-target~='content']")
  }

  itemDisabled(item) {
    return this.disabledValue || item.hasAttribute("data-disabled")
  }

  navigationKeys() {
    return this.forwardKeys().concat(this.backwardKeys())
  }

  forwardKeys() {
    return this.orientation === "horizontal" ? ["ArrowRight"] : ["ArrowDown"]
  }

  backwardKeys() {
    return this.orientation === "horizontal" ? ["ArrowLeft"] : ["ArrowUp"]
  }

  nextIndex(currentIndex, delta, length) {
    const next = currentIndex + delta
    if (next >= 0 && next < length) return next
    return this.loopFocusValue ? (next + length) % length : currentIndex
  }

  contentId(content, item) {
    if (!content.id) content.id = `${this.identifierFor(item)}-content`
    return content.id
  }

  identifierFor(item, fallbackIndex = this.itemTargets.indexOf(item)) {
    return `${this.element.id || "accordion"}-${item.dataset.uiAccordionValue || fallbackIndex}`
  }

  toggleDataFlag(element, name, enabled) {
    if (enabled) {
      element.dataset[name] = ""
    } else {
      delete element.dataset[name]
    }
  }

  get orientation() {
    return this.element.dataset.orientation || "vertical"
  }
}
