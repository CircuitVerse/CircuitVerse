import './controllers';
import 'bootstrap';
import '@popperjs/core';
document.addEventListener('turbolinks:load', () => {
    const toggleBtn = document.getElementById('dark-mode-toggle');
    const body = document.body;

    // 1. Initial State Check (LocalStorage)
    if (localStorage.getItem('theme') === 'dark') {
        body.classList.add('dark-mode');
    }

    // 2. Toggle Action
    if (toggleBtn) {
        toggleBtn.addEventListener('click', (e) => {
            e.preventDefault();
            body.classList.toggle('dark-mode');
            
            const isDark = body.classList.contains('dark-mode');
            localStorage.setItem('theme', isDark ? 'dark' : 'light');

            // Force the Simulator to re-render with new colors
            // This calls the dots() function we modified in canvasApi.js
            if (typeof CV === 'object' && CV.dots) {
                CV.dots(true, false, true);
            }
        });
    }
});