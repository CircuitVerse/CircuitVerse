import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static get targets() {
        return ['button', 'dropdown', 'content'];
    }

    static get values() {
        return {
            currentResource: String,
            countries: Array,
            filterLabels: Object,
            currentValues: Object,
        };
    }

    connect() {
        this.boundOutside = this.handleOutsideClick.bind(this);
        document.addEventListener('click', this.boundOutside);
        this.buildFiltersForResource();
    }

    disconnect() {
        document.removeEventListener('click', this.boundOutside);
    }

    updateFiltersForResource(event) {
        const { resource } = event.detail;
        this.currentResourceValue = resource;
        this.buildFiltersForResource();
    }

    buildFiltersForResource() {
        if (!this.hasDropdownTarget) return;

        this.dropdownTarget.innerHTML = '';

        const filtersContent = document.createElement('div');
        filtersContent.className = 'filters-content';

        if (this.currentResourceValue === 'Projects') {
            this.createProjectFilters(filtersContent);
        } else if (this.currentResourceValue === 'Users') {
            this.createUserFilters(filtersContent);
        }

        this.dropdownTarget.appendChild(filtersContent);
    }

    createProjectFilters(container) {
        const labels = (this.filterLabelsValue && this.filterLabelsValue.projects && this.filterLabelsValue.projects.tags) || {};
        const tagField = this.createMultiSelectTagField(
            'tag',
            labels.label || 'Tags',
            labels.placeholder || 'Add a tag...',
        );
        container.appendChild(tagField);
    }

    createUserFilters(container) {
        const countryLabels = (this.filterLabelsValue && this.filterLabelsValue.users && this.filterLabelsValue.users.country) || {};
        const instituteLabels = (this.filterLabelsValue && this.filterLabelsValue.users && this.filterLabelsValue.users.institute) || {};

        const countryField = this.createCountryDropdown(
            'country',
            countryLabels.label || 'Country',
            countryLabels.placeholder || 'Select Country...',
        );
        const instituteField = this.constructor.createFilterField(
            'institute',
            instituteLabels.label || 'Institute',
            'text',
            instituteLabels.placeholder || 'Enter institute...',
            (this.currentValuesValue && this.currentValuesValue.institute) || '',
        );

        container.appendChild(countryField);
        container.appendChild(instituteField);
    }

    static createFilterField(name, label, type, placeholder, currentValue = '') {
        const fieldDiv = document.createElement('div');
        fieldDiv.className = 'filter-field';

        const labelElement = document.createElement('label');
        labelElement.className = 'filter-label';
        labelElement.textContent = label;
        labelElement.setAttribute('for', `filter_${name}`);

        const inputElement = document.createElement('input');
        inputElement.className = 'filter-input';
        inputElement.type = type;
        inputElement.name = name;
        inputElement.id = `filter_${name}`;
        inputElement.placeholder = placeholder;
        inputElement.value = currentValue;

        // Prevent form submission on Enter key press
        inputElement.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                event.preventDefault();
            }
        });

        fieldDiv.appendChild(labelElement);
        fieldDiv.appendChild(inputElement);

        return fieldDiv;
    }

    createMultiSelectTagField(name, label, placeholder) {
        const fieldDiv = document.createElement('div');
        fieldDiv.className = 'filter-field';

        const labelElement = document.createElement('label');
        labelElement.className = 'filter-label';
        labelElement.textContent = label;
        labelElement.setAttribute('for', `filter_${name}`);

        const tagsDisplay = document.createElement('div');
        tagsDisplay.className = 'tags-display';

        const tagContainer = document.createElement('div');
        tagContainer.className = 'tag-input-container';

        const inputElement = document.createElement('input');
        inputElement.className = 'tag-input';
        inputElement.type = 'text';
        inputElement.placeholder = placeholder;
        inputElement.setAttribute('data-tag-input', name);

        // Hidden input to store the tag values for form submission
        const hiddenInput = document.createElement('input');
        hiddenInput.type = 'hidden';
        hiddenInput.name = name;
        hiddenInput.id = `filter_${name}`;

        // Store tags array on the container for easy access
        tagContainer.selectedTags = [];

        // Initialize with current tags from URL
        if (this.currentValuesValue && this.currentValuesValue.tag) {
            const currentTags = this.currentValuesValue.tag.split(',').map((tag) => tag.trim()).filter((tag) => tag);
            tagContainer.selectedTags = currentTags;
            this.renderTags(currentTags, tagsDisplay, tagContainer, hiddenInput);
        }

        // Add tag on Enter key
        inputElement.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                event.preventDefault();
                this.addTag(tagContainer, inputElement, hiddenInput, tagsDisplay);
            }
        });

        // Add tag on comma or blur
        inputElement.addEventListener('blur', () => {
            this.addTag(tagContainer, inputElement, hiddenInput, tagsDisplay);
        });

        tagContainer.appendChild(inputElement);

        fieldDiv.appendChild(labelElement);
        fieldDiv.appendChild(tagsDisplay);
        fieldDiv.appendChild(tagContainer);
        fieldDiv.appendChild(hiddenInput);

        return fieldDiv;
    }

    addTag(container, input, hiddenInput, display) {
        const tagText = input.value.trim();
        if (tagText && !container.selectedTags.includes(tagText)) {
            container.selectedTags.push(tagText);
            this.renderTags(container.selectedTags, display, container, hiddenInput);
            // eslint-disable-next-line no-param-reassign
            input.value = '';
        }
    }

    removeTag(container, hiddenInput, display, tagToRemove) {
        // eslint-disable-next-line no-param-reassign
        container.selectedTags = container.selectedTags.filter((tag) => tag !== tagToRemove);
        this.renderTags(container.selectedTags, display, container, hiddenInput);
    }

    renderTags(tags, display, container, hiddenInput) {
        // eslint-disable-next-line no-param-reassign
        display.innerHTML = '';
        // eslint-disable-next-line no-param-reassign
        hiddenInput.value = tags.join(',');

        tags.forEach((tag) => {
            const tagElement = document.createElement('span');
            tagElement.className = 'tag-item';
            tagElement.innerHTML = `
                ${tag}
                <button type="button" class="tag-remove" aria-label="Remove ${tag}">×</button>
            `;

            const removeBtn = tagElement.querySelector('.tag-remove');
            removeBtn.addEventListener('click', (event) => {
                event.stopPropagation();
                this.removeTag(container, hiddenInput, display, tag);
            });

            display.appendChild(tagElement);
        });
    }

    createCountryDropdown(name, label, placeholder = 'Select Country...') {
        const fieldDiv = document.createElement('div');
        fieldDiv.className = 'filter-field';

        const labelElement = document.createElement('label');
        labelElement.className = 'filter-label';
        labelElement.textContent = label;
        labelElement.setAttribute('for', `filter_${name}`);

        const selectElement = document.createElement('select');
        selectElement.className = 'filter-select';
        selectElement.name = name;
        selectElement.id = `filter_${name}`;

        // Add empty option
        const emptyOption = document.createElement('option');
        emptyOption.value = '';
        emptyOption.textContent = placeholder;
        selectElement.appendChild(emptyOption);

        // Add countries from the countries value
        if (this.countriesValue && Array.isArray(this.countriesValue)) {
            this.countriesValue.forEach((country) => {
                const option = document.createElement('option');
                option.value = country.code;
                option.textContent = country.name;
                selectElement.appendChild(option);
            });
        }

        // Set selected value from current state
        if (this.currentValuesValue && this.currentValuesValue.country) {
            selectElement.value = this.currentValuesValue.country;
        }

        // Prevent form submission on Enter key press
        selectElement.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                event.preventDefault();
            }
        });

        fieldDiv.appendChild(labelElement);
        fieldDiv.appendChild(selectElement);

        return fieldDiv;
    }

    toggleDropdown() {
        this.dropdownTarget.classList.toggle('show');
        this.element.classList.toggle('open');
    }

    close() {
        this.dropdownTarget.classList.remove('show');
        this.element.classList.remove('open');
    }

    handleOutsideClick(event) {
        if (!this.element.contains(event.target)) {
            this.close();
        }
    }
}
