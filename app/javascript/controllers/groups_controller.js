import { Controller } from 'stimulus';
import 'bootstrap';

export default class extends Controller {
    connect() {
        document.getElementsByClassName("dropdown-toggle")[0].addEventListener('click', () => {
            let collapsedDropdown = document.getElementsByClassName("dropdown-menu")[0];
            if (collapsedDropdown.classList.contains("show")) {
                collapsedDropdown.classList.remove("show");
            }
            else {
                collapsedDropdown.classList.add("show");
            }
        })
        document.getElementsByClassName("dropdown-toggle")[1].addEventListener('click', () => {
            let collapsedDropdown = document.getElementsByClassName("dropdown-menu")[1];
            if (collapsedDropdown.classList.contains("show")) {
                collapsedDropdown.classList.remove("show");
            }
            else {
                collapsedDropdown.classList.add("show");
            }
        })
    }
    addMemberToGroup() {
        $('#group_member_emails').tagsinput({
            trimValue: true,
            confirmKeys: [13, 44, 32],
        });

        $('.bootstrap-tagsinput input').attr('maxlength', '30');
        $('.bootstrap-tagsinput input').attr('id', 'group_email_input');
        $('.add-members-button').attr('disabled', true);
        $('.bootstrap-tagsinput input').on('keyup click', () => {
            if ($('.bootstrap-tagsinput').children().length > 1) {
                $('.add-members-button').attr('disabled', false);
            } else {
                $('.add-members-button').attr('disabled', true);
            }
        });
        document.querySelector('.bootstrap-tagsinput input').addEventListener('paste', (e) => {
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
                newLinesIntoSpacesSplitted.forEach(value => $('#group_member_emails').tagsinput('add', value));
                $('.add-members-button').attr('disabled', false);
            } else {
                const pastedEmailsSplittedBySpace = pastedEmails.split(' ');
                this.value = pastedEmails.replace(/./g, '');
                pastedEmailsSplittedBySpace.forEach(value => $('#group_member_emails').tagsinput('add', value));
                $('.add-members-button').attr('disabled', false);
            }
        });
    }
}
