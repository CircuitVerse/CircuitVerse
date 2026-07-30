/* eslint-disable class-methods-use-this */
import { Controller } from 'stimulus';

const MAX_LINKS = 5;

export default class extends Controller {
    connect() {
        this.setupCounters();
        this.setupLinks();
        this.setupLogo();
        this.setupDeleteModal();
    }

    setupCounters() {
        this.bindCounter('organization_name', 'org-name-counter', 50);
        this.bindCounter('org-description-input', 'org-description-counter', 160);
    }

    bindCounter(inputId, counterId, maxLen) {
        const el = document.getElementById(inputId);
        const counter = document.getElementById(counterId);
        if (!el || !counter) return;
        const update = () => {
            const remaining = maxLen - el.value.length;
            counter.textContent = `${remaining} characters remaining`;
            counter.classList.toggle('text-danger', remaining <= Math.floor(maxLen * 0.15));
        };
        update();
        el.addEventListener('input', update);
    }

    setupLinks() {
        this.linksContainer = document.getElementById('organizations-links-container');
        this.addLinkBtn = document.getElementById('organizations-add-link-btn');
        if (!this.linksContainer || !this.addLinkBtn) return;

        // Stash a template of a link row (for re-adding after all are removed)
        const firstItem = this.linksContainer.querySelector('.organizations-link-item');
        if (firstItem) {
            this.linkTemplate = firstItem.cloneNode(true);
            const templateField = this.linkTemplate.querySelector('input');
            if (templateField) templateField.value = '';
        }

        this.linksContainer.addEventListener('input', (e) => {
            if (e.target.tagName === 'INPUT' && e.target.type === 'url') {
                this.updateLinkIcon(e.target);
            }
        });

        this.linksContainer.querySelectorAll('input[type="url"]').forEach((field) => {
            this.updateLinkIcon(field);
        });

        this.updateRemoveButtons();

        this.addLinkBtn.addEventListener('click', () => {
            const items = this.linksContainer.querySelectorAll('.organizations-link-item');
            if (items.length < MAX_LINKS && this.linkTemplate) {
                const newItem = this.linkTemplate.cloneNode(true);
                const field = newItem.querySelector('input');
                field.value = '';
                this.linksContainer.appendChild(newItem);
                this.updateRemoveButtons();
                this.updateLinkIcon(field);
            }
        });

        this.linksContainer.addEventListener('click', (e) => {
            const removeBtn = e.target.closest('.organizations-remove-link-btn');
            if (removeBtn) {
                removeBtn.closest('.organizations-link-item').remove();
                this.updateRemoveButtons();
            }
        });
    }

    updateRemoveButtons() {
        const items = this.linksContainer.querySelectorAll('.organizations-link-item');
        items.forEach((item) => {
            const btn = item.querySelector('.organizations-remove-link-btn');
            if (btn) btn.style.display = 'block';
        });
        this.addLinkBtn.style.display = items.length >= MAX_LINKS ? 'none' : 'inline-block';
    }

    updateLinkIcon(field) {
        const item = field.closest('.organizations-link-item');
        const img = item.querySelector('.organizations-input-icon');
        if (!img) return;

        const logos = this.linksContainer.dataset;
        const urlString = field.value.trim();
        if (!urlString) {
            img.src = logos.logoDefault;
            return;
        }

        let hostname = '';
        try {
            const parsed = new URL(urlString.startsWith('http') ? urlString : `https://${urlString}`);
            hostname = parsed.hostname.toLowerCase().replace(/^www\./, '');
        } catch (e) {
            img.src = logos.logoDefault;
            return;
        }

        const is = (host, domain) => host === domain || host.endsWith(`.${domain}`);
        if (is(hostname, 'github.com')) img.src = logos.logoGithub;
        else if (is(hostname, 'twitter.com') || is(hostname, 'x.com')) img.src = logos.logoX;
        else if (is(hostname, 'linkedin.com')) img.src = logos.logoLinkedin;
        else if (is(hostname, 'facebook.com')) img.src = logos.logoFacebook;
        else if (is(hostname, 'youtube.com') || is(hostname, 'youtu.be')) img.src = logos.logoYoutube;
        else img.src = logos.logoDefault;
    }

    setupLogo() {
        const zone = document.getElementById('organization-upload-zone');
        const input = document.getElementById('organization_logo');
        const label = document.getElementById('organization-upload-filename');
        if (input) {
            input.addEventListener('change', function () {
                if (this.files && this.files[0]) label.textContent = this.files[0].name;
            });
        }
        if (zone) {
            ['dragover', 'dragenter'].forEach((evt) => {
                zone.addEventListener(evt, (e) => {
                    e.preventDefault();
                    zone.classList.add('org-upload-zone--active');
                });
            });
            ['dragleave', 'drop'].forEach((evt) => {
                zone.addEventListener(evt, () => {
                    zone.classList.remove('org-upload-zone--active');
                });
            });
            zone.addEventListener('drop', (e) => {
                e.preventDefault();
                if (e.dataTransfer.files && e.dataTransfer.files[0]) {
                    input.files = e.dataTransfer.files;
                    label.textContent = e.dataTransfer.files[0].name;
                }
            });
        }
    }

    setupDeleteModal() {
        const deleteInput = document.getElementById('deleteOrgConfirmInput');
        const deleteBtn = document.getElementById('deleteOrgSubmitBtn');
        if (!deleteInput || !deleteBtn) return;
        const orgName = deleteInput.dataset.orgName;
        deleteInput.addEventListener('input', function () {
            deleteBtn.disabled = this.value !== orgName;
        });
        const modalEl = document.getElementById('deleteOrgModal');
        if (modalEl) {
            modalEl.addEventListener('show.bs.modal', () => {
                deleteInput.value = '';
                deleteBtn.disabled = true;
            });
        }
    }
}
