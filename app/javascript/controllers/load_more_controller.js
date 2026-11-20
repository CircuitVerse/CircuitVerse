import { Controller } from 'stimulus';

export default class extends Controller {
    static targets = ['list', 'button'];

    static values = {
        url: String,
        page: { type: Number, default: 1 },
        params: Object,
    };

    async load(event) {
        event.preventDefault();
        event.stopPropagation();

        if (this.loading) return;
        this.loading = true;

        const button = this.buttonTarget;
        const originalText = button.textContent;

        button.textContent = '...';
        button.setAttribute('aria-disabled', 'true');

        try {
            const url = new URL(this.urlValue, window.location.origin);
            url.searchParams.set('page', this.pageValue);
            Object.entries(this.paramsValue).forEach(([key, value]) => {
                url.searchParams.set(key, value);
            });

            const response = await fetch(url, { headers: { Accept: 'application/json' } });
            if (!response.ok) throw new Error('Request failed');

            const data = await response.json();
            this.listTarget.insertAdjacentHTML('beforeend', data.html);

            if (data.has_more) {
                this.pageValue += 1;
                button.textContent = originalText;
                button.removeAttribute('aria-disabled');
            } else {
                button.remove();
            }
        } catch {
            button.textContent = originalText;
            button.removeAttribute('aria-disabled');
        } finally {
            this.loading = false;
        }
    }
}
