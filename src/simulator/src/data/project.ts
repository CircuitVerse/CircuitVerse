/* eslint-disable guard-for-in */
/* eslint-disable no-bitwise */
/* eslint-disable import/no-cycle */
/* eslint-disable no-restricted-globals */
/* eslint-disable no-alert */
import { resetScopeList, scopeList, newCircuit } from '../circuit'
import { showMessage, showError, generateId } from '../utils'
import { checkIfBackup } from './backupCircuit'
import { generateSaveData, getProjectName, setProjectName } from './save'
import load from './load'
import { SimulatorStore } from '#/store/SimulatorStore/SimulatorStore'
import { confirmOption } from '#/components/helpers/confirmComponent/ConfirmComponent.vue'

/**
 * Helper function to recover unsaved data
 * @category data
 */
export async function recoverProject() {
    if (localStorage.getItem('recover')) {
        const recover = localStorage.getItem('recover')
        const data = recover ? JSON.parse(recover) : {}
        if (await confirmOption(`Would you like to recover: ${data.name}`)) {
            load(data)
        }
        localStorage.removeItem('recover')
    } else {
        showError('No recover project found')
    }
}

/**
 * Prompt to restore from localStorage
 * @category data
 */
export function openOffline() {
    const simulatorStore = SimulatorStore()
    simulatorStore.dialogBox.open_project_dialog = true
    /*
    $('#openProjectDialog').empty()
    const projectList = JSON.parse(localStorage.getItem('projectList'))
    let flag = true
    for (id in projectList) {
        flag = false
        $('#openProjectDialog').append(
            `<label class="option custom-radio"><input type="radio" name="projectId" value="${id}" />${projectList[id]}<span></span><i class="fa fa-trash deleteOfflineProject" onclick="deleteOfflineProject('${id}')"></i></label>`
        )
    }
    if (flag)
        $('#openProjectDialog').append(
            '<p>Looks like no circuit has been saved yet. Create a new one and save it!</p>'
        )
    $('#openProjectDialog').dialog({
        resizable: false,
        width: 'auto',
        buttons: !flag
            ? [
                  {
                      id: 'Open_offline_btn',
                      text: 'Open Project',
                      click() {
                          if (!$('input[name=projectId]:checked').val()) return
                          load(
                              JSON.parse(
                                  localStorage.getItem(
                                      $('input[name=projectId]:checked').val()
                                  )
                              )
                          )
                          window.projectId = $(
                              'input[name=projectId]:checked'
                          ).val()
                          $(this).dialog('close')
                      },
                  },
              ]
            : [],
    })
    */
}
/**
 * Flag for project saved or not
 * @category data
 */
let projectSaved = true
export function projectSavedSet(param: boolean) {
    projectSaved = param
}

/**
 * Helper function to store to localStorage -- needs to be deprecated/removed
 * @category data
 */
export async function saveOffline() {
    const data = await generateSaveData('')
    if (data instanceof Error) return
    const stringData = JSON.stringify(data)
    localStorage.setItem(projectId, stringData)
    const projectList = localStorage.getItem('projectList')
    const temp = projectList ? JSON.parse(projectList) : {}
    temp[projectId] = getProjectName()
    localStorage.setItem('projectList', JSON.stringify(temp))
    showMessage(
        `We have saved your project: ${getProjectName()} in your browser's localStorage`
    )
}

/**
 * Checks if any circuit has unsaved data
 * @category data
 */
function checkToSave() {
    let saveFlag = false
    // eslint-disable-next-line no-restricted-syntax
    for (const id in scopeList) {
        saveFlag = saveFlag || checkIfBackup(scopeList[id])
    }
    return saveFlag
}

/**
 * Prompt user to save data if unsaved
 * @category data
 */
window.onbeforeunload = async function () {
    if (projectSaved || embed) return

    if (!checkToSave()) return

    alert(
        'You have unsaved changes on this page. Do you want to leave this page and discard your changes or stay on this page?'
    )
    // await confirmSingleOption(
    //     'You have unsaved changes on this page. Do you want to leave this page and discard your changes or stay on this page?'
    // )
    const data = await generateSaveData('Untitled')
    const stringData = JSON.stringify(data)
    localStorage.setItem('recover', stringData)
    // eslint-disable-next-line consistent-return
    return 'Are u sure u want to leave? Any unsaved changes may not be recoverable'
}

/**
 * Function to clear project
 */
export async function clearProject() {
    if (await confirmOption('Would you like to clear the project?')) {
        globalScope = undefined
        resetScopeList()
        // $('.circuits').remove()
        newCircuit('main')
        showMessage('Your project is as good as new!')
    }
}

/**
 Function used to start a new project while prompting confirmation from the user
 */
export async function newProject(verify: boolean) {
    if (
        verify ||
        projectSaved ||
        !checkToSave() ||
        (await confirmOption(
            'What you like to start a new project? Any unsaved changes will be lost.'
        ))
    ) {
        clearProject()
        localStorage.removeItem('recover')
        const baseUrl = window.location.origin !== 'null' ? window.location.origin : 'http://localhost:4000';
        window.location.assign(`${baseUrl}/simulatorvue/`);

        setProjectName(undefined)
        projectId = generateId()
        showMessage('New Project has been created!')
    }
}
