import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static get targets() {
        return ['tab', 'section'];
    }

    connect() {
        const url = new URL(window.location.href);
        let key = url.searchParams.get('section') || (url.hash ? url.hash.replace('#', '') : 'cotw');
        if (!this.hasSection(key)) key = 'cotw';
        this.showSection(key, { canonicalize: true });
    }

    switch(event) {
        const { key } = event.currentTarget.dataset;
        if (!this.hasSection(key)) return;
        this.showSection(key, { updateUrl: true });
    }

    showSection(key, { canonicalize = false, updateUrl = false } = {}) {
        this.tabTargets.forEach((el) => {
            const active = el.dataset.key === key;
            el.classList.toggle('active', active);
            el.setAttribute('aria-selected', active ? 'true' : 'false');
        });

        this.sectionTargets.forEach((el) => {
            const show = el.dataset.key === key;
            el.classList.toggle('d-none', !show);
            el.toggleAttribute('hidden', !show);
        });

        if (canonicalize || updateUrl) {
            const next = new URL(window.location.href);
            next.hash = `#${key}`;
            next.searchParams.set('section', key);

            if (key !== 'recent') {
                next.searchParams.delete('before_id');
                next.searchParams.delete('after_id');
            }

            window.history.replaceState({}, '', next);
        }
    }

    hasSection(key) {
        return this.sectionTargets.some((el) => el.dataset.key === key);
    }
}
