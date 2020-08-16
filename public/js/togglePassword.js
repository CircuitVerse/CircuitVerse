function toggleLoginPassword() {
    if ($('#login-password-input').attr('type') === 'text') {
        $('#login-password-input').attr('type', 'password');
        $('#login-toggle-icon').addClass('fa-eye-slash');
        $('#login-toggle-icon').removeClass('fa-eye');
    }
    else {
        $('#login-password-input').attr('type', 'text');
        $('#login-toggle-icon').addClass('fa-eye');
        $('#login-toggle-icon').removeClass('fa-eye-slash');
    }
}

function toggleSignupPassword() {
    if ($('#signup-password-input').attr('type') === 'text') {
        $('#signup-password-input').attr('type', 'password');
        $('#signup-toggle-icon').addClass('fa-eye-slash');
        $('#signup-toggle-icon').removeClass('fa-eye');
    }
    else {
        $('#signup-password-input').attr('type', 'text');
        $('#signup-toggle-icon').addClass('fa-eye');
        $('#signup-toggle-icon').removeClass('fa-eye-slash');
    }
}
