//Function for password toggler
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

//Function for capsLock Alert
function capsLock(e) {
    var kc = e.keyCode ? e.keyCode : e.which;
    var sk = e.shiftKey ? e.shiftKey : kc === 16;
    var visibility = ((kc >= 65 && kc <=90) && !sk) || ((kc >= 97 && kc <= 122) && sk) ? 'visible' : 'hidden';
    document.getElementById('caps-alert').style.visibility = visibility;
}
