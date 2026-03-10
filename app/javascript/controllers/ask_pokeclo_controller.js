import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { autoAsk: Boolean }

  static targets = ["description", "content", "form","outfitForm"]

  connect() {
    if (this.autoAskValue) {
      this.submitMessage()
    }
  }

  ask() {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = "ask_for_advice"
    input.value = "true"
    this.outfitFormTarget.appendChild(input)
    this.outfitFormTarget.requestSubmit()
  }

  submitMessage() {
    if (!this.hasFormTarget || !this.hasContentTarget) return
    const description = this.hasDescriptionTarget ? this.descriptionTarget.value : ""
    this.contentTarget.value = description || "Please suggest items for the missing slots in this outfit."
    this.formTarget.requestSubmit()
  }
}
