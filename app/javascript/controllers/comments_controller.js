// Comment thread interactions (project page). Uses fetch + HTML fragments;
// no jQuery. Replaces the commontator remote .js.erb views.
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['list', 'form', 'formErrors', 'body', 'editForm'];

  static values = { threadId: Number };

  get headers() {
    return {
      Accept: 'text/html',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
    };
  }

  async create(event) {
    event.preventDefault();
    const form = this.formTarget;
    const response = await fetch(
      `/comment_threads/${this.threadIdValue}/comments`,
      {
        method: 'POST',
        headers: this.headers,
        body: new FormData(form),
      },
    );

    if (response.ok) {
      this.listTarget.insertAdjacentHTML('beforeend', await response.text());
      form.reset();
      this.formErrorsTarget.innerHTML = '';
    } else if (response.status === 422) {
      this.formErrorsTarget.innerHTML = await response.text();
    }
  }

  showEdit(event) {
    const article = event.currentTarget.closest('article');
    const body = article.querySelector('[data-comments-target="body"]');
    const form = article.querySelector('[data-comments-target="editForm"]');
    if (!form) return;
    form.classList.toggle('d-none');
    body.classList.toggle('d-none');
  }

  async update(event) {
    event.preventDefault();
    const form = event.target;
    const article = form.closest('article');
    const response = await fetch(`/comments/${article.dataset.commentId}`, {
      method: 'PATCH',
      headers: this.headers,
      body: new FormData(form),
    });

    if (response.ok) {
      article.outerHTML = await response.text();
    } else if (response.status === 422) {
      form.insertAdjacentHTML('beforebegin', await response.text());
    }
  }

  async destroy(event) {
    const article = event.currentTarget.closest('article');
    // eslint-disable-next-line no-alert
    if (!window.confirm('Delete this comment?')) return;
    const response = await fetch(`/comments/${article.dataset.commentId}`, {
      method: 'DELETE',
      headers: this.headers,
    });

    if (response.ok) {
      article.outerHTML = await response.text();
    }
  }
}
