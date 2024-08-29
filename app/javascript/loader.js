let loaderTimeout;

function showLoader() {
    const loader = document.getElementById('loader');
    if (loader) {
        loader.style.display = 'flex';
    }
}

function hideLoader() {
    const loader = document.getElementById('loader');
    if (loader) {
        loader.style.display = 'none';
    }
    clearTimeout(loaderTimeout);
}

document.addEventListener('turbolinks:before-visit', () => {
    loaderTimeout = setTimeout(showLoader, 300); // Show loader after 300ms delay
});

document.addEventListener('turbolinks:load', hideLoader);
window.addEventListener('load', hideLoader);
