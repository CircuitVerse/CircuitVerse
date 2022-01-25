import { Controller } from 'stimulus';
import 'bootstrap-tagsinput/dist/bootstrap-tagsinput.js';

export default class extends Controller {
    connect() {
        $('#invite_collab_button').on('click', () => {
            setTimeout(function () { $("#embedInviteLink").select(); document.execCommand("copy") }, 100);
        })
    }
}