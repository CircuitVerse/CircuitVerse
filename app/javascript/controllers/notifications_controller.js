
/* eslint-disable class-methods-use-this */
import { Controller } from 'stimulus';

export default class extends Controller {
    activeAllNotifications() {
        this.toggleNotifications('unread', 'all');
    }

    activeUnreadNotifications() {
        this.toggleNotifications('all', 'unread');
    }

    toggleNotifications(inactive, active) {
        const inactiveElement = document.getElementById(`${inactive}-notifications`);
        const activeElement = document.getElementById(`${active}-notifications`);
        const inactiveDiv = document.getElementById(`${inactive}-notifications-div`);
        const activeDiv = document.getElementById(`${active}-notifications-div`);
        
        inactiveElement.classList.remove('active');
        activeElement.classList.add('active');
        inactiveDiv.classList.remove('d-flex');
        inactiveDiv.classList.add('d-none');
        activeDiv.classList.remove('d-none');
        activeDiv.classList.add('d-flex');
    }
}

