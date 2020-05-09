if (navigator.serviceWorker) {
    navigator.serviceWorker.register('/serviceworker.js', { scope: '/' });
}
