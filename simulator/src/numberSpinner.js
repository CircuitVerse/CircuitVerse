/**
 * Lightweight replacement for the bootstrap-input-spinner jQuery plugin.
 * Wraps each matching number input with +/- buttons that respect the
 * input's own min/max/step attributes, and fires a native 'change'
 * event so existing listeners (e.g. objectPropertyAttribute handlers)
 * keep working unchanged.
 * @param {string} selector - CSS selector for number inputs to enhance
 */
export function attachNumberSpinners(selector) {
    document.querySelectorAll(selector).forEach((input) => {
        if (input.dataset.spinnerAttached) return;
        input.dataset.spinnerAttached = 'true';

        const wrapper = document.createElement('span');
        wrapper.className = 'input-spinner-wrapper';

        const makeBtn = (label, delta) => {
            const btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'btn btn-sm btn-outline-secondary spinner-btn';
            btn.textContent = label;
            btn.addEventListener('click', () => {
                const step = parseFloat(input.step) || 1;
                const min = input.min !== '' ? parseFloat(input.min) : -Infinity;
                const max = input.max !== '' ? parseFloat(input.max) : Infinity;
                const next = (parseFloat(input.value) || 0) + delta * step;
                input.value = Math.min(max, Math.max(min, next));
                input.dispatchEvent(new Event('change', { bubbles: true }));
            });
            return btn;
        };

        input.parentNode.insertBefore(wrapper, input);
        wrapper.appendChild(makeBtn('−', -1));
        wrapper.appendChild(input);
        wrapper.appendChild(makeBtn('+', 1));
    });
}
