import { Controller } from "@hotwired/stimulus"

// Builds the "Nesta página" rail from the headings already in the document, so
// every documentation page gets a table of contents without each view having to
// declare one. Also highlights the section currently being read.
//
// Sandbox-only: this drives the docs site, not a Shadwire component.
export default class extends Controller {
  static targets = ["content", "list", "panel"]

  // How far below the sticky header a heading has to be before it counts as
  // "not read yet". Matches the scroll-mt-24 the headings carry.
  static ACTIVE_OFFSET = 100

  connect() {
    this.headings = this.collectHeadings()

    if (this.headings.length === 0 || !this.hasListTarget) {
      this.hidePanel()
      return
    }

    this.renderList()
    this.track()
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
    window.removeEventListener("resize", this.onScroll)
    if (this.frame) cancelAnimationFrame(this.frame)
  }

  // h2/h3 of the page itself. Live component previews carry their own headings
  // (an accordion's questions, a dialog's title) which describe demo content,
  // not the page, so the preview marks itself with data-docs-toc-skip and
  // everything inside it is left out. Headings inside a closed <dialog> would
  // also be dead anchors, hence the second guard.
  collectHeadings() {
    if (!this.hasContentTarget) return []

    return Array.from(this.contentTarget.querySelectorAll("h2, h3")).filter(
      (heading) =>
        heading.textContent.trim() !== "" &&
        !heading.closest("[data-docs-toc-skip]") &&
        !heading.closest("dialog")
    )
  }

  renderList() {
    const used = new Set()

    const items = this.headings.map((heading) => {
      if (!heading.id) heading.id = this.uniqueId(this.slugify(heading.textContent), used)
      used.add(heading.id)
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

  track() {
    this.onScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })
    window.addEventListener("resize", this.onScroll, { passive: true })
    this.highlight()
  }

  onScroll() {
    if (this.frame) return

    this.frame = requestAnimationFrame(() => {
      this.frame = null
      this.highlight()
    })
  }

  // The last heading that has scrolled past the header. Computing it from
  // positions rather than from an IntersectionObserver band means exactly one
  // entry is always active: a section taller than the viewport used to leave
  // the whole rail unhighlighted.
  highlight() {
    let active = this.headings[0]

    for (const heading of this.headings) {
      if (heading.getBoundingClientRect().top > this.constructor.ACTIVE_OFFSET) break
      active = heading
    }

    // The last section is often too short to ever reach the offset, so the
    // bottom of the page hands it the highlight.
    if (window.scrollY + window.innerHeight >= document.documentElement.scrollHeight - 2) {
      active = this.headings[this.headings.length - 1]
    }

    this.links.forEach((link) => {
      link.dataset.active = String(link.dataset.tocFor === active.id)
    })
  }

  hidePanel() {
    if (this.hasPanelTarget) this.panelTarget.style.display = "none"
  }

  // Two sections can legitimately share a title, and a duplicate DOM id would
  // send both links to the first one.
  uniqueId(slug, used) {
    if (!used.has(slug) && !document.getElementById(slug)) return slug

    let suffix = 2
    while (used.has(`${slug}-${suffix}`) || document.getElementById(`${slug}-${suffix}`)) suffix++
    return `${slug}-${suffix}`
  }

  slugify(text) {
    return text
      .trim()
      .toLowerCase()
      .normalize("NFD")
      .replace(/[̀-ͯ]/g, "")
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-|-$/g, "")
  }
}
