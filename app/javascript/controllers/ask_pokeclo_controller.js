import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { autoAsk: Boolean }

  static targets = ["description", "content", "form", "outfitForm", "advice", "spinner", "submitButton", "builderPanel", "builderLoading"]

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

  showAdvice(event) {
    event.preventDefault()
    event.stopPropagation()

    const adviceElement = this.hasAdviceTarget ? this.adviceTarget : document.getElementById("pokeclo-advice")
    if (!adviceElement) return

    adviceElement.classList.remove("d-none")
    setTimeout(() => adviceElement.scrollIntoView({ behavior: "smooth", block: "start" }), 50)
  }

  submitMessage() {
    if (!this.hasFormTarget || !this.hasContentTarget) return
    const description = this.hasDescriptionTarget ? this.descriptionTarget.value : ""
    this.contentTarget.value = description || "Create an outift for this item I chose"
    this.showSpinner()
    this.formTarget.requestSubmit()
  }

  handleSubmit() {
    this.showSpinner()
  }

  showSpinner() {
    if (this.hasSpinnerTarget) this.spinnerTarget.classList.remove("d-none")
    if (this.hasSubmitButtonTarget) this.submitButtonTarget.disabled = true
    if (this.hasBuilderPanelTarget) this.builderPanelTarget.classList.add("d-none")
    if (this.hasBuilderLoadingTarget) this.builderLoadingTarget.classList.remove("d-none")
  }

  hideSpinner() {
    if (this.hasSpinnerTarget) this.spinnerTarget.classList.add("d-none")
    if (this.hasSubmitButtonTarget) this.submitButtonTarget.disabled = false
    if (this.hasBuilderPanelTarget) this.builderPanelTarget.classList.remove("d-none")
    if (this.hasBuilderLoadingTarget) this.builderLoadingTarget.classList.add("d-none")
  }
}
