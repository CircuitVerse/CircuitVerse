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

    connect() {
        this.changePlaceholder();
        this.boundHandleOutsideClick = this.handleOutsideClick.bind(this);
        this.boundHandleKeydown = this.handleKeydown.bind(this);
        document.addEventListener('click', this.boundHandleOutsideClick);
        this.selectWrapperTarget.addEventListener(
            'keydown',
            this.boundHandleKeydown,
        );
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
        const options = Array.from(
            this.dropdownTarget.querySelectorAll('.select-option'),
        );
        const currentActiveOption = this.dropdownTarget.querySelector(
            '.select-option.active',
        );

        if (options.length === 0) return;

        const currentIndex = currentActiveOption
            ? options.indexOf(currentActiveOption)
            : -1;

        let nextIndex;
        if (direction === 'down') {
            nextIndex = currentIndex < 0 ? 0 : (currentIndex + 1) % options.length;
        } else {
            nextIndex = currentIndex < 0 ? options.length - 1 : (currentIndex - 1 + options.length) % options.length;
        }

        this.updateActiveOption(options[nextIndex]);
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
}
