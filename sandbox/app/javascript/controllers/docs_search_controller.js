import { Controller } from "@hotwired/stimulus"

// Wires the ⌘K shortcut to the documentation palette, searches the text of
// every page, and turns a Command selection into a navigation. The dialog, the
// list and the keyboard handling come from ui-dialog and ui-command; this adds
// the corpus they have no way to know about.
//
// The site is published as a static crawl, so there is no server to query: the
// index is built at deploy time (DocsSearchIndex) and fetched here on the first
// keystroke, not on page load. Everything below degrades to ui-command's own
// title filter if that fetch never lands.
//
// Sandbox-only: this drives the docs site, not a Shadwire component.
export default class extends Controller {
  static targets = ["trigger", "results"]
  static values = { indexUrl: String, groupLabel: String }

  // A title hit beats a heading hit beats a body hit. Ranking by where the match
  // landed is what makes "theming" open Theming rather than the several pages
  // that merely mention it.
  static TITLE = 3
  static HEADING = 2
  static BODY = 1

  // Enough hits to be worth scrolling, few enough that the palette does not
  // become its own reading task.
  static LIMIT = 12
  // Long enough for the match to sit in a sentence, short enough to stay on one line.
  static SNIPPET = 120

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
    // Ctrl+K is a text-editing binding on macOS, and the palette's own input is
    // a text field, so leave the shortcut alone while someone is typing.
    if (this.isTyping(event.target)) return

    event.preventDefault()
    this.triggerTarget.click()
  }

  isTyping(target) {
    if (!target) return false

    return target.isContentEditable || ["INPUT", "TEXTAREA", "SELECT"].includes(target.tagName)
  }

  async search(event) {
    const query = event.target.value.trim().toLowerCase()
    if (query === "") return this.clearResults()

    const pages = await this.index()
    if (!pages) return // the fetch failed; ui-command's title filter still ran

    // Another keystroke landed while the index was in flight, and it has already
    // rendered results of its own.
    if (event.target.value.trim().toLowerCase() !== query) return

    this.render(this.rank(pages, query), query)
  }

  rank(pages, query) {
    return pages
      .map((page) => ({ page, ...this.match(page, query) }))
      .filter((hit) => hit.score > 0)
      .sort((a, b) => b.score - a.score || a.page.title.localeCompare(b.page.title))
      .slice(0, this.constructor.LIMIT)
  }

  match(page, query) {
    if (page.title.toLowerCase().includes(query)) {
      return { score: this.constructor.TITLE, context: page.title }
    }

    const heading = page.headings.find((entry) => entry.toLowerCase().includes(query))
    if (heading) return { score: this.constructor.HEADING, context: heading }

    const at = page.text.toLowerCase().indexOf(query)
    if (at === -1) return { score: 0 }

    return { score: this.constructor.BODY, context: this.snippet(page.text, at, query.length) }
  }

  // A window around the match rather than the head of the page: the point of a
  // body hit is to show the reader why the page came up at all.
  snippet(text, at, length) {
    const half = Math.floor((this.constructor.SNIPPET - length) / 2)
    const from = Math.max(0, at - half)
    const to = Math.min(text.length, at + length + half)

    return `${from > 0 ? "…" : ""}${text.slice(from, to).trim()}${to < text.length ? "…" : ""}`
  }

  render(hits, query) {
    this.resultsTarget.replaceChildren()
    if (hits.length === 0) return this.refilter()

    const group = document.createElement("div")
    group.setAttribute("role", "group")
    group.className = "overflow-hidden p-1 text-foreground"
    group.dataset.slot = "command-group"
    group.dataset.uiCommandTarget = "group"
    group.append(this.groupHeading(), ...hits.map((hit) => this.item(hit, query)))

    this.resultsTarget.append(group)
    this.refilter()
  }

  groupHeading() {
    const heading = document.createElement("div")
    heading.className = "px-2 py-1.5 text-xs font-medium text-muted-foreground"
    heading.dataset.slot = "command-group-heading"
    heading.textContent = this.groupLabelValue
    return heading
  }

  // Shaped like Ui::Command::ItemComponent so ui-command adopts it: same slot,
  // same target, same action. data-value carries the text this item matched on,
  // which therefore always contains the query — otherwise ui-command's own
  // filter, which runs on the same keystroke, would hide the results as fast as
  // they appear.
  item(hit, query) {
    const element = document.createElement("div")
    element.setAttribute("role", "option")
    element.setAttribute("aria-selected", "false")
    element.className =
      "relative flex cursor-pointer select-none flex-col items-start gap-0.5 rounded-sm px-2 py-1.5 text-sm outline-none data-[active=true]:bg-accent data-[active=true]:text-accent-foreground"
    element.dataset.slot = "command-item"
    element.dataset.uiCommandTarget = "item"
    element.dataset.action = "click->ui-command#select"
    element.dataset.href = hit.page.path
    element.dataset.value = `${hit.page.title} ${hit.context}`

    const title = document.createElement("span")
    title.className = "font-medium"
    title.textContent = hit.page.title

    const context = document.createElement("span")
    context.className = "line-clamp-1 text-xs text-muted-foreground"
    context.append(...this.highlight(hit.context, query))

    element.append(title, context)
    return element
  }

  // Marks the match inside the snippet. Built from text nodes rather than
  // innerHTML: this is page content, and it is not going through a parser on
  // its way into the DOM.
  highlight(text, query) {
    const at = text.toLowerCase().indexOf(query)
    if (at === -1) return [document.createTextNode(text)]

    const mark = document.createElement("mark")
    mark.className = "bg-transparent font-semibold text-foreground"
    mark.textContent = text.slice(at, at + query.length)

    return [
      document.createTextNode(text.slice(0, at)),
      mark,
      document.createTextNode(text.slice(at + query.length))
    ]
  }

  clearResults() {
    if (this.hasResultsTarget) this.resultsTarget.replaceChildren()
  }

  // ui-command filtered the sidebar list on this same keystroke, before these
  // items existed. Run it again so it sees them, un-hides the empty state and
  // puts the active option on the first result.
  refilter() {
    this.command()?.filter()
  }

  command() {
    const element = this.element.querySelector("[data-controller~='ui-command']")
    if (!element) return null

    return this.application.getControllerForElementAndIdentifier(element, "ui-command")
  }

  // Fetched once per page load, on the first keystroke rather than eagerly: most
  // visits never open the palette, and the index is 55 KB gzipped.
  //
  // The *promise* is what gets cached, not its result. Typing "oklch" fires five
  // input events before the first fetch resolves; caching the result would make
  // the four that arrive mid-flight read the not-yet-filled slot as "the fetch
  // failed" and give up. A rejection resolves to null once, so a broken deploy
  // falls back to the title filter instead of refetching on every key.
  index() {
    this.pages ||= fetch(this.indexUrlValue)
      .then((response) => (response.ok ? response.json() : null))
      .catch(() => null) // offline, or the index was never built
    return this.pages
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
