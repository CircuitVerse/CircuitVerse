/* eslint-disable class-methods-use-this */
import { Controller } from 'stimulus';

export default class extends Controller {
    static targets = ['allNotifications', 'unreadNotifications', 'allNotificationsDiv', 'unreadNotificationsDiv'];

    connect() {
        // Check URL params for active tab
        const urlParams = new URLSearchParams(window.location.search);
        const tab = urlParams.get('tab');
        
        if (tab === 'unread') {
            this.activeUnreadNotifications();
        } else {
            this.activeAllNotifications();
        }
    }

    activeAllNotifications() {
        // Update tab styles
        this.unreadNotificationsTarget.classList.remove('active');
        this.allNotificationsTarget.classList.add('active');
        
        // Update content visibility
        this.allNotificationsDivTarget.classList.remove('d-none');
        this.unreadNotificationsDivTarget.classList.remove('d-flex');
        this.allNotificationsDivTarget.classList.add('d-flex');
        this.unreadNotificationsDivTarget.classList.add('d-none');
        
        // Update URL without page reload
        this.updateUrlParam('tab', 'all');
    }

    activeUnreadNotifications() {
        // Update tab styles
        this.allNotificationsTarget.classList.remove('active');
        this.unreadNotificationsTarget.classList.add('active');
        
        // Update content visibility
        this.allNotificationsDivTarget.classList.add('d-none');
        this.unreadNotificationsDivTarget.classList.add('d-flex');
        this.allNotificationsDivTarget.classList.remove('d-flex');
        this.unreadNotificationsDivTarget.classList.remove('d-none');
        
        // Update URL without page reload
        this.updateUrlParam('tab', 'unread');
    }

    updateUrlParam(key, value) {
        const url = new URL(window.location);
        url.searchParams.set(key, value);
        window.history.replaceState({}, '', url);
    }
}
