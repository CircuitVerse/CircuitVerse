function toggle(){
  var pass = document.getElementById("formPassword");
  var icon = document.getElementById("hideOrShow");
  if(pass.type == "password"){
      pass.type = "text";
      icon.src = "Eye.png";
  } else{
      pass.type = "password";
      icon.src = "EyeClosed.png";
  }
}
