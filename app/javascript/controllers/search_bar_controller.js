import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static get targets() {
        return ['select', 'input'];
    }

    static get values() {
        return { placeholders: Object };
    }

    connect() {
        this.changePlaceholder();
    }

    changePlaceholder() {
        const selectValue = this.selectTarget.value;
        const placeholderMap = this.placeholdersValue;
        this.inputTarget.placeholder = placeholderMap[selectValue];
    }
}
