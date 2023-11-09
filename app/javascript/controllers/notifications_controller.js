/* eslint-disable class-methods-use-this */
import { Controller } from 'stimulus';

export default class extends Controller {
    activeAllNotifications() {
        document.getElementById('unread-notifications').classList.remove('active');
        document.getElementById('all-notifications').classList.add('active');
        document.getElementById('all-notifications-div').classList.remove('d-none');
        document.getElementById('unread-notifications-div').classList.remove('d-flex');
        document.getElementById('all-notifications-div').classList.add('d-flex');
        document.getElementById('unread-notifications-div').classList.add('d-none');
    }

    activeUnreadNotifications() {
        document.getElementById('all-notifications').classList.remove('active');
        document.getElementById('unread-notifications').classList.add('active');
        document.getElementById('all-notifications-div').classList.add('d-none');
        document.getElementById('unread-notifications-div').classList.add('d-flex');
        document.getElementById('all-notifications-div').classList.remove('d-flex');
        document.getElementById('unread-notifications-div').classList.remove('d-none');
    }
}
