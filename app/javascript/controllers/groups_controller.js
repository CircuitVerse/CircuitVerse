import { Controller } from 'stimulus';

export default class extends Controller {
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
            const newLinesIntoSpacesSplitted = newLinesIntoSpaces.split(' ');
            this.value = pastedEmails.replace(/./g, '');
            newLinesIntoSpacesSplitted.forEach((value) => {
                var tags = $('<option/>', { text: value });
                $('#group_mentor_emails').append(tags);
                $('#group_mentor_emails option').prop('selected', true);
            });
            $('.add-mentor-button').attr('disabled', false);
        } else {
            const pastedEmailsSplittedBySpace = pastedEmails.split(' ');
            this.value = pastedEmails.replace(/./g, '');
            pastedEmailsSplittedBySpace.forEach((value) => {
                var tags = $('<option/>', { text: value });
                $('#group_mentor_emails').append(tags);
                $('#group_mentor_emails option').prop('selected', true);
            });
            $('.add-mentor-button').attr('disabled', false);
        }
    }

    addMentorToGroup() {
        $('#group_mentor_emails').select2({
            tags: true,
            multiple: true,
            tokenSeparators: [',', ' '],
        });
        $('.select2-selection input').attr('maxlength', '30');
        $('.select2-selection input').attr('id', 'group_email_input_mentor');
        $('.add-mentor-button').attr('disabled', true);
        if ($('#group_mentor_emails').select2('data').length > 0) {
            $('.add-mentor-button').attr('disabled', false);
        }
        $('.select2-selection input').attr('data-action', 'paste->groups#mentorInputPaste');
        $('#group_mentor_emails').on('select2:select select2:unselect', () => {
            $('.add-mentor-button').attr('disabled', true);
            if ($('#group_mentor_emails').select2('data').length > 0) {
                $('.add-mentor-button').attr('disabled', false);
            }
        });
    }

    addMemberToGroup() {
        $('#group_member_emails').select2({
            tags: true,
            multiple: true,
            tokenSeparators: [',', ' '],
        });
        $('.select2-selection input').attr('maxlength', '30');
        $('.select2-selection input').attr('id', 'group_email_input');
        $('.add-members-button').attr('disabled', true);
        if ($('#group_member_emails').select2('data').length > 0) {
            $('.add-members-button').attr('disabled', false);
        }
        $('#group_member_emails').on('select2:select select2:unselect', () => {
            $('.add-members-button').attr('disabled', true);
            if ($('#group_member_emails').select2('data').length > 0) {
                $('.add-members-button').attr('disabled', false);
            }
        });
        document.querySelector('.select2-selection input').addEventListener('paste', (e) => {
            e.preventDefault();
            let pastedEmails = '';
            if (window.clipboardData && window.clipboardData.getData) {
                pastedEmails = window.clipboardData.getData('Text');
            } else if (e.clipboardData && e.clipboardData.getData) {
                pastedEmails = e.clipboardData.getData('text/plain');
            }

            if (pastedEmails.includes('\n')) {
                const newLinesIntoSpaces = pastedEmails.replace(/\n/g, ' ');
                const newLinesIntoSpacesSplitted = newLinesIntoSpaces.split(' ');
                this.value = pastedEmails.replace(/./g, '');
                newLinesIntoSpacesSplitted.forEach((value) => {
                    var tags = $('<option/>', { text: value });
                    $('#group_member_emails').append(tags);
                    $('#group_member_emails option').prop('selected', true);
                });
                $('.add-members-button').attr('disabled', false);
            } else {
                const pastedEmailsSplittedBySpace = pastedEmails.split(' ');
                this.value = pastedEmails.replace(/./g, '');
                pastedEmailsSplittedBySpace.forEach((value) => {
                    var tags = $('<option/>', { text: value });
                    $('#group_member_emails').append(tags);
                    $('#group_member_emails option').prop('selected', true);
                });
                $('.add-members-button').attr('disabled', false);
            }
        });
    }
}
