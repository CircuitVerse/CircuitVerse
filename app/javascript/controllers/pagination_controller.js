import { Controller } from 'stimulus';
import { csrfToken } from '@rails/ujs';

export default class extends Controller {
  static targets = ['pagination']; // Declaring targets array for Stimulus

  connect() {
    console.log('Pagination controller connected!');
  }
  fetchPage(event) {
    event.preventDefault(); // Prevent default link behavior

    const url = event.target.href; // Get the URL from the clicked link

    fetch(url, {
      method: 'GET',
      headers: {
        'X-CSRF-Token': csrfToken(), // Include CSRF token for Rails
      },
    })
      .then((response) => response.text()) // Parse response as text (HTML)
      .then((html) => {
        document.querySelector('.pagination-cont').innerHTML = html; // Replace content with new HTML
      })
      .catch((error) => {
        console.error('Error fetching page:', error); // Log errors for debugging
      });
  }
}
