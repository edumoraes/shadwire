import { Controller } from "@hotwired/stimulus"

// Copies the source of a documentation code block to the clipboard and gives
// brief visual feedback on the button label that triggered it.
export default class extends Controller {
  static targets = ["source", "label"]

  copy() {
    const text = this.sourceTarget.textContent.trim()
    navigator.clipboard.writeText(text).then(() => this.flash())
  }

  flash() {
    if (this.flashing) return

    this.flashing = true
    this.labelTarget.textContent = "Copiado!"

    setTimeout(() => {
      this.labelTarget.textContent = "Copiar"
      this.flashing = false
    }, 1500)
  }
}
