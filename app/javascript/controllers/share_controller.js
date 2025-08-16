import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static get values() {
    return { url: String, title: String, text: String }
  }

  static get targets() {
    return ["toast"]
  }

  async share(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }

    const url = this.hasUrlValue ? this.urlValue : window.location.href
    const title = this.hasTitleValue ? this.titleValue : document.title
    const text = this.hasTextValue ? this.textValue : ""

    try {
      if (navigator.share) {
        await navigator.share({ title, text, url })
        this._flashToast()
        return
      }

      if (navigator.clipboard && navigator.clipboard.writeText) {
        await navigator.clipboard.writeText(url)
        this._flashToast()
        return
      }

      this._copyViaInput(url)
      this._flashToast()
    } catch (_) {
      try {
        this._copyViaInput(url)
        this._flashToast()
      } catch (__){ /* noop */ }
    }
  }

  _copyViaInput(value) {
    const input = document.createElement("input")
    input.value = value
    document.body.appendChild(input)
    input.select()
    document.execCommand("copy")
    document.body.removeChild(input)
  }

  _flashToast() {
    if (!this.hasToastTarget) return
    const toast = this.toastTarget
    toast.classList.add("show")
    setTimeout(() => toast.classList.remove("show"), 1500)
  }
}
