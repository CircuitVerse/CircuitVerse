import { download, generateSaveData } from '../data/save';

const GetDialogData = () => {
    const fileName = `${$('#projectName').text().trim()}.cv`;
    const Input = document.createElement('input');
    Input.type = 'text';
    Input.name = 'fileName';
    Input.setAttribute('placeholder', fileName);
    Input.id = 'filename';
    const Label = document.createElement('label');
    Label.setAttribute('for', 'filename');
    Label.textContent = 'File Name';
    const container = document.createElement('div');
    container.appendChild(Label);
    container.appendChild(Input);
    return container;
};

/**
 * To Export Circuit Files
 */
export const ExportCircuitFiles = () => {
    $('#ExportCircuitFilesDialog').empty();
    $('#ExportCircuitFilesDialog').append(GetDialogData());
    $('#ExportCircuitFilesDialog').dialog({
      resizable: false,
      buttons: [
        {
          text: 'Save',
          click() {
            var fileName = $('#projectName').text().trim() || 'untitled';
            const circuitData = generateSaveData(fileName);
            fileName = fileName.split('.')[0] + '.cv';
            download(fileName, circuitData);
            $(this).dialog('close');
          },
        }],
    });
    $('#ExportCircuitFilesDialog').focus();
};
