import { Controller } from "@hotwired/stimulus"

// A two-state toggle button. Flips `aria-pressed` and `data-state` (on/off) and
// dispatches a `ui-toggle:change` event with the new pressed state.
export default class extends Controller {
  static values = { pressed: { type: Boolean, default: false } }

  toggle() {
    this.pressedValue = !this.pressedValue
    this.element.setAttribute("aria-pressed", this.pressedValue ? "true" : "false")
    this.element.dataset.state = this.pressedValue ? "on" : "off"
    this.dispatch("change", { detail: { pressed: this.pressedValue } })
  }
}
