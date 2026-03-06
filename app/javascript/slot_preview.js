document.addEventListener("change", function (event) {
  const input = event.target

  if (!input.classList.contains("item-radio")) return

  const slot = input.dataset.slot
  const image = input.dataset.image

  const slotButton = document.querySelector(`.slot-square[data-slot="${slot}"]`)

  if (!slotButton) return

  slotButton.style.backgroundImage = `url('${image}')`
  slotButton.style.backgroundSize = "cover"
  slotButton.style.backgroundPosition = "center"
  slotButton.style.color = "transparent"
})
