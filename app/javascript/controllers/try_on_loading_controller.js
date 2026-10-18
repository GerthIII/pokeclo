import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["actions", "loading", "button"]

  start() {
    this.actionsTarget.classList.add("d-none")
    this.loadingTarget.classList.remove("d-none")
    this.buttonTarget.setAttribute("aria-busy", "true")
  }
}
