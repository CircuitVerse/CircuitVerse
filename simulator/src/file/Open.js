import load from "../data/load";

var circuitData = {};
const GetDialogData = () => '<div><div><label for="CircuitDataFile">Choose a File</label><input style="background:none;" type="file" id="CircuitDataFile"/></div></div>';

export const ImportCircuitFiles = () => {
    $('#ImportCircuitFilesDialog').empty();
    $('#ImportCircuitFilesDialog').append(GetDialogData())
    $('#ImportCircuitFilesDialog').dialog({
        resizable: false,
        buttons: [{
            text: 'Open File',
            click() {
                load(circuitData);
                $(this).dialog('close');
            },
        }],
    });
    $('#ImportCircuitFilesDialog').focus();

    function receivedText(e) {
        circuitData = JSON.parse(e.target.result);
    }
    $('#CircuitDataFile').on('change', (event) => {
        var File = event.target.files[0];
        if (File !== null && File.name.split('.')[1] === 'cv') {
            var fr = new FileReader();
            fr.onload = receivedText;
            fr.readAsText(File);
        } else {
            alert('File Not Supported !');
        }
    });

};
