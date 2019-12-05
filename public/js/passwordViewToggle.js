function toggle() {
    var icon = document.getElementById('hideOrShow');
    var pass = document.getElementById('formPassword');
    if (pass.type === 'password') {
        pass.type = 'text';
        icon.src = 'Eye.png';
        icon.alt = 'Hide Password';
    } else {
        pass.type = 'password';
        icon.src = 'EyeClosed.png';
        icon.alt = 'Reveal Password';
    }
}
