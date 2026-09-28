import TomSelect from 'tom-select';

/**
 * Lightweight wrapper around tom-select for "type an email, press
 * space/comma/enter to tag it" inputs. Replaces the select2 tags:true
 * pattern used across the groups and project-collaborator forms.
 *
 * `delimiter` splits on typed commas, `splitOn` splits pasted text on
 * spaces/newlines/commas, and a keydown handler turns a typed space
 * into a tag (select2's old tokenSeparators behaviour).
 * `onChange` is called with the current tag count on every add/remove
 * and once after init, so callers can set their initial button state.
 *
 * @param {string} selector - CSS selector for the <select multiple> element
 * @param {Object} [opts]
 * @param {(count: number) => void} [opts.onChange]
 * @returns {TomSelect|null}
 */
export default function initEmailTagSelect(selector, { onChange } = {}) {
    const el = document.querySelector(selector);
    if (!el) return null;

    const instance = new TomSelect(el, {
        create: true,
        persist: false,
        delimiter: ',',
        splitOn: /[\s,]+/,
        maxItems: null,
        plugins: ['remove_button'],
        onChange: () => {
            if (onChange) onChange(instance.items.length);
        },
    });

    instance.control_input.addEventListener('keydown', (e) => {
        if (e.key !== ' ') return;
        e.preventDefault();
        const value = instance.control_input.value.trim();
        if (value) instance.createItem(value);
    });

    if (onChange) onChange(instance.items.length);
    return instance;
}
