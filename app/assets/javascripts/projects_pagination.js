// app/assets/javascripts/projects_pagination.js

document.addEventListener('DOMContentLoaded', () => {
    const loadMoreButton = document.getElementById('load-more-button');
    const projectsContainer = document.getElementById('projects-container');

    if (loadMoreButton) {
        loadMoreButton.addEventListener('click', () => {
            const { nextCursor } = loadMoreButton.dataset;

            // Disable the button to prevent multiple clicks
            loadMoreButton.disabled = true;
            loadMoreButton.textContent = I18n.t('circuitverse.index.loading'); // Updated translation key

            fetch(`/?cursor=${nextCursor}`, {
                headers: {
                    Accept: 'application/json',
                    'X-Requested-With': 'XMLHttpRequest', // Helps Rails recognize AJAX requests
                },
            })
                .then((response) => {
                    if (!response.ok) {
                        throw new Error(`HTTP error! Status: ${response.status}`);
                    }
                    return response.json();
                })
                .then((data) => {
                    // eslint-disable-next-line camelcase
                    const { projects, next_cursor } = data;

                    // Append new projects to the container
                    projects.forEach((project) => {
                        const projectElement = document.createElement('div');
                        projectElement.className = 'col-12 col-sm-12 col-md-6 col-lg-4';
                        projectElement.innerHTML = `
                    <div class="card circuit-card">
                      <img src="${project.image_preview}" alt="${project.name}" class="card-img-top circuit-card-image">
                      <div class="card-footer circuit-card-footer">
                        <div class="circuit-card-name">
                          <p>${project.name}</p>
                          <span class="tooltiptext">${project.name}</span>
                        </div>
                        <a class="btn primary-button circuit-card-primary-button" target="_blank" href="/users/${project.author_id}/projects/${project.slug}">${I18n.t('view')}</a>
                      </div>
                    </div>
                  `;
                        projectsContainer.appendChild(projectElement);
                    });

                    // Update or hide the "Load More" button
                    // eslint-disable-next-line camelcase
                    if (next_cursor) {
                        // eslint-disable-next-line camelcase
                        loadMoreButton.dataset.nextCursor = next_cursor;
                        loadMoreButton.disabled = false;
                        loadMoreButton.textContent = I18n.t('circuitverse.index.load_more'); // Updated translation key
                    } else {
                        loadMoreButton.remove();
                    }
                })
                .catch((error) => {
                    // eslint-disable-next-line no-console
                    console.error('Error loading more projects:', error);
                    loadMoreButton.disabled = false;
                    loadMoreButton.textContent = I18n.t('circuitverse.index.load_more'); // Updated translation key
                });
        });
    }
});
