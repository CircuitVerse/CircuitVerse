import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['tab', 'section'];

  connect() {
    const keyFromHash = window.location.hash?.replace('#', '');
    if (keyFromHash) this.activate(keyFromHash);
  }

  switch(event) {
    const key = event.currentTarget.dataset.key;
    this.activate(key);
  }

  activate(key) {
    this.tabTargets.forEach((el) => {
      const active = el.dataset.key === key;
      el.classList.toggle('active', active);
      el.setAttribute('aria-selected', active ? 'true' : 'false');
    });

    this.sectionTargets.forEach((el) => {
      el.classList.toggle('d-none', el.dataset.key !== key);
    });

    if (history.replaceState) history.replaceState(null, '', `#${key}`);
  }
}
