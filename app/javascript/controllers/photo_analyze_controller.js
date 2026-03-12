import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["photo", "name", "description", "category", "slot", "spinner", "fields", "submitButton", "preview", "previewImage"]

  async connect() {
    if (new URLSearchParams(window.location.search).get("from_camera")) {
      const file = await this.getPendingPhoto()
      if (file) {
        this.injectFileIntoInput(file)
        await this.analyzeFile(file)
        this.clearPendingPhoto()
      }
    }
  }

  disconnect() {
    if (this.previewObjectUrl) {
      URL.revokeObjectURL(this.previewObjectUrl)
      this.previewObjectUrl = null
    }
  }

  async photoChanged() {
    const file = this.photoTarget.files[0]
    if (!file) return
    await this.analyzeFile(file)
  }

  async analyzeFile(file) {
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
      this.showPreview(file)
    }
  }

  injectFileIntoInput(file) {
    try {
      const dt = new DataTransfer()
      dt.items.add(file)
      this.photoTarget.files = dt.files
    } catch (e) {
      console.warn("Could not inject file into input:", e)
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
    this.submitButtonTarget.classList.add("d-none")
  }

  showFields() {
    this.fieldsTarget.classList.remove("d-none")
  }

  hideSpinner() {
    this.spinnerTarget.classList.add("d-none")
    this.submitButtonTarget.classList.remove("d-none")
  }

  showPreview(file) {
    if (!file || !this.hasPreviewTarget || !this.hasPreviewImageTarget) return

    if (this.previewObjectUrl) URL.revokeObjectURL(this.previewObjectUrl)
    this.previewObjectUrl = URL.createObjectURL(file)
    this.previewImageTarget.src = this.previewObjectUrl
    this.previewTarget.classList.remove("d-none")
  }

  getPendingPhoto() {
    return new Promise((resolve) => {
      const request = indexedDB.open("pokeclo", 1)
      request.onupgradeneeded = (e) => {
        e.target.result.createObjectStore("pending_photos")
      }
      request.onsuccess = (e) => {
        const db = e.target.result
        const tx = db.transaction("pending_photos", "readonly")
        const req = tx.objectStore("pending_photos").get("latest")
        req.onsuccess = () => {
          const record = req.result
          if (!record) return resolve(null)
          const file = record instanceof File
            ? record
            : new File([record.buffer], record.name, { type: record.type })
          resolve(file)
        }
        req.onerror = () => resolve(null)
      }
      request.onerror = () => resolve(null)
    })
  }

  clearPendingPhoto() {
    const request = indexedDB.open("pokeclo", 1)
    request.onsuccess = (e) => {
      const db = e.target.result
      const tx = db.transaction("pending_photos", "readwrite")
      tx.objectStore("pending_photos").delete("latest")
    }
  }
}
