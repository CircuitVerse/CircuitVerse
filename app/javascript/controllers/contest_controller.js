import { Controller } from 'stimulus';

export default class extends Controller {
    static values = { timeleft: String }
    connect() {
        this.setCountDownTimer();
        this.setShowModals();
        this.setAdminModals();
    }
    enableSubmitButton() {
        document.getElementById('submission-submit-button').disabled = false;
    }

    setAdminModals() {
        $("#close-contest-confirmation-modal").on("show.bs.modal", function (e) {
            let contest = $(e.relatedTarget).data('contest');
            $(e.currentTarget).find('#close-contest-button').attr("href",
                `/contests/${contest}/close`);
        })
    }
    setShowModals() {
        $("#projectModal").on("show.bs.modal", function (e) {
            let projectSlug = $(e.relatedTarget).data('project').slug;
            let projectId = $(e.relatedTarget).data('project').id;
            let authorId = $(e.relatedTarget).data('project').author_id;
            var id = projectSlug ? projectSlug : projectId;
            $(e.currentTarget).find('#project-more-button').attr("href",
                "/users/" + authorId + "/projects/" + id);
            $(e.currentTarget).find('#project-ifram-preview').attr("src", "/simulator/" + id.toString())
        })
        $("#withdraw-submission-confirmation-modal").on("show.bs.modal", function (e) {
            let contest = $(e.relatedTarget).data('contest').id;
            let submission = $(e.relatedTarget).data('submission').id;
            $(e.currentTarget).find("#withdraw-submission-button").attr("href",
                `/contests/${contest}/withdraw/${submission}`
            )
        })
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