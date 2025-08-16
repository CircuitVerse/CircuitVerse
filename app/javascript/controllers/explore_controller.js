import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static get targets() {
    return ["tab", "section"]
  }

  connect() {
    const url = new URL(window.location.href)

    let key =
      url.searchParams.get("section") ||
      (url.hash ? url.hash.replace("#", "") : "cotw")

    if (!this._hasSection(key)) key = "cotw"

    this._show(key, { canonicalize: true })
  }

  switch(event) {
    const key = event.currentTarget.dataset.key
    if (!this._hasSection(key)) return
    this._show(key, { updateUrl: true })
  }

  _show(key, { canonicalize = false, updateUrl = false } = {}) {
    this.tabTargets.forEach((el) => {
      const active = el.dataset.key === key
      el.classList.toggle("active", active)
      el.setAttribute("aria-selected", active ? "true" : "false")
    })

    this.sectionTargets.forEach((el) => {
      const show = el.dataset.key === key
      el.classList.toggle("d-none", !show)
      el.toggleAttribute("hidden", !show)
    })

    if (canonicalize || updateUrl) {
      const url = new URL(window.location.href)
      url.hash = `#${key}`
      url.searchParams.set("section", key)

      if (key !== "recent") {
        url.searchParams.delete("before_id")
        url.searchParams.delete("after_id")
      }

      history.replaceState({}, "", url)
    }
  }

  _hasSection(key) {
    return this.sectionTargets.some((el) => el.dataset.key === key)
  }
}
