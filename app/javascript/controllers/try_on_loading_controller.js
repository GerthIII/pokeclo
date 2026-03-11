import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["actions", "loading", "button"]

  start(event) {
    event.preventDefault()

    this.actionsTarget.classList.add("d-none")
    this.loadingTarget.classList.remove("d-none")
    this.buttonTarget.setAttribute("aria-busy", "true")

    const url = this.buttonTarget.getAttribute("href")
    if (!url) return

    // Let the loading state paint before starting the Turbo visit.
    requestAnimationFrame(() => Turbo.visit(url))
  }
}
