/*
Basic Intro: What this code does
This code is responsible for showing and hiding a spinner icon on pagination buttons in recent circuit section in CircuitVerse Home Page.
when an AJAX request is in progress. It listens for the `ajax:beforeSend` and `ajax:complete` events
*/

document.addEventListener('DOMContentLoaded', () => {
    const handleSpinner = (target, show) => {
        const textSpan = target.querySelector('.button-text');
        const spinnerSpan = target.querySelector('.spinner-border');
        if (textSpan) textSpan.classList.toggle('d-none', show);
        if (spinnerSpan) spinnerSpan.classList.toggle('d-none', !show);
    };

    document.addEventListener('ajax:beforeSend', (event) => {
        const { target } = event;
        if (target && target.classList.contains('pagination-btn')) {
            handleSpinner(target, true);
            target.classList.add('disabled');
        }
    });

    document.addEventListener('ajax:complete', (event) => {
        const { target } = event;
        if (target && target.classList.contains('pagination-btn')) {
            handleSpinner(target, false);
            target.classList.remove('disabled');
        }
    });
});
