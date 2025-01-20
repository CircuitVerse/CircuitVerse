import { Controller } from 'stimulus';

export default class extends Controller {
    connect() {
        this.setupModal('#promote-member-modal', '#groups-member-promote-button');
        this.setupModal('#demote-member-modal', '#groups-member-demote-button');
    }

    setupModal(modalSelector, buttonSelector) {
        $(modalSelector).on('show.bs.modal', (e) => {
            const groupmember = $(e.relatedTarget).data('currentgroupmember');
            $(e.currentTarget).find(buttonSelector).parent().attr('action', `/group_members/${groupmember.toString()}`);
        });
    }

    toggleButtonBasedOnEmails(emailSelector, buttonSelector) {
        const hasSelectedEmails = $(emailSelector).select2('data').length > 0;
        $(buttonSelector).attr('disabled', !hasSelectedEmails);
    }

    mentorInputPaste(e) {
        this.handlePaste(e, '#group_mentor_emails', '#add-mentor-button');
    }

    handlePaste(e, emailSelector, buttonSelector) {
        e.preventDefault();
        let pastedEmails = (e.clipboardData || window.clipboardData).getData('text/plain');
        const emails = pastedEmails.includes('\n') 
            ? pastedEmails.replace(/\n/g, ' ').split(' ') 
            : pastedEmails.split(' ');

        this.addEmailsToSelect(emailSelector, emails);
        $(buttonSelector).attr('disabled', false);
    }

    addEmailsToSelect(selector, emails) {
        $(selector).empty();
        emails.forEach((email) => {
            const option = $('<option/>', { text: email });
            $(selector).append(option).find('option').prop('selected', true);
        });
    }

    setupSelect2(selector, buttonSelector) {
        $(selector).select2({
            tags: true,
            multiple: true,
            tokenSeparators: [',', ' '],
        });
        this.configureSelect2Input(selector, buttonSelector);
    }

    configureSelect2Input(selector, buttonSelector) {
        const inputSelector = `${selector} .select2-selection input`;
        $(inputSelector).attr({ maxlength: '30', id: `${selector}-input` })
            .on('paste', (e) => this.handlePaste(e, selector, buttonSelector));
        $(selector).on('select2:select select2:unselect', () => {
            this.toggleButtonBasedOnEmails(selector, buttonSelector);
        });
    }

    addMentorToGroup() {
        this.setupSelect2('#group_mentor_emails', '#add-mentor-button');
    }

    addMemberToGroup() {
        this.setupSelect2('#group_member_emails', '#add-members-button');
    }
}
