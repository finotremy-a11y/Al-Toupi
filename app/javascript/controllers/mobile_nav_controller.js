import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "panel"]

  connect() {
    this.open = false
  }

  toggle(event) {
    event.preventDefault()
    if (this.open) {
      this.close()
    } else {
      this.openMenu()
    }
  }

  close() {
    if (!this.open) return

    this.open = false
    this.panelTarget.classList.add("hidden")
    this.panelTarget.setAttribute("aria-hidden", "true")
    this.buttonTarget.setAttribute("aria-expanded", "false")
    this.buttonTarget.setAttribute("aria-label", "Ouvrir le menu")
    this.buttonTarget.focus()
  }

  closeOnEscape() {
    this.close()
  }

  closeOnOutsideClick(event) {
    if (!this.open) return
    if (this.element.contains(event.target)) return

    this.close()
  }

  openMenu() {
    this.open = true
    this.panelTarget.classList.remove("hidden")
    this.panelTarget.setAttribute("aria-hidden", "false")
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.buttonTarget.setAttribute("aria-label", "Fermer le menu")

    const firstLink = this.panelTarget.querySelector("a")
    if (firstLink) firstLink.focus()
  }
}
