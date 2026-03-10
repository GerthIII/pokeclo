import { Controller } from '@hotwired/stimulus'

export default class extends Controller {

  static targets = ["select", "card"]

  connect() {
    console.log("Hello from our first Stimulus controller");
  }

  filter(){
    const select = this.selectTarget.value
    console.log(select);

    this.cardTargets.forEach((card) => {
    const currentFilter = select === "" || select === card.dataset.slot
    if (currentFilter) {
      card.classList.remove("d-none")
    } else {
      card.classList.add("d-none")
    }
  })
  }
}
