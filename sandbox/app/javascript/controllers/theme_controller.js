import { Controller } from "@hotwired/stimulus"

// Alterna a classe `.dark` no <html> e persiste a escolha em localStorage. O
// script anti-flash no <head> aplica o tema salvo antes da primeira pintura.
export default class extends Controller {
  toggle() {
    const isDark = document.documentElement.classList.toggle("dark")
    localStorage.setItem("theme", isDark ? "dark" : "light")
  }
}
