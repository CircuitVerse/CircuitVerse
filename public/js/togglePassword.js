function toggleLoginPassword() {
    if ($('.users-login-password-input').attr('type') === 'text') {
        $('.users-login-password-input').attr('type', 'password');
        $('#login-toggle-icon').addClass('fa-eye-slash');
        $('#login-toggle-icon').removeClass('fa-eye');
    }
    else {
        $('.users-login-password-input').attr('type', 'text');
        $('#login-toggle-icon').addClass('fa-eye');
        $('#login-toggle-icon').removeClass('fa-eye-slash');
    }
}

function toggleSignupPassword() {
    if ($('.users-signup-password-input').attr('type') === 'text') {
        $('.users-signup-password-input').attr('type', 'password');
        $('#signup-toggle-icon').addClass('fa-eye-slash');
        $('#signup-toggle-icon').removeClass('fa-eye');
    }
    else {
        $('.users-signup-password-input').attr('type', 'text');
        $('#signup-toggle-icon').addClass('fa-eye');
        $('#signup-toggle-icon').removeClass('fa-eye-slash');
    }
}
