import { Controller } from "@hotwired/stimulus"

// Toggles long documentation code blocks between a short preview and the full
// Scroll Area-backed source.
export default class extends Controller {
  static targets = ["button", "collapsed", "expanded", "label", "expandIcon", "collapseIcon"]
  // expand/collapse come from the server: this file has no access to Rails
  // i18n, and the site is published in two languages.
  static values = { expanded: Boolean, expand: String, collapse: String }

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
    this.labelTarget.textContent = expanded ? this.collapseValue : this.expandValue
    this.buttonTarget.setAttribute("aria-expanded", String(expanded))

    if (this.hasExpandIconTarget) this.expandIconTarget.hidden = expanded
    if (this.hasCollapseIconTarget) this.collapseIconTarget.hidden = !expanded
  }
}
