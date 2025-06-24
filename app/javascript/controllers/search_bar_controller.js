import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static get targets() {
        return [
            'selectWrapper',
            'selectButton',
            'selectedOption',
            'dropdown',
            'hiddenSelect',
            'input',
        ];
    }

    static get values() {
        return { placeholders: Object };
    }

    connect() {
        this.changePlaceholder();
        document.addEventListener('click', this.handleOutsideClick.bind(this));
    }

    disconnect() {
        document.removeEventListener('click', this.handleOutsideClick.bind(this));
    }

    toggleDropdown() {
        this.dropdownTarget.classList.toggle('show');
        this.selectWrapperTarget.classList.toggle('open');
    }

    selectOption(event) {
        const option = event.currentTarget;
        const { value } = option.dataset;

        this.selectedOptionTarget.textContent = value;

        this.hiddenSelectTarget.value = value;

        this.changePlaceholder();

        this.closeDropdown();

        this.updateActiveOption(option);
    }

    changePlaceholder() {
        const selectValue = this.hiddenSelectTarget.value;
        const placeholderMap = this.placeholdersValue;
        this.inputTarget.placeholder = placeholderMap[selectValue];
    }

    closeDropdown() {
        this.dropdownTarget.classList.remove('show');
        this.selectWrapperTarget.classList.remove('open');
    }

    updateActiveOption(selectedOption) {
        this.dropdownTarget.querySelectorAll('.select-option').forEach((option) => {
            option.classList.remove('active');
        });

        selectedOption.classList.add('active');
    }

    handleOutsideClick(event) {
        if (!this.selectWrapperTarget.contains(event.target)) {
            this.closeDropdown();
        }
    }
}
