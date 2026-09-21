import { Controller } from "@hotwired/stimulus"

// Adds and removes rows in a `fields_for` collection. New rows are cloned from a
// <template> whose field names contain the NEW_RECORD placeholder.
export default class extends Controller {
  static targets = ["list", "template"]

  add(event) {
    event.preventDefault()

    const index = Date.now() + this.listTarget.children.length
    const html = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, index)

    this.listTarget.insertAdjacentHTML("beforeend", html)
    this.listTarget.lastElementChild.querySelector("input[type=text]")?.focus()
  }

  remove(event) {
    event.preventDefault()

    const row = event.target.closest("[data-nested-form-target='row']")
    if (!row) return

    if (row.querySelector("input[name*='[id]']")) {
      // Persisted record: flag it for deletion so the server destroys it on save.
      row.querySelector("input[name*='_destroy']").value = "1"
      row.hidden = true
    } else {
      row.remove()
    }
  }
}
