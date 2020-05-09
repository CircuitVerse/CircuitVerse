function toggleLoginPassword() {
  if($('#password-input').attr("type") == "text"){
    $('#password-input').attr('type', 'password')
    $('#toggle-icon').addClass( "fa-eye-slash" );
    $('#toggle-icon').removeClass( "fa-eye" );
  }
  else {
    $('#password-input').attr('type', 'text')
    $('#toggle-icon').addClass( "fa-eye" );
    $('#toggle-icon').removeClass( "fa-eye-slash" );
  }
};

function toggleSignupPassword() {
  if($('#signup-psw').attr("type") == "text"){
    $('#signup-psw').attr('type', 'password')
    $('#toggle-psw-icon').addClass( "fa-eye-slash" );
    $('#toggle-psw-icon').removeClass( "fa-eye" );
  }
  else {
    $('#signup-psw').attr('type', 'text')
    $('#toggle-psw-icon').addClass( "fa-eye" );
    $('#toggle-psw-icon').removeClass( "fa-eye-slash" );
  }
}