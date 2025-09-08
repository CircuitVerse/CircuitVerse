import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static get targets() {
        return ['optionsList', 'sorting', 'sortingText', 'hiddenSortBy', 'hiddenSortDirection', 'sortingDirection', 'ascIcon', 'descIcon'];
    }

    static get values() {
        return {
            selectedSort: String,
            sortDirection: String,
            allOptions: Object,
            currentResource: String,
        };
    }

    connect() {
        this.boundOutside = this.handleOutsideClick.bind(this);
        document.addEventListener('click', this.boundOutside);
        this.buildSortingOptions();
    }

    disconnect() {
        document.removeEventListener('click', this.boundOutside);
    }

    updateOptionsForResource(event) {
        const { resource } = event.detail;
        this.currentResourceValue = resource;
        this.buildSortingOptions();
        this.resetToFirstOption();
        this.updateButtonText();
    }

    resetToFirstOption() {
        const currentOptions = this.getCurrentOptions();
        if (currentOptions.length > 0) {
            this.selectedSortValue = currentOptions[0].value;
        }
    }

    getCurrentOptions() {
        return this.allOptionsValue[this.currentResourceValue] || [];
    }

    toggleOptions() {
        this.optionsListTarget.classList.toggle('show');
        this.element.classList.toggle('open');
    }

    close() {
        this.optionsListTarget.classList.remove('show');
        this.element.classList.remove('open');
    }

    handleOutsideClick(event) {
        if (!this.element.contains(event.target)) {
            this.close();
        }
    }

    selectOption(event) {
        const option = event.currentTarget;
        const { value } = option.dataset;

        // update the selectedSortValue
        this.selectedSortValue = value;

        this.close();

        // Ensure hidden fields are updated before form submission
        this.updateHiddenFields();

        // Auto-submit the form when sorting option is selected
        this.submitForm();
    }

    // Automatically called when selectedSortValue changes
    selectedSortValueChanged() {
        this.updateHiddenFields();
        this.updateButtonText();
        this.buildSortingOptions(); // Rebuild to update active state
    }

    buildSortingOptions() {
        if (!this.hasOptionsListTarget || !this.allOptionsValue) return;

        this.optionsListTarget.innerHTML = '';
        const currentOptions = this.getCurrentOptions();

        currentOptions.forEach((option) => {
            const li = document.createElement('li');
            li.className = 'sorting-option';
            if (option.value === this.selectedSortValue) {
                li.classList.add('active');
            }
            li.dataset.value = option.value;
            li.dataset.action = 'click->search-sorting#selectOption';
            li.textContent = option.label;
            this.optionsListTarget.appendChild(li);
        });
    }

    updateButtonText() {
        if (!this.hasSortingTextTarget) return;

        const currentOptions = this.getCurrentOptions();
        const option = currentOptions.find((opt) => opt.value === this.selectedSortValue);
        const defaultOption = currentOptions[0];

        let buttonText = 'Created Date';
        if (option) {
            buttonText = option.label;
        } else if (defaultOption) {
            buttonText = defaultOption.label;
        }

        this.sortingTextTarget.textContent = buttonText;
    }

    toggleSortingDirection() {
        this.sortDirectionValue = this.sortDirectionValue === 'asc' ? 'desc' : 'asc';

        // Ensure hidden fields are updated before form submission
        this.updateHiddenFields();

        // Auto-submit the form when sort direction is changed
        this.submitForm();
    }

    // Automatically called when sortDirectionValue changes
    sortDirectionValueChanged() {
        this.updateSortIcon();
        this.updateHiddenFields();
    }

    updateSortIcon() {
        if (this.hasAscIconTarget && this.hasDescIconTarget) {
            if (this.sortDirectionValue === 'asc') {
                this.ascIconTarget.classList.remove('d-none');
                this.descIconTarget.classList.add('d-none');
            } else {
                this.ascIconTarget.classList.add('d-none');
                this.descIconTarget.classList.remove('d-none');
            }
        }
    }

    updateHiddenFields() {
        if (this.hasHiddenSortByTarget) {
            this.hiddenSortByTarget.value = this.selectedSortValue;
        }
        if (this.hasHiddenSortDirectionTarget) {
            this.hiddenSortDirectionTarget.value = this.sortDirectionValue;
        }
    }

    submitForm() {
        const searchForm = this.element.closest('form') || document.getElementById('search-box');
        if (searchForm) {
            searchForm.submit();
        }
    }
}
