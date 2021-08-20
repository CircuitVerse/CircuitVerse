/* eslint-disable guard-for-in */
/* eslint-disable no-bitwise */
/* eslint-disable import/no-cycle */
/* eslint-disable no-restricted-globals */
/* eslint-disable no-alert */
import { resetScopeList, scopeList, newCircuit } from '../circuit';
import { showMessage, showError, generateId } from '../utils';
import { checkIfBackup } from './backupCircuit';
import {generateSaveData, getProjectName, setProjectName} from './save';
import load from './load';
import banana from '../i18n';

/**
 * Helper function to recover unsaved data
 * @category data
 */
export function recoverProject() {
    if (localStorage.getItem('recover')) {
        var data = JSON.parse(localStorage.getItem('recover'));
        if (confirm(banana.i18n('data-project-recover-project', data.name))) {
            load(data);
        }
        localStorage.removeItem('recover');
    } else {
        showError(banana.i18n('data-project-no-recover-project'));
    }
}


/**
 * Prompt to restore from localStorage
 * @category data
 */
export function openOffline() {
    $('#openProjectDialog').empty();
    const projectList = JSON.parse(localStorage.getItem('projectList'));
    let flag = true;
    for (id in projectList) {
        flag = false;
        $('#openProjectDialog').append(`<label class="option custom-radio"><input type="radio" name="projectId" value="${id}" />${projectList[id]}<span></span><i class="fa fa-trash deleteOfflineProject" onclick="deleteOfflineProject('${id}')"></i></label>`);
    }
    if (flag) $('#openProjectDialog').append(banana.i18n('data-project-no-project-saved'));
    $('#openProjectDialog').dialog({
        resizable:false,
        width: 'auto',
        buttons: !flag ? [{
            text: banana.i18n('data-project-buttons-open-project'),
            click() {
                if (!$('input[name=projectId]:checked').val()) return;
                load(JSON.parse(localStorage.getItem($('input[name=projectId]:checked').val())));
                window.projectId = $('input[name=projectId]:checked').val();
                $(this).dialog('close');
            },
        }] : [],

    });
}
/**
 * Flag for project saved or not
 * @type {boolean}
 * @category data
 */
var projectSaved = true;
export function projectSavedSet(param) {
    projectSaved = param;
}


/**
 * Helper function to store to localStorage -- needs to be deprecated/removed
 * @category data
 */
export function saveOffline() {
    const data = generateSaveData();
    localStorage.setItem(projectId, data);
    const temp = JSON.parse(localStorage.getItem('projectList')) || {};
    temp[projectId] = getProjectName();
    localStorage.setItem('projectList', JSON.stringify(temp));
    showMessage(banana.i18n('data-project-project-saved-offline', getProjectName()));
}

/**
 * Checks if any circuit has unsaved data
 * @category data
 */
function checkToSave() {
    let saveFlag = false;
    // eslint-disable-next-line no-restricted-syntax
    for (id in scopeList) {
        saveFlag |= checkIfBackup(scopeList[id]);
    }
    return saveFlag;
}

/**
 * Prompt user to save data if unsaved
 * @category data
 */
window.onbeforeunload = function () {
    if (projectSaved || embed) return;

    if (!checkToSave()) return;

    alert(banana.i18n('data-project-alert-unsaved-changes'));
    const data = generateSaveData('Untitled');
    localStorage.setItem('recover', data);
    // eslint-disable-next-line consistent-return
    return banana.i18n('data-project-leave-page');
};


/**
 * Function to clear project
 * @category data
 */
export function clearProject() {
    if (confirm(banana.i18n('data-project-clear-project'))) {
        globalScope = undefined;
        resetScopeList();
        $('.circuits').remove();
        newCircuit('main');
        showMessage(banana.i18n('data-project-project-cleared'));
    }
}

/**
 Function used to start a new project while prompting confirmation from the user
 * @param {boolean} verify - flag to verify a new project
 * @category data
 */
export function newProject(verify) {
    if (verify || projectSaved || !checkToSave() || confirm(banana.i18n('data-project-start-new-project'))) {
        clearProject();
        localStorage.removeItem('recover');
        window.location = '/simulator';

        setProjectName(undefined);
        projectId = generateId();
        showMessage(banana.i18n('data-project-new-project-created'));
    }
}