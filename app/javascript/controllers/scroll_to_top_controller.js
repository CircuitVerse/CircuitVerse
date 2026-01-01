/* eslint-disable class-methods-use-this */
import { Controller } from 'stimulus';

export default class extends Controller {
    get buttonTarget() {
        return this.targets.find('button');
    }

    connect() {
        this.handleScroll = this.handleScroll.bind(this);
        window.addEventListener('scroll', this.handleScroll);
        this.handleScroll(); // Initial check
    }

    disconnect() {
        window.removeEventListener('scroll', this.handleScroll);
    }

    handleScroll() {
        const scrollY = window.scrollY || document.documentElement.scrollTop;
        if (scrollY > 300) {
            this.buttonTarget.classList.add('visible');
        } else {
            this.buttonTarget.classList.remove('visible');
        }
    }

    scrollToTop() {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
}
