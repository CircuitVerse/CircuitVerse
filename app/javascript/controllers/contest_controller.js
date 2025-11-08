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
        // --- OLD update-contest-modal logic (renamed to update-contest-deadline-modal) is now split ---

        // 1. Logic for the dedicated Update Name Modal
        const updateNameModal = this.element.querySelector('#update-contest-name-modal');
        if (updateNameModal) {
            $(updateNameModal).on('show.bs.modal', function handleUpdateNameModal(e) {
                const contestId = $(e.relatedTarget).data('contestId');
                const currentName = $(e.relatedTarget).data('name');
                const form = $(this).find('#update-contest-name-form'); // Target the specific name form ID

                // Use let for action to allow re-assignment if necessary, though attr() is often sufficient
                const action = form.attr('action').replace(':contest_id', contestId);
                form.attr('action', action);
                form.find('#contest_name').val(currentName);
            });
        }

        // 2. Logic for the dedicated Update Deadline Modal (formerly #update-contest-modal)
        const updateDeadlineModal = this.element.querySelector('#update-contest-deadline-modal');
        if (updateDeadlineModal) {
            $(updateDeadlineModal).on('show.bs.modal', function handleUpdateDeadlineModal(e) {
                const contestId = $(e.relatedTarget).data('contestId');
                const currentDeadline = $(e.relatedTarget).data('deadline');
                const form = $(this).find('#update-contest-deadline-form');

                const action = form.attr('action').replace(':contest_id', contestId);
                form.attr('action', action);
                form.find('#contest_deadline').val(currentDeadline);
            });
        }
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

