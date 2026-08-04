import { Controller } from "@hotwired/stimulus"

// Wires the ⌘K shortcut to the documentation palette and turns a Command
// selection into a navigation. The dialog and the filtering come from the
// ui-dialog and ui-command controllers; this only connects the two.
//
// Sandbox-only: this drives the docs site, not a Shadwire component.
export default class extends Controller {
  static targets = ["trigger"]

  connect() {
    this.openOnShortcut = this.openOnShortcut.bind(this)
    document.addEventListener("keydown", this.openOnShortcut)
  }

  disconnect() {
    document.removeEventListener("keydown", this.openOnShortcut)
  }

  openOnShortcut(event) {
    if (event.key?.toLowerCase() !== "k") return
    if (!event.metaKey && !event.ctrlKey) return

    event.preventDefault()
    this.triggerTarget.click()
  }

  // ui-command:select carries the chosen item; the destination rides on it as a
  // data attribute, because a Command item is an option, not a link.
  navigate(event) {
    const href = event.detail?.item?.dataset?.href
    if (!href) return

    if (window.Turbo) {
      window.Turbo.visit(href)
    } else {
      window.location.assign(href)
    }
  }
}
