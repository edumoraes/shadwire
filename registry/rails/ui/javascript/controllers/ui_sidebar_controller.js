import { Controller } from "@hotwired/stimulus"

// Drives the sidebar: desktop expand/collapse (persisted to a cookie) and the
// mobile off-canvas drawer. The trigger and rail dispatch `toggle`; the backdrop
// dispatches `closeMobile`. Cmd/Ctrl+B toggles from anywhere. State is written
// to the `data-state`/`data-mobile` attributes of the sidebar peer, which the
// utility classes read to animate.
const MOBILE_QUERY = "(max-width: 767px)"
const SHORTCUT_KEY = "b"

export default class extends Controller {
  static targets = ["sidebar"]
  static values = {
    open: { type: Boolean, default: true },
    cookieName: { type: String, default: "sidebar_state" },
    cookieMaxAge: { type: Number, default: 60 * 60 * 24 * 7 },
  }

  connect() {
    this.mql = window.matchMedia(MOBILE_QUERY)
    this.openMobile = false

    const stored = this.readCookie()
    if (stored !== null) this.openValue = stored

    this.onKeydown = this.handleKeydown.bind(this)
    window.addEventListener("keydown", this.onKeydown)

    this.applyState()
    this.applyMobile()
  }

  disconnect() {
    window.removeEventListener("keydown", this.onKeydown)
  }

  toggle(event) {
    if (event) event.preventDefault()

    if (this.mql.matches) {
      this.openMobile = !this.openMobile
      this.applyMobile()
    } else {
      this.openValue = !this.openValue
      this.writeCookie(this.openValue)
      this.applyState()
    }
  }

  closeMobile() {
    this.openMobile = false
    this.applyMobile()
  }

  handleKeydown(event) {
    if (event.key.toLowerCase() === SHORTCUT_KEY && (event.metaKey || event.ctrlKey)) {
      event.preventDefault()
      this.toggle()
    }
  }

  applyState() {
    if (!this.hasSidebarTarget) return

    const collapsed = !this.openValue
    this.sidebarTarget.dataset.state = collapsed ? "collapsed" : "expanded"
    // data-collapsible carries the active mode only while collapsed, matching
    // the group-data-[collapsible=...] utilities that drive the animation.
    const mode = this.sidebarTarget.dataset.collapsibleMode || "offcanvas"
    this.sidebarTarget.dataset.collapsible = collapsed ? mode : ""
  }

  applyMobile() {
    if (this.hasSidebarTarget) this.sidebarTarget.dataset.mobile = this.openMobile ? "open" : "closed"
  }

  readCookie() {
    const match = document.cookie.match(new RegExp(`(?:^|; )${this.cookieNameValue}=([^;]*)`))
    if (!match) return null
    return match[1] === "true"
  }

  writeCookie(open) {
    document.cookie = `${this.cookieNameValue}=${open}; path=/; max-age=${this.cookieMaxAgeValue}; SameSite=Lax`
  }
}
