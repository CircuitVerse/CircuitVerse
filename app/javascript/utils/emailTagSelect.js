/**
 * Lightweight wrapper around tom-select for "type an email, press
 * comma/space/enter to tag it" inputs. Replaces the select2 tags:true
 * pattern used across the groups and project-collaborator forms.
 *
 * `delimiter` handles splitting on typed commas; `splitOn` handles
 * splitting pasted text on spaces or commas, so no manual paste
 * handler is needed for either case.
 * `onChange` fires on every add/remove, covering the old
 * select2:select/select2:unselect toggle logic in one place.
 *
 * @param {string} selector - CSS selector for the <select multiple> element
 * @param {Object} [opts]
 * @param {(count: number) => void} [opts.onChange] - called with the
 *   current number of tags whenever the selection changes
 * @param {number} [opts.maxLength=30] - max characters per typed email
 * @returns {TomSelect|null}
 */
import TomSelect from 'tom-select';

export function initEmailTagSelect(selector, { onChange, maxLength = 30 } = {}) {
    const el = document.querySelector(selector);
    if (!el) return null;

    const instance = new TomSelect(el, {
        create: true,
        persist: false,
        delimiter: ',',
        splitOn: /[\s,]+/,
        maxItems: null,
        plugins: ['remove_button'],
        onChange: (value) => {
            if (onChange) onChange(Array.isArray(value) ? value.length : (value ? 1 : 0));
        },
    });

    if (instance.control_input) {
        instance.control_input.setAttribute('maxlength', String(maxLength));
    }

    return instance;
}
