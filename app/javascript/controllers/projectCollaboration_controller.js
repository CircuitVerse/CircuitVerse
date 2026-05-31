import { Controller } from 'stimulus';

export default class extends Controller {
    async embedInviteLink() {
        const text = document.getElementById('embedInviteLink').value;
        if (navigator.clipboard) {
            try {
                await navigator.clipboard.writeText(text);
                return;
            } catch {
                // fall through to execCommand fallback
            }
        }
        document.getElementById('embedInviteLink').select();
        document.execCommand('copy');
    }
}
