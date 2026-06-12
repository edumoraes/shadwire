import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "panel"]
  static values = { defaultValue: String }

  connect() {
    this.wireAria()
    this.activate(this.initialTrigger(), { focus: false })
  }

  select(event) {
    event.preventDefault()

    const trigger = event.currentTarget
    if (this.triggerDisabled(trigger)) return

    this.activate(trigger, { focus: false })
  }

  navigate(event) {
    if (!["ArrowRight", "ArrowLeft", "Home", "End"].includes(event.key)) return

    const triggers = this.enabledTriggers()
    if (triggers.length === 0) return

    const currentIndex = triggers.indexOf(event.currentTarget)
    if (currentIndex === -1) return

    event.preventDefault()

    let next
    if (event.key === "Home") {
      next = triggers[0]
    } else if (event.key === "End") {
      next = triggers[triggers.length - 1]
    } else {
      const delta = event.key === "ArrowRight" ? 1 : -1
      next = triggers[(currentIndex + delta + triggers.length) % triggers.length]
    }

    this.activate(next, { focus: true })
  }

  activate(trigger, { focus }) {
    if (!trigger) return

    const value = trigger.dataset.uiTabsValue

    this.triggerTargets.forEach((candidate) => {
      const active = candidate === trigger
      candidate.dataset.state = active ? "active" : "inactive"
      candidate.setAttribute("aria-selected", active ? "true" : "false")
      candidate.tabIndex = active ? 0 : -1
    })

    this.panelTargets.forEach((panel) => {
      const active = panel.dataset.uiTabsValue === value
      panel.dataset.state = active ? "active" : "inactive"
      panel.hidden = !active
    })

    if (focus) trigger.focus()
    this.dispatch("change", { detail: { value } })
  }

  wireAria() {
    this.triggerTargets.forEach((trigger, index) => {
      const value = trigger.dataset.uiTabsValue || String(index)
      const panel = this.panelFor(value)

      if (!trigger.id) trigger.id = `${this.baseId()}-trigger-${value}`
      if (!panel) return

      if (!panel.id) panel.id = `${this.baseId()}-panel-${value}`
      trigger.setAttribute("aria-controls", panel.id)
      panel.setAttribute("aria-labelledby", trigger.id)
    })
  }

  initialTrigger() {
    const triggers = this.enabledTriggers()
    const wanted = triggers.find((trigger) => trigger.dataset.uiTabsValue === this.defaultValueValue)
    return wanted || triggers[0]
  }

  enabledTriggers() {
    return this.triggerTargets.filter((trigger) => !this.triggerDisabled(trigger))
  }

  triggerDisabled(trigger) {
    return trigger.disabled || trigger.hasAttribute("data-disabled")
  }

  panelFor(value) {
    return this.panelTargets.find((panel) => panel.dataset.uiTabsValue === value)
  }

  baseId() {
    return this.element.id || "tabs"
  }
}
