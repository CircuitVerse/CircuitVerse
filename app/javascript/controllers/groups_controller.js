import { Controller } from 'stimulus';

export default class extends Controller {
    /**
     * Initializes modal event listeners when the controller is connected.
     * Sets up dynamic action URLs for promote and demote member modals.
     */
    connect() {
        $('#promote-member-modal').on('show.bs.modal', (e) => {
            const groupmember = $(e.relatedTarget).data('currentgroupmember');
            $(e.currentTarget).find('#groups-member-promote-button').parent().attr('action',
                `/group_members/${groupmember.toString()}`);
        });
        $('#demote-member-modal').on('show.bs.modal', (e) => {
            const groupmember = $(e.relatedTarget).data('currentgroupmember');
            $(e.currentTarget).find('#groups-member-demote-button').parent().attr('action',
                `/group_members/${groupmember.toString()}`);
        });
    }

    /**
     * Toggles the disabled state of a button based on whether emails are selected.
     * @param {string} emailSelector - The jQuery selector for the Select2 email input
     * @param {string} buttonSelector - The jQuery selector for the button to toggle
     */
    toggleButtonBasedOnEmails(emailSelector, buttonSelector) {
        if ($(emailSelector).select2('data').length > 0) {
            $(buttonSelector).attr('disabled', false);
        } else {
            $(buttonSelector).attr('disabled', true);
        }
    }

    /**
     * Handles the paste event for the mentor email input.
     * Trims and truncates pasted emails to a maximum of 254 characters
     * to prevent bypassing backend limits.
     * @param {ClipboardEvent} e - The paste event object
     */
    mentorInputPaste(e) {
        e.preventDefault();
        let pastedEmails = '';
        if (window.clipboardData && window.clipboardData.getData) {
            pastedEmails = window.clipboardData.getData('Text');
        } else if (e.clipboardData && e.clipboardData.getData) {
            pastedEmails = e.clipboardData.getData('text/plain');
        }

        if (pastedEmails.includes('\n')) {
            const newLinesIntoSpaces = pastedEmails.replace(/\n/g, ' ');
            const newLinesIntoSpacesSplit = newLinesIntoSpaces.split(' ');
            this.value = pastedEmails.replace(/./g, '');
            newLinesIntoSpacesSplit.forEach((value) => {
                const trimmedEmail = value.trim().slice(0, 254);
                if (trimmedEmail.length > 0) {
                    var tags = $('<option/>', { text: trimmedEmail });
                    $('#group_mentor_emails').append(tags);
                    $('#group_mentor_emails option').prop('selected', true);
                }
            });
            $('#add-mentor-button').attr('disabled', false);
        } else {
            const pastedEmailsSplitBySpace = pastedEmails.split(' ');
            this.value = pastedEmails.replace(/./g, '');
            pastedEmailsSplitBySpace.forEach((value) => {
                const trimmedEmail = value.trim().slice(0, 254);
                if (trimmedEmail.length > 0) {
                    var tags = $('<option/>', { text: trimmedEmail });
                    $('#group_mentor_emails').append(tags);
                    $('#group_mentor_emails option').prop('selected', true);
                }
            });
            $('#add-mentor-button').attr('disabled', false);
        }
    }

    /**
     * Initializes the Select2 input for adding mentors to a group.
     * Sets up length limits and custom paste event listeners.
     */
    addMentorToGroup() {
        $('#group_mentor_emails').select2({
            tags: true,
            multiple: true,
            tokenSeparators: [',', ' '],
        });
        const mentorInput = $('#group_mentor_emails').next('.select2-container').find('.select2-selection input');
        mentorInput.attr('maxlength', '30');
        mentorInput.attr('id', 'group_email_input_mentor');
        this.toggleButtonBasedOnEmails('#group_mentor_emails', '#add-mentor-button');
        mentorInput.attr('data-action', 'paste->groups#mentorInputPaste');
        $('#group_mentor_emails').on('select2:select select2:unselect', () => {
            this.toggleButtonBasedOnEmails('#group_mentor_emails', '#add-mentor-button');
        });
    }

    /**
     * Initializes the Select2 input for adding members to a group.
     * Sets up length limits and inline paste event listeners for members.
     */
    addMemberToGroup() {
        $('#group_member_emails').select2({
            tags: true,
            multiple: true,
            tokenSeparators: [',', ' '],
        });
        const memberInput = $('#group_member_emails').next('.select2-container').find('.select2-selection input');
        memberInput.attr('maxlength', '30');
        memberInput.attr('id', 'group_email_input');
        this.toggleButtonBasedOnEmails('#group_member_emails', '#add-members-button');
        $('#group_member_emails').on('select2:select select2:unselect', () => {
            this.toggleButtonBasedOnEmails('#group_member_emails', '#add-members-button');
        });
        memberInput[0].addEventListener('paste', (e) => {
            e.preventDefault();
            let pastedEmails = '';
            if (window.clipboardData && window.clipboardData.getData) {
                pastedEmails = window.clipboardData.getData('Text');
            } else if (e.clipboardData && e.clipboardData.getData) {
                pastedEmails = e.clipboardData.getData('text/plain');
            }

            if (pastedEmails.includes('\n')) {
                const newLinesIntoSpaces = pastedEmails.replace(/\n/g, ' ');
                const newLinesIntoSpacesSplit = newLinesIntoSpaces.split(' ');
                this.value = pastedEmails.replace(/./g, '');
                newLinesIntoSpacesSplit.forEach((value) => {
                    const trimmedEmail = value.trim().slice(0, 254);
                    if (trimmedEmail.length > 0) {
                        var tags = $('<option/>', { text: trimmedEmail });
                        $('#group_member_emails').append(tags);
                        $('#group_member_emails option').prop('selected', true);
                    }
                });
                $('#add-members-button').attr('disabled', false);
            } else {
                const pastedEmailsSplitBySpace = pastedEmails.split(' ');
                this.value = pastedEmails.replace(/./g, '');
                pastedEmailsSplitBySpace.forEach((value) => {
                    const trimmedEmail = value.trim().slice(0, 254);
                    if (trimmedEmail.length > 0) {
                        var tags = $('<option/>', { text: trimmedEmail });
                        $('#group_member_emails').append(tags);
                        $('#group_member_emails option').prop('selected', true);
                    }
                });
                $('#add-members-button').attr('disabled', false);
            }
        });
    }
}
