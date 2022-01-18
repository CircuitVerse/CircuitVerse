import { Controller } from 'stimulus';

export default class extends Controller {
    connect() {
        $('#project_tags').tagsinput({
            trimValue: true,
            confirmKeys: [13, 44, 32],
        });

        $('.bootstrap-tagsinput input').attr('maxlength', '30');
        $('.bootstrap-tagsinput input').attr('id', 'project_tags_input');
        $('.add-members-button').attr('disabled', true);
        $('.bootstrap-tagsinput input').on('keyup click', () => {
            if ($('.bootstrap-tagsinput').children().length > 1) {
                $('.add-members-button').attr('disabled', false);
            } else {
                $('.add-members-button').attr('disabled', true);
            }
        });
        $('.bootstrap-tagsinput').css('overflow-y', 'hidden');
        $('.bootstrap-tagsinput').css('border-radius', '0');
        $('.bootstrap-tagsinput').css('min-height', '38px');
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
                newLinesIntoSpacesSplitted.forEach((value) => $('#project_tags').tagsinput('add', value));
                $('.add-members-button').attr('disabled', false);
            } else {
                const pastedEmailsSplittedBySpace = pastedEmails.split(' ');
                this.value = pastedEmails.replace(/./g, '');
                pastedEmailsSplittedBySpace.forEach((value) => $('#project_tags').tagsinput('add', value));
                $('.add-members-button').attr('disabled', false);
            }
        });
    }
}
