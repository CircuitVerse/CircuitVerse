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
        const updateContestModals = this.element.querySelectorAll('[id^="update-contest-modal"]');
        updateContestModals.forEach((modal) => {
            $(modal).on('show.bs.modal', function handleUpdateContestModal(e) {
                const contestData = $(e.relatedTarget).data('contest');
                if (!contestData) return;
                const contestId = contestData.id;
                const currentDeadline = $(e.relatedTarget).data('deadline');
                const form = $(this).find(`[id^="update-contest-form"]`);
                if (form.length && form.attr('action')) {
                    const action = form.attr('action').replace(':contest_id', contestId);
                    form.attr('action', action);
                    if (currentDeadline) {
                        form.find('input[type="datetime-local"]').val(currentDeadline);
                    }
                }
            });
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
