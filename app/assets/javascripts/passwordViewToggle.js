var icon = document.getElementById('hideOrShow');
function toggle() {
    var pass = document.getElementById('formPassword');    
    if (pass.type === 'password') {
        pass.type = "text";
        icon.src = "Eye.png";
    } else {
        pass.type = "password";
        icon.src = "EyeClosed.png";
    }
}

icon.addEventListener('click', toggle);
