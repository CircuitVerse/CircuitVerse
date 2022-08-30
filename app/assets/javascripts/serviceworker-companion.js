if (navigator.serviceWorker) {
    navigator.serviceWorker.register('/serviceworker.js.erb', { scope: '/' });
    console.log('Helllo');
}
