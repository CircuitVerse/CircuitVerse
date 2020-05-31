import simulationArea from './simulationArea';
import { scheduleUpdate, play } from './engine';

window.width = undefined;
window.height = undefined;

window.scopeList = {};
window.globalScope = undefined;
window.unit = 10; // size of each division/ not used everywhere, to be deprecated
window.uniqueIdCounter = 10; // size of each division/ not used everywhere, to be deprecated
window.embed = false; // true if embed mode
window.wireToBeChecked = 0; // when node disconnects from another node
window.willBeUpdated = false; // scheduleUpdate() will be called if true
window.objectSelection = false; // Flag for object selection
window.errorDetected = false; // Flag for error detection
window.projectId = undefined;
window.id = undefined;
window.prevErrorMessage = undefined; // Global variable for error messages
window.prevShowMessage = undefined; // Global variable for error messages
window.prevPropertyObj = undefined;
window.updatePosition = true; // Flag for updating position
window.updateSimulation = true; // Flag for updating simulation
window.updateCanvas = true; // Flag for rendering
window.gridUpdate = true; // Flag for updating grid
window.updateSubcircuit = true; // Flag for updating subCircuits

window.loading = false; // Flag - all assets are loaded

window.DPR = 1; // devicePixelRatio, 2 for retina displays, 1 for low resolution displays

window.projectSaved = true; // Flag for project saved or not
window.canvasMessageData = undefined; //  Globally set in draw fn ()

window.lightMode = false; // To be deprecated

window.layoutMode = false; // Flag for mode

window.forceResetNodes = true; // FLag to reset all Nodes


export function generateId() {
    var id = '';
    var possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

    for (var i = 0; i < 20; i++) { id += possible.charAt(Math.floor(Math.random() * possible.length)); }

    return id;
}

// To strip tags from input
export function stripTags(string = '') {
    return string.replace(/(<([^>]+)>)/ig, '').trim();
}


export function clockTick() {
    if (!simulationArea.clockEnabled) return;
    if (errorDetected) return;
    updateCanvas = true;
    globalScope.clockTick();
    play();
    scheduleUpdate(0, 20);
}

/**
 * Helper function to show error
 * @param {string} error -The error to be shown
 */
export function showError(error) {
    errorDetected = true;
    // if error ha been shown return
    if (error === prevErrorMessage) return;
    prevErrorMessage = error;
    var id = Math.floor(Math.random() * 10000);
    $('#MessageDiv').append(`<div class='alert alert-danger' role='alert' id='${id}'> ${error}</div>`);
    setTimeout(() => {
        prevErrorMessage = undefined;
        $(`#${id}`).fadeOut();
    }, 1500);
}

// Helper function to show message
export function showMessage(mes) {
    if (mes === prevShowMessage) return;
    prevShowMessage = mes;
    var id = Math.floor(Math.random() * 10000);
    $('#MessageDiv').append(`<div class='alert alert-success' role='alert' id='${id}'> ${mes}</div>`);
    setTimeout(() => {
        prevShowMessage = undefined;
        $(`#${id}`).fadeOut();
    }, 2500);
}

export function distance(x1, y1, x2, y2) {
    return Math.sqrt((x2 - x1) ** 2) + ((y2 - y1) ** 2);
}

/**
 * Helper function to return unique list
 * @param {Array} a - any array
 */
export function uniq(a) {
    var seen = {};
    const tmp = a.filter((item) => (seen.hasOwnProperty(item) ? false : (seen[item] = true)));
    return tmp;
}
