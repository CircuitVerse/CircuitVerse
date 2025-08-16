import { Controller } from '@hotwired/stimulus';

function copyViaInput(value) {
    const input = document.createElement('input');
    input.value = value;
    input.setAttribute('readonly', '');
    input.style.position = 'absolute';
    input.style.left = '-9999px';
    input.style.top = '0';
    document.body.appendChild(input);
    input.focus();
    input.select();
    const ok = document.execCommand('copy');
    document.body.removeChild(input);
    if (!ok) throw new Error('copy failed');
}

export default class extends Controller {
    static get values() {
        return { url: String, title: String, text: String };
    }

    static get targets() {
        return ['toast'];
    }

    async share(event) {
        if (event) {
            event.preventDefault();
            event.stopPropagation();
        }

        const url = this.hasUrlValue ? this.urlValue : window.location.href;
        const title = this.hasTitleValue ? this.titleValue : document.title;
        const text = this.hasTextValue ? this.textValue : '';

        if (navigator.share) {
            try {
                await navigator.share({ title, text, url });
                this.flashToast();
                return;
            } catch (err) {
                const name = err && err.name;
                if (name === 'AbortError' || name === 'NotAllowedError' || name === 'InvalidStateError') {
                    return;
                }

            }
        }

        if (navigator.clipboard && navigator.clipboard.writeText) {
            try {
                await navigator.clipboard.writeText(url);
                this.flashToast();
                return;
            } catch (_) {

            }
        }

        try {
            copyViaInput(url);
            this.flashToast();
        } catch (_) {

        }
    }

    flashToast() {
        if (!this.hasToastTarget) return;
        const toast = this.toastTarget;
        toast.classList.add('show');
        setTimeout(() => toast.classList.remove('show'), 1500);
    }
}
