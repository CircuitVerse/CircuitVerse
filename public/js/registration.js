function chooseStatus(index) {
    var schoolStud = document.getElementById('schoolStudentGrp');
    var collegeStud = document.getElementById('collegeStudentGrp');
    var teacher = document.getElementById('teacherGrp');
    var arrayOfOptions = [schoolStud, collegeStud, teacher];

    schoolStud.style.display = 'none';
    collegeStud.style.display = 'none';
    teacher.style.display = 'none';

    for (i = 0; i < arrayOfOptions.length; i++) {
        arrayOfOptions[i].style.display = 'none';
    }
    if (index == -1){

    } else{
        arrayOfOptions[index].style.display = 'block';
    }
}
