truthTablePrompt = function(scope = globalScope) {
    $('#truthTable').empty();
    $('#truthTable').append("<p>Please make sure that the inputs and outputs are labeled.</p>");
    $('#truthTable').append("<p>The unlabelled inputs and outputs will be shown as NL.</p>");
    $('#truthTable').dialog({
        width: "auto",
        buttons: [{
            text: "Generate Truth Table",
            click: function() {
                $(this).dialog("close");
                createTruthTable();
            },
        }]

    });

}

function createTruthTable(scope = globalScope) {
    inputLabels = [];
    outputLabels = [];
    var matrix = [];

    function generateOutput(outputIndex, decIndex) {
        for (var i = 0; i < scope.Input.length; i++) {
            scope.Input[i].state = matrix[i][decIndex];                         //Change the input values
        }
        updateSimulation = true;
        updateSubcircuit = true;
        updateCanvas = true;
        update(globalScope, true);                                              //Update Simulation
        return scope.Output[outputIndex].state;
    }

    for (var i = 0; i < scope.Input.length; i++) {
        inputLabels[i] = [scope.Input[i].label, scope.Input[i].state];          //Store the labels and initial state of input
    }

    for (var i = 0; i < scope.Output.length; i++) {
        outputLabels[i] = scope.Output[i].label;                                //Store the labels of outputs
    }

    var s = '<table>';                                                          //Creation of table
    s += '<tbody style="display:block; max-height:70vh; overflow-y:scroll" >';
    s += '<tr>';

    for (var i = 0; i < scope.Input.length; i++)
        s += '<th>' + (inputLabels[i][0] != "" ? inputLabels[i][0] : "NL") + '</th>';
    for (var i = 0; i < outputLabels.length; i++)
        s += '<th>' + (outputLabels[i] != "" ? outputLabels[i][0] : "NL") + '</th>';
    s += '</tr>';


    for (var i = 0; i < scope.Input.length; i++) {
        matrix[i] = new Array((1 << scope.Input.length));
    }

    for (var i = 0; i < scope.Input.length; i++) {
        for (var j = 0; j < (1 << scope.Input.length); j++) {
            matrix[i][j] = (+((j & (1 << (scope.Input.length - i - 1))) != 0));
        }
    }
    for (var j = 0; j < (1 << scope.Input.length); j++) {
        s += '<tr>';

        for (var i = 0; i < scope.Input.length; i++) {
            s += '<td>' + matrix[i][j] + '</td>';
        }
        for (var i = 0; i < outputLabels.length; i++) {

            s += '<td class ="output ' + i + '" id="' + j + '">' + generateOutput(i, j) + '</td>';
            //using hash values as they'll be used in the generateBooleanTableData function
        }
        s += '</tr>';
    }

    s += '</tbody>';
    s += '</table>';

    for (var i = 0; i < scope.Input.length; i++) {
        scope.Input[i].state = inputLabels[i][1];                               //Return the inputs to their initial state
    }
    $('#truthTable').empty()
    if (scope.Input.length == 0 && scope.Output.length == 0)
        $('#truthTable').append("<p>There are no inputs or outputs.</p>")
    $('#truthTable').append(s)

    $('#truthTable').dialog({
        width: "auto",
        buttons: [{
            text: scope.Input.length ? "Download Truth Table" : "Ok",
            click: function() {
                if (scope.Input.length)
                    createCSV(scope.name + '(' + getTimeFormatted() + ')');
                $(this).dialog("close");
            },
        }]

    });
}


function getTimeFormatted() {
    var now = new Date();
    var y = now.getFullYear();
    var m = now.getMonth() + 1;
    var d = now.getDate();
    var h = now.getHours();
    var mi = now.getMinutes();
    var s = now.getSeconds();
    return y + "-" + m + "-" + d + " " + h + "." + mi + "." + s;
}

function createCSV(name) {                                                      //Create a CSV of the truthTable
    var csv = [];
    var rows = document.querySelectorAll("table tr");

    for (var i = 0; i < rows.length; i++) {
        var row = [],
            cols = rows[i].querySelectorAll("td, th");

        for (var j = 0; j < cols.length; j++)
            row.push(cols[j].innerText);

        csv.push(row.join(","));
    }

    downloadCSV(csv.join("\n"), name);
}

function downloadCSV(csv, name) {
    var csvFile;
    var downloadLink;
    csvFile = new Blob([csv], {
        type: "text/csv"
    });
    downloadLink = document.createElement("a");
    downloadLink.download = name + '.csv';
    downloadLink.href = window.URL.createObjectURL(csvFile);
    downloadLink.style.display = "none";
    document.body.appendChild(downloadLink);
    downloadLink.click();
}
