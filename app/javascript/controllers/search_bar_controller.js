import { Controller } from '@hotwired/stimulus';

// Search keyword suggestions for the advanced search input (Issue #7340)
const SUGGESTIONS = [
    {
        keyword: 'AND',
        description: 'Combine search terms (both must match)',
        category: 'Operators',
    },
    {
        keyword: 'OR',
        description: 'Match either search term',
        category: 'Operators',
    },
    {
        keyword: 'NOT',
        description: 'Exclude a search term',
        category: 'Operators',
    },
    {
        keyword: 'UNIQUE',
        description: 'Show only unique results',
        category: 'Operators',
    },
    {
        keyword: 'tag:',
        description: 'Filter by project tag',
        category: 'Filters',
    },
    {
        keyword: 'author:',
        description: 'Filter by author name',
        category: 'Filters',
    },
    {
        keyword: 'project:',
        description: 'Filter by project name',
        category: 'Filters',
    },
];

export default class extends Controller {
    static get targets() {
        return [
            'selectWrapper',
            'selectButton',
            'selectedOption',
            'dropdown',
            'hiddenSelect',
            'input',
            'suggestionsPanel',
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
        this.boundHandleInputKeydown = this.handleInputKeydown.bind(this);
        this.boundHandleInput = this.handleInput.bind(this);
        this.boundHandleInputFocus = this.handleInputFocus.bind(this);
        this.activeSuggestionIndex = -1;
        this._suppressNextFocus = false;

        document.addEventListener('click', this.boundHandleOutsideClick);
        this.selectWrapperTarget.addEventListener(
            'keydown',
            this.boundHandleKeydown,
        );

        // Suggestions event listeners and ARIA attributes on the search input
        if (this.hasInputTarget) {
            this.inputTarget.addEventListener('input', this.boundHandleInput);
            this.inputTarget.addEventListener('focus', this.boundHandleInputFocus);
            this.inputTarget.addEventListener('keydown', this.boundHandleInputKeydown);

            if (this.hasSuggestionsPanelTarget) {
                this.inputTarget.setAttribute('role', 'combobox');
                this.inputTarget.setAttribute('aria-autocomplete', 'list');
                this.inputTarget.setAttribute('aria-controls', 'search-suggestions-listbox');
                this.inputTarget.setAttribute('aria-expanded', 'false');
            }
        }

        // Dispatch initial resource change event on connect
        this.dispatch('resource-changed', { detail: { resource: this.hiddenSelectTarget.value } });
    }

    disconnect() {
        document.removeEventListener('click', this.boundHandleOutsideClick);
        this.selectWrapperTarget.removeEventListener(
            'keydown',
            this.boundHandleKeydown,
        );

        if (this.hasInputTarget) {
            this.inputTarget.removeEventListener('input', this.boundHandleInput);
            this.inputTarget.removeEventListener('focus', this.boundHandleInputFocus);
            this.inputTarget.removeEventListener('keydown', this.boundHandleInputKeydown);
        }
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

        // Close suggestions if click is outside the search bar container
        if (this.hasSuggestionsPanelTarget && !this.element.contains(event.target)) {
            this.hideSuggestions();
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

    // =========================================================================
    // Suggestions / Autocomplete (Issue #7340)
    // =========================================================================

    /**
     * Returns the last word (token) being typed in the input, i.e. text after
     * the last space character.  Used to filter suggestions contextually.
     */
    getLastWord() {
        const value = this.inputTarget.value;
        const cursorPos = this.inputTarget.selectionStart ?? value.length;
        const textBeforeCursor = value.substring(0, cursorPos);
        const words = textBeforeCursor.split(/\s+/);
        return words[words.length - 1] || '';
    }

    /**
     * Filter the static SUGGESTIONS list against the user's current partial
     * word.  Returns all suggestions when the partial word is empty.
     */
    filterSuggestions(partial) {
        if (!partial) return SUGGESTIONS;

        const lower = partial.toLowerCase();
        return SUGGESTIONS.filter(
            (s) => s.keyword.toLowerCase().startsWith(lower),
        );
    }

    /**
     * Build the suggestions panel DOM from a filtered list of suggestions.
     */
    renderSuggestions(filtered) {
        if (!this.hasSuggestionsPanelTarget) return;

        const panel = this.suggestionsPanelTarget;
        panel.innerHTML = '';

        if (filtered.length === 0) {
            this.hideSuggestions();
            return;
        }

        // Group by category
        const grouped = {};
        filtered.forEach((s) => {
            if (!grouped[s.category]) grouped[s.category] = [];
            grouped[s.category].push(s);
        });

        Object.keys(grouped).forEach((category) => {
            // Category header
            const header = document.createElement('div');
            header.className = 'search-suggestion-category';
            header.textContent = category;
            panel.appendChild(header);

            grouped[category].forEach((suggestion, index) => {
                const item = document.createElement('div');
                item.className = 'search-suggestion-item';
                item.setAttribute('role', 'option');
                item.setAttribute('aria-selected', 'false');
                item.id = `search-suggestion-${suggestion.keyword.replace(/[^a-zA-Z]/g, '')}`;
                item.dataset.keyword = suggestion.keyword;

                const keywordEl = document.createElement('span');
                keywordEl.className = 'search-suggestion-keyword';
                keywordEl.textContent = suggestion.keyword;

                const descEl = document.createElement('span');
                descEl.className = 'search-suggestion-description';
                descEl.textContent = suggestion.description;

                item.appendChild(keywordEl);
                item.appendChild(descEl);

                item.addEventListener('click', (e) => {
                    e.preventDefault();
                    e.stopPropagation();
                    this.insertSuggestion(suggestion.keyword);
                });

                panel.appendChild(item);
            });
        });

        this.activeSuggestionIndex = -1;
        panel.classList.add('show');
        this.inputTarget.setAttribute('aria-expanded', 'true');
    }

    /**
     * Insert a suggestion keyword into the input, replacing the partial word
     * that the user was typing.  Adds a trailing space for operators, keeps
     * cursor tight for filter prefixes (e.g. "tag:").
     */
    insertSuggestion(keyword) {
        const value = this.inputTarget.value;
        const cursorPos = this.inputTarget.selectionStart ?? value.length;
        const textBeforeCursor = value.substring(0, cursorPos);
        const textAfterCursor = value.substring(cursorPos);

        // Find the start of the last word
        const lastSpaceIndex = textBeforeCursor.lastIndexOf(' ');
        const beforeLastWord = textBeforeCursor.substring(0, lastSpaceIndex + 1);

        // Add trailing space for operators (not for filter prefixes like "tag:")
        const suffix = keyword.endsWith(':') ? '' : ' ';

        this.inputTarget.value = beforeLastWord + keyword + suffix + textAfterCursor;

        // Position cursor right after the inserted keyword + suffix
        const newCursorPos = (beforeLastWord + keyword + suffix).length;
        this.inputTarget.setSelectionRange(newCursorPos, newCursorPos);

        // Prevent the programmatic focus() from reopening the suggestions panel
        this._suppressNextFocus = true;
        this.inputTarget.focus();

        this.hideSuggestions();
    }

    showSuggestions() {
        const partial = this.getLastWord();
        const filtered = this.filterSuggestions(partial);
        this.renderSuggestions(filtered);
    }

    hideSuggestions() {
        if (!this.hasSuggestionsPanelTarget) return;
        this.suggestionsPanelTarget.classList.remove('show');
        this.activeSuggestionIndex = -1;

        // Reset ARIA state when suggestions are hidden
        if (this.hasInputTarget) {
            this.inputTarget.setAttribute('aria-expanded', 'false');
            this.inputTarget.removeAttribute('aria-activedescendant');
        }
    }

    /**
     * Handle the "input" event — filter suggestions as the user types.
     */
    handleInput() {
        this.showSuggestions();
    }

    /**
     * Handle the "focus" event — show suggestions when input is focused.
     */
    handleInputFocus() {
        if (this._suppressNextFocus) {
            this._suppressNextFocus = false;
            return;
        }
        this.showSuggestions();
    }

    /**
     * Handle keydown events on the input for suggestion navigation.
     * Arrow keys, Enter, and Escape are intercepted only when the
     * suggestions panel is visible.
     */
    handleInputKeydown(event) {
        if (!this.hasSuggestionsPanelTarget) return;

        const isVisible = this.suggestionsPanelTarget.classList.contains('show');
        if (!isVisible) return;

        const items = this.getSuggestionItems();
        if (items.length === 0) return;

        switch (event.key) {
        case 'ArrowDown':
            event.preventDefault();
            this.navigateSuggestions('down', items);
            break;
        case 'ArrowUp':
            event.preventDefault();
            this.navigateSuggestions('up', items);
            break;
        case 'Enter':
            if (this.activeSuggestionIndex >= 0 && this.activeSuggestionIndex < items.length) {
                event.preventDefault();
                const activeItem = items[this.activeSuggestionIndex];
                this.insertSuggestion(activeItem.dataset.keyword);
            }
            // If no suggestion is highlighted, let the form submit normally
            break;
        case 'Escape':
            event.preventDefault();
            this.hideSuggestions();
            break;
        default:
            break;
        }
    }

    /**
     * Get all suggestion item elements from the panel.
     */
    getSuggestionItems() {
        if (!this.hasSuggestionsPanelTarget) return [];
        return Array.from(
            this.suggestionsPanelTarget.querySelectorAll('.search-suggestion-item'),
        );
    }

    /**
     * Navigate through suggestion items with arrow keys.
     */
    navigateSuggestions(direction, items) {
        // Remove active class and aria-selected from current
        if (this.activeSuggestionIndex >= 0 && this.activeSuggestionIndex < items.length) {
            items[this.activeSuggestionIndex].classList.remove('active');
            items[this.activeSuggestionIndex].setAttribute('aria-selected', 'false');
        }

        if (direction === 'down') {
            this.activeSuggestionIndex = (this.activeSuggestionIndex + 1) % items.length;
        } else {
            this.activeSuggestionIndex = this.activeSuggestionIndex <= 0
                ? items.length - 1
                : this.activeSuggestionIndex - 1;
        }

        const activeItem = items[this.activeSuggestionIndex];
        activeItem.classList.add('active');
        activeItem.setAttribute('aria-selected', 'true');

        // Update aria-activedescendant so screen readers announce the active option
        this.inputTarget.setAttribute('aria-activedescendant', activeItem.id);

        // Scroll into view if needed
        activeItem.scrollIntoView({ block: 'nearest' });
    }
}
