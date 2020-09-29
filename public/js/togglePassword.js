function togglePassword() {
    if ($('.users-password-input').attr('type') === 'text') {
        $('.users-password-input').attr('type', 'password');
        $('#toggle-icon').addClass('fa-eye-slash');
        $('#toggle-icon').removeClass('fa-eye');
    } else {
        $('.users-password-input').attr('type', 'text');
        $('#toggle-icon').addClass('fa-eye');
        $('#toggle-icon').removeClass('fa-eye-slash');
    }
}
