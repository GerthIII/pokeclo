function applyPreview(input) {
  if (!input.classList.contains("item-radio")) return
  if (!input.checked) return

  const slot = input.dataset.slot
  const image = input.dataset.image
  const slotButton = document.querySelector(`.slot-square[data-slot="${slot}"]`)
  if (!slotButton) return

  slotButton.style.backgroundImage = `url('${image}')`
  slotButton.style.backgroundSize = "cover"
  slotButton.style.backgroundPosition = "center"
  slotButton.style.color = "transparent"
}

function clearPreview(input) {
  if (!input.classList.contains("item-radio")) return

  const slot = input.dataset.slot
  const slotButton = document.querySelector(`.slot-square[data-slot="${slot}"]`)
  if (!slotButton) return

  slotButton.style.backgroundImage = ""
  slotButton.style.backgroundSize = ""
  slotButton.style.backgroundPosition = ""
  slotButton.style.color = ""
}

function radioFromTarget(target) {
  if (!target) return null

  if (target.classList?.contains("item-radio")) return target

  const label = target.closest?.("label")
  if (label?.htmlFor) {
    return document.getElementById(label.htmlFor)
  }

  return null
}

document.addEventListener("mousedown", (event) => {
  const input = radioFromTarget(event.target)
  if (!input) return
  input.dataset.wasChecked = input.checked ? "true" : "false"
})

document.addEventListener("keydown", (event) => {
  if (event.key !== " " && event.key !== "Enter") return
  const input = radioFromTarget(event.target)
  if (!input) return
  input.dataset.wasChecked = input.checked ? "true" : "false"
})

document.addEventListener("click", (event) => {
  const input = radioFromTarget(event.target)
  if (!input) return
  if (input.dataset.wasChecked !== "true") return

  event.preventDefault()
  input.checked = false
  clearPreview(input)
  input.dataset.wasChecked = "false"
})

document.addEventListener("change", (event) => {
  const input = radioFromTarget(event.target)
  if (!input) return
  applyPreview(input)
})

document.addEventListener("turbo:load", () => {
  document.querySelectorAll(".item-radio:checked").forEach((input) => {
    applyPreview(input)
  })
})

document.addEventListener("change", (event) => {
  const input = radioFromTarget(event.target)
  if (!input) return

  applyPreview(input)

  const offcanvasEl = input.closest(".offcanvas")
  if (!offcanvasEl) return

  const instance = bootstrap.Offcanvas.getOrCreateInstance(offcanvasEl)
  instance.hide()
})
