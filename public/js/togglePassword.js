function togglePassword(element) {
    const $button = $(element);
    const $input = $button.siblings('.users-password-input');
    const $icon = $button.find('.password-icon');

    if ($input.attr('type') === 'text') {
        $input.attr('type', 'password');
        $icon.addClass('fa-eye-slash');
        $icon.removeClass('fa-eye');
    } else {
        $input.attr('type', 'text');
        $icon.addClass('fa-eye');
        $icon.removeClass('fa-eye-slash');
    }
}
