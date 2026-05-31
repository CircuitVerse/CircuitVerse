import { Controller } from 'stimulus';

export default class extends Controller {
    connect() {
        this.setShowModals();
        this.setAdminModals();
    }

    enableSubmitButton() {
        const button = this.element.querySelector('#submission-submit-button');
        if (button) {
            button.disabled = false;
        }
    }

    setAdminModals() {
        const updateContestModal = this.element.querySelector('#update-contest-modal');
        if (!updateContestModal) return;
        $(updateContestModal).on('show.bs.modal', function handleUpdateContestModal(e) {
            const contestId = $(e.relatedTarget).data('contest').id;
            const currentDeadline = $(e.relatedTarget).data('deadline');
            const form = $(this).find('#update-contest-form');
            const action = form.attr('action').replace(':contest_id', contestId);
            form.attr('action', action);
            form.find('#contest_deadline').val(currentDeadline);
        });
    }

    setShowModals() {
        const projectModal = this.element.querySelector('#projectModal');
        if (projectModal) {
            $(projectModal).on('show.bs.modal', (e) => {
                const projectData = $(e.relatedTarget).data('project');
                if (!projectData) return;

                const { slug, id, author_id: authorId } = projectData;
                const projectSlugOrId = slug || id;

                $(e.currentTarget)
                    .find('#project-more-button')
                    .attr('href', `/users/${authorId}/projects/${projectSlugOrId}`);

                $(e.currentTarget)
                    .find('#project-iframe-preview')
                    .attr('src', `/simulator/${projectSlugOrId}`);
            });
        }

        const withdrawModal = this.element.querySelector('#withdraw-submission-confirmation-modal');
        if (withdrawModal) {
            $(withdrawModal).on('show.bs.modal', (e) => {
                const contestId = $(e.relatedTarget).data('contest').id;
                const submissionId = $(e.relatedTarget).data('submission').id;
                $(e.currentTarget)
                    .find('#withdraw-submission-button')
                    .attr('href', `/contests/${contestId}/submissions/${submissionId}/withdraw`);
            });
        }
    }
}
