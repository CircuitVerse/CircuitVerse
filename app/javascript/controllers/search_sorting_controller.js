import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static get targets() {
        return ['optionsList', 'sorting', 'hiddenSortBy', 'hiddenSortDirection', 'sortingDirection', 'ascIcon', 'descIcon'];
    }

    static get values() {
        return {
            selectedSort: String,
            sortDirection: String,
        };
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

    updateButtonText() {
        const textMap = {
            created_at: 'Created Date',
            views: 'Views',
            stars: 'Stars',
        };

        if (this.hasSortingTarget) {
            this.sortingTarget.textContent = textMap[this.selectedSortValue] || 'Created Date';
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
