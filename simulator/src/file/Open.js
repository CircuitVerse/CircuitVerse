import load from '../data/load';
import { generateSaveData } from '../data/save';
import { escapeHtml } from '../ux';

const scopeSchema = ['layout', 'verilogMetadata', 'allNodes', 'id', 'name', 'restrictedCircuitElementsUsed', 'nodes'];
const JSONSchema = ['name', 'timePeriod', 'clockEnabled', 'projectId', 'focussedCircuit', 'orderedTabs', 'scopes'];

var circuitData = null;
const GetDialogData = () => '<div><label for="CircuitDataFile">Choose file</label><div id="message-box"><i class="fas fa-plus"></i><br/>Browse files or Drag & Drop files here<div id="message">No file chosen!!</div><input style="background:none;" type="file" id="CircuitDataFile"/></div></div>';

const ImportCircuitFiles = () => {
    $('#ImportCircuitFilesDialog').empty();
    $('#ImportCircuitFilesDialog').append(GetDialogData());
    $('#ImportCircuitFilesDialog').dialog({
        resizable: false,
        close() {
            if (circuitData) load(circuitData);
        },
        buttons: [
            {
                text: 'Close',
                click() {
                    $(this).dialog('close');
                },
            },
        ],
    });
    $('#ImportCircuitFilesDialog').focus();

    function ValidateData(fileData) {
        try {
            const parsedFileDate = JSON.parse(fileData);
            if (JSON.stringify(Object.keys(parsedFileDate)) !== JSON.stringify(JSONSchema)) throw new Error('Invalid JSON data');
            parsedFileDate.scopes.forEach((scope) => {
                const keys = Object.keys(scope); // get scope keys
                scopeSchema.forEach((key) => {
                    if (!keys.includes(key)) throw new Error('Invalid Scope data');
                });
            });
            load(parsedFileDate);
            return true;
        } catch (error) {
            $('#message').text('Invalid file format');
            return false;
        }
    }

    function receivedText(e) {
        // backUp data
        const backUp = JSON.parse(generateSaveData(escapeHtml($('#projectName').text()).trim(), false));
        const valid = ValidateData(e.target.result); // validate data
        if (!valid) {
            // fallback
            load(backUp);
        } else {
            $('#ImportCircuitFilesDialog').dialog('close');
        }
    }
    $('#CircuitDataFile').on('change', (event) => {
        var File = event.target.files[0];
        var fr = new FileReader();
        fr.onload = receivedText;
        fr.readAsText(File);
    });
};

export default ImportCircuitFiles;
