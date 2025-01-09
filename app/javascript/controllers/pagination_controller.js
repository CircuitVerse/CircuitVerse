import { Controller } from 'stimulus';
import { csrfToken } from '@rails/ujs';

export default class extends Controller {
  // Declare targets inside the constructor instead of using static
  targets = ['pagination'];

  connect() {
    console.log('Pagination controller connected!');
  }

  // Method to handle pagination click events
  fetchPage(event) {
    event.preventDefault();
    
    // Get the URL from the clicked pagination link
    const url = event.target.href;
    
    // Fetch the new page content using the URL
    fetch(url, {
      method: 'GET',
      headers: {
        'X-CSRF-Token': csrfToken()  // Add CSRF token to the request
      }
    })
    .then(response => response.text())  // Get the new HTML response
    .then(html => {
      // Replace the pagination content with the new HTML
      document.querySelector('.pagination-cont').innerHTML = html;
    })
    .catch(error => console.log('Error fetching page:', error));
  }
}
