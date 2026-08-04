import { Controller } from "@hotwired/stimulus"

// Builds the "Nesta página" rail from the headings already in the document, so
// every documentation page gets a table of contents without each view having to
// declare one. Also highlights the section currently in view.
//
// Sandbox-only: this drives the docs site, not a Shadwire component.
export default class extends Controller {
  static targets = ["content", "list", "panel"]

  connect() {
    this.headings = this.collectHeadings()

    if (this.headings.length === 0) {
      this.hidePanel()
      return
    }

    this.renderList()
    this.observe()
  }

  disconnect() {
    this.observer?.disconnect()
  }

  // h2/h3 inside the page body. Headings that live inside a live component
  // preview would point at demo content, so they are skipped.
  collectHeadings() {
    if (!this.hasContentTarget) return []

    return Array.from(this.contentTarget.querySelectorAll("h2, h3")).filter(
      (heading) => heading.textContent.trim() !== "" && !heading.closest("[data-slot='card']")
    )
  }

  renderList() {
    const items = this.headings.map((heading) => {
      heading.id ||= this.slugify(heading.textContent)
      // Keeps an anchor jump clear of the sticky header.
      heading.classList.add("scroll-mt-24")

      const link = document.createElement("a")
      link.href = `#${heading.id}`
      link.textContent = heading.textContent.trim()
      link.className = this.linkClasses(heading)
      link.dataset.tocFor = heading.id

      const item = document.createElement("li")
      item.appendChild(link)
      return item
    })

    this.listTarget.replaceChildren(...items)
    this.links = Array.from(this.listTarget.querySelectorAll("a"))
  }

  linkClasses(heading) {
    const indent = heading.tagName === "H3" ? "pl-6" : "pl-3"
    return `-ml-px block border-l border-transparent py-1 ${indent} text-muted-foreground transition-colors hover:text-foreground data-[active=true]:border-foreground data-[active=true]:font-medium data-[active=true]:text-foreground`
  }

  // Track which headings are on screen and mark the topmost one active. The
  // negative bottom margin keeps the highlight on the section being read rather
  // than on whatever is about to scroll in from below.
  observe() {
    this.visible = new Set()
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            this.visible.add(entry.target.id)
          } else {
            this.visible.delete(entry.target.id)
          }
        })
        this.highlight()
      },
      { rootMargin: "-80px 0px -70% 0px", threshold: 0 }
    )

    this.headings.forEach((heading) => this.observer.observe(heading))
  }

  highlight() {
    const active = this.headings.find((heading) => this.visible.has(heading.id))

    this.links.forEach((link) => {
      link.dataset.active = String(Boolean(active) && link.dataset.tocFor === active.id)
    })
  }

  hidePanel() {
    if (this.hasPanelTarget) this.panelTarget.style.display = "none"
  }

  slugify(text) {
    return text
      .trim()
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-|-$/g, "")
  }
}
