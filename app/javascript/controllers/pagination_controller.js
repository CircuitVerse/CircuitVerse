import { Controller } from 'stimulus';
import Rails from '@rails/ujs';

export default class extends Controller {
    fetchPage(event) {
        event.preventDefault();
        const url = event.target.href;

        fetch(url, {
            method: 'GET',
            headers: {
                'X-CSRF-Token': Rails.csrfToken(),
            },
        })
            .then((response) => response.text())
            .then((html) => {
                this.paginationTarget.innerHTML = html;
            })
            .catch((error) => {
                // eslint-disable-next-line no-console
                console.error('Error fetching page:', error);
            });
    }
}
