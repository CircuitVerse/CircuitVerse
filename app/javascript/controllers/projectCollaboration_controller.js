import { Controller } from 'stimulus';
import 'bootstrap-tagsinput/dist/bootstrap-tagsinput.js';

export default class extends Controller {
    embedInviteLink() {
        setTimeout(()=>{
            $("#embedInviteLink").select(); document.execCommand("copy")
        }, 100);
    }
}