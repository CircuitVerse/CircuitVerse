import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
    static get targets() {
        return [
            'button',
            'dropdown',
            'projectFilters',
            'userFilters',
            'tagInput',
            'tagHidden',
            'tagsDisplay',
            'countrySelect',
            'instituteInput',
            'applyButton',
        ];
    }

    static get values() {
        return {
            currentResource: String,
        };
    }

    connect() {
        this.boundOutside = this.handleOutsideClick.bind(this);
        document.addEventListener('click', this.boundOutside);
        this.setupTagInput();
        this.setupFormInputs();
    }

    disconnect() {
        document.removeEventListener('click', this.boundOutside);
    }

    updateFiltersForResource(event) {
        const { resource } = event.detail;
        this.currentResourceValue = resource;
        this.showFiltersForResource();
    }

    showFiltersForResource() {
        // Hide all filter sections first
        if (this.hasProjectFiltersTarget) {
            this.projectFiltersTarget.classList.add('hidden');
        }
        if (this.hasUserFiltersTarget) {
            this.userFiltersTarget.classList.add('hidden');
        }

        // Show the appropriate filter section
        if (this.currentResourceValue === 'Projects' && this.hasProjectFiltersTarget) {
            this.projectFiltersTarget.classList.remove('hidden');
        } else if (this.currentResourceValue === 'Users' && this.hasUserFiltersTarget) {
            this.userFiltersTarget.classList.remove('hidden');
        }
    }

    setupTagInput() {
        if (!this.hasTagInputTarget) return;

        // Add tag on Enter key
        this.tagInputTarget.addEventListener('keydown', (event) => {
            if (event.key === 'Enter') {
                event.preventDefault();
                this.addTag();
            }
        });

        // Add tag on blur
        this.tagInputTarget.addEventListener('blur', () => {
            this.addTag();
        });

        // Setup remove buttons for existing tags
        this.setupTagRemoveButtons();
    }

    setupFormInputs() {
        // Prevent form submission on Enter key for all filter inputs
        const inputs = this.element.querySelectorAll('input, select');
        inputs.forEach((input) => {
            input.addEventListener('keydown', (event) => {
                if (event.key === 'Enter' && input !== this.tagInputTarget) {
                    event.preventDefault();
                }
            });
        });
    }

    setupTagRemoveButtons() {
        if (!this.hasTagsDisplayTarget) return;

        const removeButtons = this.tagsDisplayTarget.querySelectorAll('.tag-remove');
        removeButtons.forEach((button) => {
            button.addEventListener('click', (event) => {
                event.stopPropagation();
                this.removeTag(button.dataset.tag);
            });
        });
    }

    addTag() {
        if (!this.hasTagInputTarget || !this.hasTagHiddenTarget || !this.hasTagsDisplayTarget) return;

        const tagText = this.tagInputTarget.value.trim();
        if (!tagText) return;

        const currentTags = this.getCurrentTags();
        if (currentTags.includes(tagText)) return;

        currentTags.push(tagText);
        this.updateTags(currentTags);
        this.tagInputTarget.value = '';
    }

    removeTag(tagToRemove) {
        if (!this.hasTagHiddenTarget || !this.hasTagsDisplayTarget) return;

        const currentTags = this.getCurrentTags();
        const updatedTags = currentTags.filter((tag) => tag !== tagToRemove);
        this.updateTags(updatedTags);
    }

    getCurrentTags() {
        if (!this.hasTagHiddenTarget) return [];

        const { value } = this.tagHiddenTarget;
        return value ? value.split(',').map((tag) => tag.trim()).filter((tag) => tag) : [];
    }

    updateTags(tags) {
        if (!this.hasTagHiddenTarget || !this.hasTagsDisplayTarget) return;

        // Update hidden input
        this.tagHiddenTarget.value = tags.join(',');

        // Update display
        this.tagsDisplayTarget.innerHTML = '';
        tags.forEach((tag) => {
            const tagElement = document.createElement('span');
            tagElement.className = 'tag-item';
            // Safely append tag text and remove button without using innerHTML
            const textSpan = document.createElement('span');
            textSpan.className = 'tag-text';
            textSpan.textContent = tag;
            tagElement.appendChild(textSpan);

            const removeBtn = document.createElement('button');
            removeBtn.type = 'button';
            removeBtn.className = 'tag-remove';
            removeBtn.dataset.tag = tag;
            removeBtn.setAttribute('aria-label', `Remove ${tag}`);
            removeBtn.textContent = '×';
            removeBtn.addEventListener('click', (event) => {
                event.stopPropagation();
                this.removeTag(tag);
            });
            tagElement.appendChild(removeBtn);

            this.tagsDisplayTarget.appendChild(tagElement);
        });
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

    applyFilters() {
        this.close();
        this.submitForm();
    }

    clearFilters() {
        let didAffectParams = false;

        // Project filters (affect params)
        if (this.hasTagHiddenTarget && this.tagHiddenTarget.value !== '') {
            this.tagHiddenTarget.value = '';
            didAffectParams = true;
        }
        // Project filters (UI only)
        if (this.hasTagsDisplayTarget && this.tagsDisplayTarget.innerHTML.trim() !== '') {
            this.tagsDisplayTarget.innerHTML = '';
        }
        if (this.hasTagInputTarget && this.tagInputTarget.value !== '') {
            this.tagInputTarget.value = '';
        }

        // User filters (affect params)
        if (this.hasCountrySelectTarget && this.countrySelectTarget.value !== '') {
            this.countrySelectTarget.value = '';
            didAffectParams = true;
        }
        if (this.hasInstituteInputTarget && this.instituteInputTarget.value !== '') {
            this.instituteInputTarget.value = '';
            didAffectParams = true;
        }

        // If nothing changed, do not submit
        if (!didAffectParams) {
            this.close();
            return;
        }

        this.applyFilters();
    }

    submitForm() {
        const searchForm = this.element.closest('form') || document.getElementById('search-box');
        if (searchForm) {
            searchForm.submit();
        }
    }
}
