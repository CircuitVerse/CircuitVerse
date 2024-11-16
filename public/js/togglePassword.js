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


function checkPasswordStrength() {
    const password = document.getElementById("password-field").value;
    const strengthBar = document.getElementById("password-strength-bar");
    const strengthText = document.getElementById("password-strength-text");
    const submitButton = document.getElementById("submit-button");
    
    let strength = 0;
    const tests = [
      /[a-z]/, // lowercase
      /[A-Z]/, // uppercase
      /[0-9]/, // numbers
      /[\W_]/, // special characters
    ];
    
    tests.forEach((test) => {
      if (test.test(password)) {
        strength++;
      }
    });
  
    // Update strength bar and text
    if (strength === 0) {
      strengthBar.style.width = "0%";
      strengthBar.style.backgroundColor = "red";
      strengthText.textContent = "Weak";
    } else if (strength === 1) {
      strengthBar.style.width = "25%";
      strengthBar.style.backgroundColor = "orange";
      strengthText.textContent = "Weak";
    } else if (strength === 2) {
      strengthBar.style.width = "50%";
      strengthBar.style.backgroundColor = "yellow";
      strengthText.textContent = "Medium";
    } else if (strength === 3) {
      strengthBar.style.width = "75%";
      strengthBar.style.backgroundColor = "lightgreen";
      strengthText.textContent = "Good";
    } else if (strength === 4) {
      strengthBar.style.width = "100%";
      strengthBar.style.backgroundColor = "green";
      strengthText.textContent = "Strong";
    }
  
    // Disable submit button if password is weak
    submitButton.disabled = strength < 3;
  }