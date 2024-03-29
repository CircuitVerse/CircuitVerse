/*
 Grading
*/

document.querySelectorAll('.list-group-item-action').forEach((item) => {
    item.addEventListener('click', (e) => {
        e.preventDefault();
        document.getElementById('assignment-project-id').value = e.currentTarget.id;
        document.getElementById('project-grade').innerHTML = e.currentTarget.getAttribute('data-grade');
        document.getElementById('project-remarks').innerHTML = e.currentTarget.getAttribute('data-remarks');
        document.getElementById('project-grade-error').innerHTML = '';
    });
});

document.getElementById('grade-form-remove').addEventListener('click', (e) => {
    e.preventDefault();

    var form = document.getElementById('assignment-grade-form');
    var url = form.getAttribute('action');

    var xhr = new XMLHttpRequest();
    xhr.open('DELETE', url);
    xhr.onreadystatechange = function () {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            var data = JSON.parse(xhr.responseText);
            if (data.project_id != null) {
                document.getElementById('project-grade').innerHTML = 'N.A.';
                document.getElementById(data.project_id).setAttribute('data-grade', 'N.A.');
                document.getElementById('project-remarks').innerHTML = 'N.A.';
                document.getElementById(data.project_id).setAttribute('data-remarks', 'N.A.');
            }
        }
    };
    xhr.send(new FormData(form));
});

document.getElementById('grade-form-finalized').addEventListener('click', (e) => {
    e.preventDefault();

    var url = `${e.currentTarget.dataset.url}.json`;

    if (window.confirm('Do you want to finalize grades?')) {
        var xhr = new XMLHttpRequest();
        xhr.open('PUT', url);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                document.getElementById('assignment-grade-form').innerHTML = 'Grades have been finalized!';
            }
        };
        xhr.send(JSON.stringify({ assignment: { grades_finalized: true } }));
    }
});

document.getElementById('grade-form-submit').addEventListener('click', (e) => {
    e.preventDefault();

    var form = document.getElementById('assignment-grade-form');
    var type = 'POST';
    var url = form.getAttribute('action');

    if (document.getElementById('assignment-grade-grade').value !== '' || document.getElementById('assignment-grade-remarks').value !== '') {
        var xhr = new XMLHttpRequest();
        xhr.open(type, url);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var data = JSON.parse(xhr.responseText);
                const gradeRemarks = data.remarks !== null ? data.remarks : 'N.A.';
                document.getElementById('project-grade').innerHTML = data.grade;
                document.getElementById('project-remarks').innerHTML = gradeRemarks;
                document.getElementById(data.project_id).setAttribute('data-grade', data.grade);
                document.getElementById(data.project_id).setAttribute('data-remarks', gradeRemarks);
                document.getElementById('project-grade-error').innerHTML = '';
                document.getElementById('assignment-grade-grade').value = '';
                document.getElementById('assignment-grade-remarks').value = '';
            }
        };
        xhr.send(new URLSearchParams(new FormData(form)).toString());
    }
});
