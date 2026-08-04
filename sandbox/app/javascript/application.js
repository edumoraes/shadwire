// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Turbo caches the outgoing page before it navigates. A snapshot taken while a
// <dialog> is open restores it as a *non-modal* dialog: it renders over the
// restored page, ignores Escape, and the ui-dialog controller refuses to reopen
// what it believes is already open. A page reached with the Back button could
// come back carrying a stuck overlay. Close them before the snapshot is taken.
document.addEventListener("turbo:before-cache", () => {
  document.querySelectorAll("dialog[open]").forEach((dialog) => dialog.close())
})
