import { Controller } from 'stimulus';

export default class extends Controller {
    static get values() {
        return {
            timeleft: String,
        };
    }

    connect() {
        this.setCountDownTimer();
        this.setShowModals();
        this.setAdminModals();
    }

    // eslint-disable-next-line class-methods-use-this
    enableSubmitButton() {
        document.getElementById('submission-submit-button').disabled = false;
    }

    // eslint-disable-next-line class-methods-use-this
    setAdminModals() {
        const getContestId = (event) => $(event.relatedTarget).data('contest').id;

        const setupModal = (modalId, buttonId, path) => {
            $(`#${modalId}`).on('show.bs.modal', (e) => {
                const contestId = getContestId(e);
                $(e.currentTarget).find(`#${buttonId}`).attr('href', `/contests/${contestId}${path}`);
            });
        };

        setupModal('close-contest-confirmation-modal', 'close-contest-button', '/close_contest');
        setupModal('update-new-contest-modal', 'update-contest-button', '/update_contest');

        $('#update-contest-modal').on('show.bs.modal', (e) => {
            const contestId = getContestId(e);
            const currentDeadline = $(e.relatedTarget).data('deadline');
            const form = $(e.currentTarget).find('#update-contest-form');
            const action = form.attr('action').replace(':contest_id', contestId);
            form.attr('action', action);
            form.find('#contest_deadline').val(currentDeadline);
        });
    }

    // eslint-disable-next-line class-methods-use-this
    setShowModals() {
        $('#projectModal').on('show.bs.modal', (e) => {
            const projectSlug = $(e.relatedTarget).data('project').slug;
            const projectId = $(e.relatedTarget).data('project').id;
            const authorId = $(e.relatedTarget).data('project').author_id;
            var id = projectSlug || projectId;
            $(e.currentTarget).find('#project-more-button').attr(
                'href',
                `/users/${authorId}/projects/${id}`,
            );
            $(e.currentTarget).find('#project-ifram-preview').attr('src', `/simulator/${id.toString()}`);
        });
        $('#withdraw-submission-confirmation-modal').on('show.bs.modal', (e) => {
            const contest = $(e.relatedTarget).data('contest').id;
            const submission = $(e.relatedTarget).data('submission').id;
            $(e.currentTarget).find('#withdraw-submission-button').attr(
                'href',
                `/contests/${contest}/withdraw/${submission}`,
            );
        });
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
