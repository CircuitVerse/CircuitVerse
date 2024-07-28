import { Controller } from 'stimulus';

export default class extends Controller {
    static values = { timeleft: String }
    connect() {
        this.setCountDownTimer();
    }

    setCountDownTimer() {
        var deadline = new Date(this.timeleftValue).getTime();
        var x = setInterval(() => {
            var now = new Date().getTime();
            var t = deadline - now;
            var days = Math.floor(t / (1000 * 60 * 60 * 24));
            var hours = Math.floor((t % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            var minutes = Math.floor((t % (1000 * 60 * 60)) / (1000 * 60));
            var seconds = Math.floor((t % (1000 * 60)) / 1000);
            document.getElementById('timeLeftCounter').innerHTML = `${days}d ${hours}h ${minutes}m ${seconds}s `;
            if (t < 0) {
                clearInterval(x);
                document.getElementById('timeLeftCounter').innerHTML = 'EXPIRED';
            }
        }, 1000);
    }
}