function togglePassword() {
    if ($('.users-password-input').attr('type') === 'text') {
        $('.users-password-input').attr('type', 'password');
        $('.password-icon').addClass('fa-eye-slash');
        $('.password-icon').removeClass('fa-eye');
    } else {
        $('.users-password-input').attr('type', 'text');
        $('.password-icon').addClass('fa-eye');
        $('.password-icon').removeClass('fa-eye-slash');
    }
}
