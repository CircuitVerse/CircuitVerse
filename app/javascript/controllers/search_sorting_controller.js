import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static get targets() {
        return ['optionsList', 'sorting', 'hiddenSortBy', 'hiddenSortDirection', 'sortingDirection', 'ascIcon', 'descIcon'];
    }

    static get values() {
        return {
            selectedSort: String,
            sortDirection: String,
            options: Array,
        };
    }

    connect() {
        this.buildSortingOptions();
    }

    toggleOptions() {
        this.optionsListTarget.classList.toggle('d-none');
    }

    selectOption(event) {
        const option = event.currentTarget;
        const { value } = option.dataset;

        // update the selectedSortValue
        this.selectedSortValue = value;

        this.optionsListTarget.classList.add('d-none');
    }

    // Automatically called when selectedSortValue changes
    selectedSortValueChanged() {
        this.updateHiddenFields();
        this.updateButtonText();
    }

    buildSortingOptions() {
        if (this.hasOptionsListTarget && this.optionsValue) {
            this.optionsListTarget.innerHTML = '';

            this.optionsValue.forEach((option) => {
                const li = document.createElement('li');
                li.className = 'sorting-option';
                li.dataset.value = option.value;
                li.dataset.action = 'click->search-sorting#selectOption';
                li.textContent = option.label;
                this.optionsListTarget.appendChild(li);
            });
        }
    }

    updateButtonText() {
        const option = this.optionsValue.find((opt) => opt.value === this.selectedSortValue);
        const defaultOption = this.optionsValue[0];

        if (this.hasSortingTarget) {
            let buttonText = 'Created Date';
            if (option) {
                buttonText = option.label;
            } else if (defaultOption) {
                buttonText = defaultOption.label;
            }
            this.sortingTarget.textContent = buttonText;
        }
    }

    toggleSortingDirection() {
        this.sortDirectionValue = this.sortDirectionValue === 'asc' ? 'desc' : 'asc';
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
}
