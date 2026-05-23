import { Controller } from "@hotwired/stimulus"

// Toggles long documentation code blocks between a short preview and the full
// Scroll Area-backed source.
export default class extends Controller {
  static targets = ["button", "collapsed", "expanded", "label", "expandIcon", "collapseIcon"]
  static values = { expanded: Boolean }

  connect() {
    this.render()
  }

  toggle() {
    this.expandedValue = !this.expandedValue
  }

  expandedValueChanged() {
    this.render()
  }

  render() {
    const expanded = this.expandedValue

    this.collapsedTarget.hidden = expanded
    this.expandedTarget.hidden = !expanded
    this.labelTarget.textContent = expanded ? "Recolher" : "Expandir"
    this.buttonTarget.setAttribute("aria-expanded", String(expanded))

    if (this.hasExpandIconTarget) this.expandIconTarget.hidden = expanded
    if (this.hasCollapseIconTarget) this.collapseIconTarget.hidden = !expanded
  }
}
