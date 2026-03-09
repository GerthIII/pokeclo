import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["photo", "name", "description", "category", "slot", "spinner", "fields"]

  async photoChanged() {
    const file = this.photoTarget.files[0]
    if (!file) return

    this.showSpinner()

    const formData = new FormData()
    formData.append("photo", file)
    formData.append("authenticity_token", document.querySelector('meta[name="csrf-token"]').content)

    try {
      const response = await fetch("/items/analyze_photo", {
        method: "POST",
        body: formData
      })
      const data = await response.json()

      if (data.error) {
        console.error("Analysis error:", data.error)
        this.showFields()
      } else {
        await this.animateFields(data)
      }
    } catch (e) {
      console.error("Analysis failed", e)
      this.showFields()
    } finally {
      this.hideSpinner()
    }
  }

  async animateFields(data) {
    this.fieldsTarget.classList.remove("d-none")
    await this.typeInto(this.nameTarget, data.name)
    await this.typeInto(this.descriptionTarget, data.description)
    this.setSelect(this.categoryTarget, data.category)
    this.setSelect(this.slotTarget, data.slot)
  }

  typeInto(input, text) {
    if (!text) return Promise.resolve()
    input.value = ""
    input.focus()
    return new Promise(resolve => {
      let i = 0
      const interval = setInterval(() => {
        input.value += text[i]
        i++
        if (i >= text.length) {
          clearInterval(interval)
          resolve()
        }
      }, 18)
    })
  }

  setSelect(select, value) {
    const option = Array.from(select.options).find(o => o.value === value)
    if (option) select.value = value
  }

  showSpinner() {
    this.spinnerTarget.classList.remove("d-none")
    this.fieldsTarget.classList.add("d-none")
  }

  showFields() {
    this.fieldsTarget.classList.remove("d-none")
  }

  hideSpinner() {
    this.spinnerTarget.classList.add("d-none")
  }
}
