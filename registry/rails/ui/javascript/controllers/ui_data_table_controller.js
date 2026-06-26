import { Controller } from "@hotwired/stimulus"

// The engine behind the Data Table: client-side filtering, sorting,
// pagination, row selection, and column visibility over a server-rendered
// <table>. Each body cell carries data-column (and data-sort-value); rows are
// shown/hidden rather than re-rendered, so it works without any data library.
export default class extends Controller {
  static targets = [
    "filter",
    "row",
    "selectAll",
    "rowCheckbox",
    "selectionInfo",
    "previous",
    "next",
    "pageInfo",
    "columnHeader",
    "emptyState"
  ]
  static values = {
    pageSize: { type: Number, default: 10 },
    page: { type: Number, default: 0 },
    filterKey: { type: String, default: "" }
  }

  connect() {
    this.filterText = ""
    this.sortKey = null
    this.sortDir = "asc"
    this.render()
  }

  filter(event) {
    this.filterText = event.target.value.trim().toLowerCase()
    this.pageValue = 0
    this.render()
  }

  sort(event) {
    const key = event.currentTarget.dataset.column
    if (this.sortKey === key) {
      this.sortDir = this.sortDir === "asc" ? "desc" : "asc"
    } else {
      this.sortKey = key
      this.sortDir = "asc"
    }
    this.render()
  }

  toggleColumn(event) {
    const item = event.currentTarget
    const key = item.dataset.column
    const hide = item.getAttribute("aria-checked") === "true"
    item.setAttribute("aria-checked", hide ? "false" : "true")
    this.element
      .querySelectorAll(`th[data-column="${key}"], td[data-column="${key}"]`)
      .forEach((cell) => { cell.hidden = hide })
  }

  toggleAll(event) {
    const checked = event.target.checked
    const rows = this.filteredRows()
    rows.forEach((row) => {
      const box = row.querySelector("[data-ui-data-table-target='rowCheckbox']")
      if (box) box.checked = checked
      this.setSelected(row, checked)
    })
    this.updateSelectAll(rows)
    this.updateSelectionInfo()
  }

  toggleRow(event) {
    const row = event.target.closest("[data-ui-data-table-target='row']")
    if (!row) return
    this.setSelected(row, event.target.checked)
    this.updateSelectAll()
    this.updateSelectionInfo()
  }

  previousPage() {
    if (this.pageValue > 0) {
      this.pageValue -= 1
      this.render()
    }
  }

  nextPage() {
    if (this.pageValue < this.pageCount() - 1) {
      this.pageValue += 1
      this.render()
    }
  }

  // --- internals -----------------------------------------------------------

  render() {
    const rows = this.filteredRows()

    if (this.sortKey) {
      rows.sort((a, b) => this.compareRows(a, b))
      const body = this.hasRowTarget ? this.rowTargets[0].parentElement : null
      if (body) rows.forEach((row) => body.appendChild(row))
    }

    const size = this.pageSizeValue
    const pageCount = Math.max(1, Math.ceil(rows.length / size))
    this.pageValue = Math.min(Math.max(this.pageValue, 0), pageCount - 1)

    const start = this.pageValue * size
    const visible = new Set(rows.slice(start, start + size))
    this.rowTargets.forEach((row) => { row.hidden = !visible.has(row) })

    if (this.hasEmptyStateTarget) this.emptyStateTarget.hidden = rows.length !== 0
    if (this.hasPreviousTarget) this.previousTarget.disabled = this.pageValue === 0
    if (this.hasNextTarget) this.nextTarget.disabled = this.pageValue >= pageCount - 1
    if (this.hasPageInfoTarget) {
      this.pageInfoTarget.textContent =
        rows.length === 0 ? "0 de 0" : `Página ${this.pageValue + 1} de ${pageCount}`
    }

    this.updateSortIndicators()
    this.updateSelectAll(rows)
    this.updateSelectionInfo()
  }

  pageCount() {
    return Math.max(1, Math.ceil(this.filteredRows().length / this.pageSizeValue))
  }

  filteredRows() {
    return this.rowTargets.filter((row) => this.matchesFilter(row))
  }

  matchesFilter(row) {
    const key = this.filterKeyValue
    if (!key || !this.filterText) return true
    const cell = row.querySelector(`[data-column="${key}"]`)
    return cell ? cell.textContent.trim().toLowerCase().includes(this.filterText) : true
  }

  compareRows(a, b) {
    const va = this.sortValue(a)
    const vb = this.sortValue(b)
    const na = Number(va)
    const nb = Number(vb)
    let result
    if (va !== "" && vb !== "" && !Number.isNaN(na) && !Number.isNaN(nb)) {
      result = na - nb
    } else {
      result = va.localeCompare(vb, undefined, { numeric: true })
    }
    return this.sortDir === "asc" ? result : -result
  }

  sortValue(row) {
    const cell = row.querySelector(`[data-column="${this.sortKey}"]`)
    if (!cell) return ""
    return (cell.dataset.sortValue ?? cell.textContent).trim()
  }

  setSelected(row, selected) {
    if (selected) row.dataset.state = "selected"
    else delete row.dataset.state
  }

  updateSortIndicators() {
    this.columnHeaderTargets.forEach((button) => {
      const active = button.dataset.column === this.sortKey
      const th = button.closest("th")
      if (th) {
        th.setAttribute(
          "aria-sort",
          active ? (this.sortDir === "asc" ? "ascending" : "descending") : "none"
        )
      }
      button.dataset.state = active ? this.sortDir : ""
    })
  }

  updateSelectAll(rows = this.filteredRows()) {
    if (!this.hasSelectAllTarget) return
    const selected = rows.filter((row) => row.dataset.state === "selected").length
    this.selectAllTarget.checked = rows.length > 0 && selected === rows.length
    this.selectAllTarget.indeterminate = selected > 0 && selected < rows.length
  }

  updateSelectionInfo() {
    if (!this.hasSelectionInfoTarget) return
    const total = this.rowTargets.length
    const selected = this.rowTargets.filter((row) => row.dataset.state === "selected").length
    this.selectionInfoTarget.textContent = `${selected} de ${total} linha(s) selecionada(s).`
  }
}
