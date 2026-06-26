import { Controller } from "@hotwired/stimulus"

// A hand-rolled Sonner-style toaster (no `sonner` dependency). Maintains a
// polite live region and a tiny imperative API: `window.toast({ title,
// description, variant, duration, actionLabel })` pushes a toast that
// auto-dismisses. Buttons inside the controller scope can enqueue declaratively
// with `data-action="click->ui-sonner#toast"` and `data-ui-sonner-*-param`s.
const ICON = {
  success: '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="m9 12 2 2 4-4"/></svg>',
  error: '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="m15 9-6 6"/><path d="m9 9 6 6"/></svg>',
  warning: '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><path d="M12 9v4"/><path d="M12 17h.01"/></svg>',
  info: '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4"/><path d="M12 8h.01"/></svg>'
}
const CLOSE_ICON = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>'

export default class extends Controller {
  static targets = ["list"]
  static values = { duration: { type: Number, default: 4000 } }

  connect() {
    this.previousToast = window.toast
    window.toast = (options = {}) => this.show(options)
  }

  disconnect() {
    window.toast = this.previousToast
  }

  // Declarative entry point for trigger buttons inside the controller scope.
  toast(event) {
    this.show({ ...event.params })
  }

  show({ title = "", description = "", variant = "default", duration, actionLabel } = {}) {
    if (!this.hasListTarget) return

    const item = document.createElement("li")
    item.dataset.slot = "sonner-toast"
    item.dataset.state = "closed"
    item.dataset.variant = variant
    item.setAttribute("role", variant === "error" ? "alert" : "status")
    item.className =
      "pointer-events-auto relative flex w-full items-start gap-3 overflow-hidden rounded-md border bg-background p-4 pr-8 text-foreground shadow-lg"

    if (ICON[variant]) {
      const glyph = document.createElement("span")
      glyph.className = variant === "error" ? "mt-0.5 shrink-0 text-destructive" : "mt-0.5 shrink-0"
      glyph.innerHTML = ICON[variant]
      item.appendChild(glyph)
    }

    const body = document.createElement("div")
    body.className = "flex-1 space-y-1"
    const heading = document.createElement("div")
    heading.className = "text-sm font-medium leading-none"
    heading.textContent = title
    body.appendChild(heading)
    if (description) {
      const desc = document.createElement("div")
      desc.className = "text-sm text-muted-foreground"
      desc.textContent = description
      body.appendChild(desc)
    }
    item.appendChild(body)

    if (actionLabel) {
      const action = document.createElement("button")
      action.type = "button"
      action.className =
        "inline-flex h-8 shrink-0 items-center rounded-md bg-primary px-3 text-xs font-medium text-primary-foreground transition-colors hover:bg-primary/90"
      action.textContent = actionLabel
      action.addEventListener("click", () => this.dismiss(item))
      item.appendChild(action)
    }

    const close = document.createElement("button")
    close.type = "button"
    close.setAttribute("aria-label", "Fechar")
    close.className =
      "absolute right-2 top-2 rounded-md p-1 text-foreground/50 transition-colors hover:text-foreground"
    close.innerHTML = CLOSE_ICON
    close.addEventListener("click", () => this.dismiss(item))
    item.appendChild(close)

    this.listTarget.appendChild(item)
    item.offsetHeight // flush layout with the closed state so the transition plays
    item.dataset.state = "open"

    const ms = duration ?? this.durationValue
    if (ms > 0) item.dismissTimer = setTimeout(() => this.dismiss(item), ms)
  }

  dismiss(item) {
    if (!item || item.dataset.state === "closed") return
    clearTimeout(item.dismissTimer)
    item.dataset.state = "closed"
    const remove = () => item.remove()
    item.addEventListener("transitionend", remove, { once: true })
    setTimeout(remove, 300)
  }
}
