import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["viewport", "scrollbar", "thumb", "corner"]

  connect() {
    this.update = this.update.bind(this)
    this.endDrag = this.endDrag.bind(this)
    this.dragThumb = this.dragThumb.bind(this)
    this.scheduleUpdate()
    this.observeSizeChanges()
    this.observeContentChanges()
  }

  disconnect() {
    if (this.resizeObserver) this.resizeObserver.disconnect()
    if (this.mutationObserver) this.mutationObserver.disconnect()
    if (this.scrollTimeout) window.clearTimeout(this.scrollTimeout)
    if (this.frame) window.cancelAnimationFrame(this.frame)
    this.endDrag()
  }

  scroll() {
    this.element.dataset.scrolling = "true"
    if (this.scrollTimeout) window.clearTimeout(this.scrollTimeout)
    this.scrollTimeout = window.setTimeout(() => {
      delete this.element.dataset.scrolling
    }, 150)
    this.scheduleUpdate()
  }

  hoverStart() {
    this.element.dataset.hovering = "true"
  }

  hoverEnd() {
    delete this.element.dataset.hovering
  }

  trackPointerDown(event) {
    const scrollbar = event.currentTarget
    const thumb = this.thumbFor(scrollbar)
    if (!this.hasViewportTarget || !thumb || event.target === thumb) return

    event.preventDefault()

    const orientation = this.orientationFor(scrollbar)
    const rect = scrollbar.getBoundingClientRect()
    const pointer = orientation === "vertical" ? event.clientY - rect.top : event.clientX - rect.left
    const trackSize = orientation === "vertical" ? rect.height : rect.width
    const viewportSize = orientation === "vertical" ? this.viewportTarget.clientHeight : this.viewportTarget.clientWidth
    const scrollSize = orientation === "vertical" ? this.viewportTarget.scrollHeight : this.viewportTarget.scrollWidth
    const maxScroll = Math.max(scrollSize - viewportSize, 0)
    const nextScroll = (pointer / Math.max(trackSize, 1)) * maxScroll

    if (orientation === "vertical") {
      this.viewportTarget.scrollTop = nextScroll
    } else {
      this.viewportTarget.scrollLeft = nextScroll
    }

    this.scroll()
  }

  thumbPointerDown(event) {
    if (!this.hasViewportTarget) return

    const scrollbar = event.currentTarget.closest("[data-slot='scroll-area-scrollbar']")
    if (!scrollbar) return

    event.preventDefault()

    const orientation = this.orientationFor(scrollbar)
    const rect = scrollbar.getBoundingClientRect()
    const trackSize = orientation === "vertical" ? rect.height : rect.width
    const viewportSize = orientation === "vertical" ? this.viewportTarget.clientHeight : this.viewportTarget.clientWidth
    const scrollSize = orientation === "vertical" ? this.viewportTarget.scrollHeight : this.viewportTarget.scrollWidth
    const maxScroll = Math.max(scrollSize - viewportSize, 0)
    const thumbSize = orientation === "vertical" ? event.currentTarget.offsetHeight : event.currentTarget.offsetWidth
    const maxThumbOffset = Math.max(trackSize - thumbSize, 1)

    this.dragState = {
      orientation,
      startPointer: orientation === "vertical" ? event.clientY : event.clientX,
      startScroll: orientation === "vertical" ? this.viewportTarget.scrollTop : this.viewportTarget.scrollLeft,
      ratio: maxScroll / maxThumbOffset,
    }

    event.currentTarget.setPointerCapture?.(event.pointerId)
    window.addEventListener("pointermove", this.dragThumb)
    window.addEventListener("pointerup", this.endDrag, { once: true })
  }

  dragThumb(event) {
    if (!this.dragState || !this.hasViewportTarget) return

    const pointer = this.dragState.orientation === "vertical" ? event.clientY : event.clientX
    const delta = pointer - this.dragState.startPointer
    const nextScroll = this.dragState.startScroll + delta * this.dragState.ratio

    if (this.dragState.orientation === "vertical") {
      this.viewportTarget.scrollTop = nextScroll
    } else {
      this.viewportTarget.scrollLeft = nextScroll
    }

    this.scroll()
  }

  endDrag() {
    this.dragState = null
    window.removeEventListener("pointermove", this.dragThumb)
  }

  scheduleUpdate() {
    if (this.frame) return

    this.frame = window.requestAnimationFrame(() => {
      this.frame = null
      this.update()
    })
  }

  update() {
    if (!this.hasViewportTarget) return

    const viewport = this.viewportTarget
    const hasOverflowY = viewport.scrollHeight > viewport.clientHeight + 1
    const hasOverflowX = viewport.scrollWidth > viewport.clientWidth + 1

    this.setDataValue("hasOverflowY", hasOverflowY)
    this.setDataValue("hasOverflowX", hasOverflowX)
    this.setDataValue("overflowYStart", viewport.scrollTop <= 1)
    this.setDataValue("overflowYEnd", !hasOverflowY || viewport.scrollTop + viewport.clientHeight >= viewport.scrollHeight - 1)
    this.setDataValue("overflowXStart", viewport.scrollLeft <= 1)
    this.setDataValue("overflowXEnd", !hasOverflowX || viewport.scrollLeft + viewport.clientWidth >= viewport.scrollWidth - 1)

    this.scrollbarTargets.forEach((scrollbar) => {
      const orientation = this.orientationFor(scrollbar)
      const hasOverflow = orientation === "vertical" ? hasOverflowY : hasOverflowX
      scrollbar.hidden = !hasOverflow
      if (hasOverflow) this.updateThumb(scrollbar, orientation)
    })

    if (this.hasCornerTarget) this.cornerTarget.hidden = !(hasOverflowX && hasOverflowY)
  }

  updateThumb(scrollbar, orientation) {
    const thumb = this.thumbFor(scrollbar)
    if (!thumb) return

    const viewport = this.viewportTarget
    const trackSize = orientation === "vertical" ? scrollbar.clientHeight : scrollbar.clientWidth
    const viewportSize = orientation === "vertical" ? viewport.clientHeight : viewport.clientWidth
    const scrollSize = orientation === "vertical" ? viewport.scrollHeight : viewport.scrollWidth
    const scrollOffset = orientation === "vertical" ? viewport.scrollTop : viewport.scrollLeft
    const thumbSize = Math.max(18, Math.round((viewportSize / scrollSize) * trackSize))
    const maxScroll = Math.max(scrollSize - viewportSize, 1)
    const maxThumbOffset = Math.max(trackSize - thumbSize, 0)
    const thumbOffset = Math.round((scrollOffset / maxScroll) * maxThumbOffset)

    if (orientation === "vertical") {
      thumb.style.height = `${thumbSize}px`
      thumb.style.width = ""
      thumb.style.transform = `translate3d(0, ${thumbOffset}px, 0)`
    } else {
      thumb.style.width = `${thumbSize}px`
      thumb.style.height = ""
      thumb.style.transform = `translate3d(${thumbOffset}px, 0, 0)`
    }
  }

  observeSizeChanges() {
    if (!window.ResizeObserver || !this.hasViewportTarget) return

    this.resizeObserver = new ResizeObserver(this.update)
    this.resizeObserver.observe(this.viewportTarget)
    if (this.viewportTarget.firstElementChild) this.resizeObserver.observe(this.viewportTarget.firstElementChild)
  }

  observeContentChanges() {
    if (!window.MutationObserver || !this.hasViewportTarget) return

    this.mutationObserver = new MutationObserver(() => this.scheduleUpdate())
    this.mutationObserver.observe(this.viewportTarget, { childList: true, subtree: true, characterData: true })
  }

  thumbFor(scrollbar) {
    return scrollbar.querySelector("[data-slot='scroll-area-thumb']")
  }

  orientationFor(scrollbar) {
    return scrollbar.dataset.orientation || "vertical"
  }

  setDataValue(name, value) {
    this.element.dataset[name] = value ? "true" : "false"
  }
}
