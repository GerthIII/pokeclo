import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit-outfit"
export default class extends Controller {
  static targets = ["field"]

  show() {
    this.fieldTarget.classList.remove("d-none");
  }
}
