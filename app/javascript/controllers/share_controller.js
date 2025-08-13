import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static values = { url: String, title: String, text: String }
  static targets = ['toast']

  async share(event) {
    event.preventDefault();
    event.stopPropagation();

    const url = this.urlValue || window.location.href;
    const data = {
      title: this.titleValue || document.title,
      text: this.textValue || '',
      url
    };

    if (navigator.share) {
      try {
        await navigator.share(data);
      } catch (e) {

      }
      return;
    }

    try {
      if (navigator.clipboard?.writeText) {
        await navigator.clipboard.writeText(url);
      } else {
        const ta = document.createElement('textarea');
        ta.value = url;
        document.body.appendChild(ta);
        ta.select();
        document.execCommand('copy');
        document.body.removeChild(ta);
      }
      this.showToast();
    } catch (_err) {
      alert(this.textValue || 'Link copied');
    }
  }

  showToast() {
    const el = this.hasToastTarget ? this.toastTarget : null;
    if (!el) return;
    el.classList.add('show');
    setTimeout(() => el.classList.remove('show'), 1500);
  }
}
