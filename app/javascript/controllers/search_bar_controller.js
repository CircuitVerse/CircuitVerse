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
        return {
            placeholders: Object,
            optionLabels: Object,
        };
    }

    static calculateNextIndex(currentIndex, optionsLength, direction) {
        if (currentIndex < 0) {
            return direction === 'down' ? 0 : optionsLength - 1;
        }

        if (direction === 'down') {
            return (currentIndex + 1) % optionsLength;
        }

        return (currentIndex - 1 + optionsLength) % optionsLength;
    }

    connect() {
        this.changePlaceholder();
        this.boundHandleOutsideClick = this.handleOutsideClick.bind(this);
        this.boundHandleKeydown = this.handleKeydown.bind(this);
        document.addEventListener('click', this.boundHandleOutsideClick);
        this.selectWrapperTarget.addEventListener(
            'keydown',
            this.boundHandleKeydown,
        );

        // Dispatch initial resource change event on connect
        this.dispatch('resource-changed', { detail: { resource: this.hiddenSelectTarget.value } });
    }

    disconnect() {
        document.removeEventListener('click', this.boundHandleOutsideClick);
        this.selectWrapperTarget.removeEventListener(
            'keydown',
            this.boundHandleKeydown,
        );
    }

    changePlaceholder() {
        const selectValue = this.hiddenSelectTarget.value;
        const placeholderMap = this.placeholdersValue;
        this.inputTarget.placeholder = placeholderMap[selectValue];

        // Dispatch event to notify sorting controller of resource change
        this.dispatch('resource-changed', { detail: { resource: selectValue } });
    }

    selectOption(event) {
        this.setSelectedOption(event.currentTarget);
    }

    setSelectedOption(option) {
        const { value } = option.dataset;

        const optionLabelsMap = this.optionLabelsValue;
        this.selectedOptionTarget.textContent = optionLabelsMap[value];
        this.hiddenSelectTarget.value = value;

        this.closeDropdown();

        this.changePlaceholder();

        this.updateActiveOption(option);

        // Auto-submit the form after allowing sorting controller to update
        this.submitFormAfterSortingUpdate();
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

    handleKeydown(event) {
        // Only handle keys when dropdown is open, except for Escape which can always close
        const isDropdownOpen = this.dropdownTarget.classList.contains('show');
        if (!isDropdownOpen && event.key !== 'Escape') return;

        switch (event.key) {
        case 'Escape':
            this.handleEscapeKey(event);
            break;
        case 'ArrowDown':
            this.handleArrowKey(event, 'down');
            break;
        case 'ArrowUp':
            this.handleArrowKey(event, 'up');
            break;
        case 'Enter':
            this.handleEnterKey(event);
            break;
        default:
            break;
        }
    }

    handleEscapeKey(event) {
        event.preventDefault();
        this.closeDropdown();
    }

    handleArrowKey(event, direction) {
        event.preventDefault();
        this.navigateOptions(direction);
    }

    handleEnterKey(event) {
        event.preventDefault();
        const currentActiveOption = this.dropdownTarget.querySelector(
            '.select-option.active',
        );
        if (currentActiveOption) {
            this.setSelectedOption(currentActiveOption);
        }
    }

    navigateOptions(direction) {
        const options = this.getSelectOptions();
        if (options.length === 0) return;

        const currentIndex = this.getCurrentOptionIndex(options);
        const nextIndex = this.constructor.calculateNextIndex(currentIndex, options.length, direction);

        this.updateActiveOption(options[nextIndex]);
    }

    getSelectOptions() {
        return Array.from(
            this.dropdownTarget.querySelectorAll('.select-option'),
        );
    }

    getCurrentOptionIndex(options) {
        const currentActiveOption = this.dropdownTarget.querySelector(
            '.select-option.active',
        );
        return currentActiveOption ? options.indexOf(currentActiveOption) : -1;
    }

    toggleDropdownState(action = 'toggle') {
        const dropdown = this.dropdownTarget;
        const wrapper = this.selectWrapperTarget;

        if (action === 'open') {
            dropdown.classList.add('show');
            wrapper.classList.add('open');
        } else if (action === 'close') {
            dropdown.classList.remove('show');
            wrapper.classList.remove('open');
        } else {
            dropdown.classList.toggle('show');
            wrapper.classList.toggle('open');
        }
    }

    toggleDropdown() {
        this.toggleDropdownState('toggle');
    }

    closeDropdown() {
        this.toggleDropdownState('close');
    }

    submitForm() {
        const searchForm = this.element.closest('form') || document.getElementById('search-box');
        if (searchForm) {
            searchForm.submit();
        }
    }

    submitFormAfterSortingUpdate() {
        // Allow time for the sorting controller to process the resource change event
        // and update the hidden sort fields with appropriate defaults
        setTimeout(() => {
            this.submitForm();
        }, 0);
    }
}
