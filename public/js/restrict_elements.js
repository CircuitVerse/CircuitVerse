$(document).ready(() => {
    $('#restrict-elements').change((e) => {
        e.preventDefault();
        const radio = $(e.currentTarget);

        if (radio.is(':checked')) {
            $('.restricted-elements-list').removeClass('display--none');
        } else {
            $('.restricted-elements-list').addClass('display--none');
        }
    });

    $('#restrict-elements').trigger('change');
});
