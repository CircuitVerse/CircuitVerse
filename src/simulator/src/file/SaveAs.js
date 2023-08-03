/* **************************************************************************************************** */
/* Implemented in ExportProject.vue Kept for reference in case any bugs occur */
/* TODO: Remove this file after testing */
/* **************************************************************************************************** */

// import { download, generateSaveData } from '../data/save'
// import { escapeHtml } from '../ux'

// const GetDialogData = () => {
//     const fileName = `${$('#projectName').text().trim()}.cv`
//     const Input = document.createElement('input')
//     Input.type = 'text'
//     Input.name = 'fileName'
//     Input.setAttribute('placeholder', fileName)
//     Input.id = 'filename'
//     Input.defaultValue = fileName
//     const Label = document.createElement('label')
//     Label.setAttribute('for', 'filename')
//     Label.textContent = 'File Name'
//     const container = document.createElement('div')
//     container.appendChild(Label)
//     container.appendChild(Input)
//     return container
// }

// /**
//  * To Export Circuit Files
//  */
// const ExportCircuitFiles = () => {
//     $('#ExportCircuitFilesDialog').empty()
//     $('#ExportCircuitFilesDialog').append(GetDialogData())
//     $('#ExportCircuitFilesDialog').dialog({
//         resizable: false,
//         buttons: [
//             {
//                 text: 'Save',
//                 click() {
//                     var fileName =
//                         escapeHtml($('#filename').val()) || 'untitled'
//                     const circuitData = generateSaveData(
//                         fileName.split('.')[0],
//                         false
//                     )
//                     fileName = `${fileName.split('.')[0]}.cv`
//                     download(fileName, circuitData)
//                     $(this).dialog('close')
//                 },
//             },
//         ],
//     })
//     $('#ExportCircuitFilesDialog').focus()
// }

// export default ExportCircuitFiles
