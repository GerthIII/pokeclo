import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { newItemUrl: String }

  async photoSelected(event) {
    const file = event.target.files[0]
    if (!file) return
    await this.storePendingPhoto(file)
    window.location.href = this.newItemUrlValue + "?from_camera=true"
  }

  async storePendingPhoto(file) {
    const buffer = await file.arrayBuffer()
    const record = { buffer, name: file.name, type: file.type }
    return new Promise((resolve, reject) => {
      const request = indexedDB.open("pokeclo", 1)
      request.onupgradeneeded = (e) => {
        e.target.result.createObjectStore("pending_photos")
      }
      request.onsuccess = (e) => {
        const db = e.target.result
        const tx = db.transaction("pending_photos", "readwrite")
        tx.objectStore("pending_photos").put(record, "latest")
        tx.oncomplete = resolve
        tx.onerror = reject
      }
      request.onerror = reject
    })
  }
}
