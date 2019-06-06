/*
 Grading
*/
$(".list-group-item-action").on('click', (e) => {
    e.preventDefault();
    $("#assignment-project-id").val(e.currentTarget.id);
    $("#project-grade").html($(e.currentTarget).attr("data-grade"));
    $("#project-grade-error").html("");
});

$("#grade-form-remove").click((e) => {
    e.preventDefault();

    var form = $("#assignment-grade-form");
    var url = form.attr("action");

    $.ajax({
        type: "DELETE",
        url: url,
        data: form.serialize(),
        success: (data) => {
            if (data.project_id != null) {
                $("#project-grade").html("N.A.");
                $(`#${data.project_id}`).attr("data-grade", "N.A.");
            }
        },
    });
});

$("#grade-form-submit").click((e) => {
    e.preventDefault();

    var form = $("#assignment-grade-form");
    var type = $("#assignment-grade-grade").val() === "" ? "DELETE" : "POST";
    var url = form.attr("action");

    $.ajax({
        type: type,
        url: url,
        data: form.serialize(),
        datatype: "json",
        success: (data) => {
            if (type === "POST") {
                $("#project-grade").html(data.grade);
                $(`#${data.project_id}`).attr("data-grade", data.grade);
            } else if (type === "DELETE") {
                if (data.project_id != null) {
                    $("#project-grade").html("N.A.");
                    $(`#${data.project_id}`).attr("data-grade", data.grade);
                }
            }

            $("#project-grade-error").html("");
            $("#assignment-grade-grade").val("");
        },
        error: (data) => {
            $("#project-grade-error").html(`* ${data.responseJSON.error}`);
            $("#assignment-grade-grade").val("");
        },
    });
});
