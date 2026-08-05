import { Controller } from "@hotwired/stimulus"

// Copies the source of a documentation code block to the clipboard and gives
// brief visual feedback on the button label that triggered it.
export default class extends Controller {
  static targets = ["source", "label"]
  // The two labels come from the server rather than living here: this file has
  // no access to Rails i18n, and the site is published in two languages.
  static values = { source: String, copy: String, copied: String }

  copy() {
    const text = this.hasSourceValue ? this.sourceValue.trim() : this.sourceTarget.textContent.trim()
    navigator.clipboard.writeText(text).then(() => this.flash())
  }

  flash() {
    if (this.flashing) return

    this.flashing = true
    this.labelTarget.textContent = this.copiedValue

    setTimeout(() => {
      this.labelTarget.textContent = this.copyValue
      this.flashing = false
    }, 1500)
  }
}
