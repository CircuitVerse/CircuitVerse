/* eslint-disable import/no-cycle */
/* eslint-disable guard-for-in */
/* eslint-disable no-restricted-syntax */
/* eslint-disable no-restricted-syntax */
/* eslint-disable guard-for-in */

import { layoutModeGet } from './layoutMode'
import {
    scheduleUpdate,
    wireToBeCheckedSet,
    updateCanvasSet,
    update,
    updateSimulationSet,
} from './engine'
import simulationArea from './simulationArea'
import logixFunction from './data'
import { newCircuit, circuitProperty } from './circuit'
import modules from './modules'
import { updateRestrictedElementsInScope } from './restrictedElementDiv'
import { paste } from './events'
import { setProjectName, getProjectName } from './data/save'
import { changeScale } from './canvasApi'
import updateTheme from './themer/themer'
import { generateImage, generateSaveData } from './data/save'
import { setupVerilogExportCodeWindow } from './verilog'
import { setupBitConvertor } from './utils'
import { updateTestbenchUI, setupTestbenchUI } from './testbench'
import { applyVerilogTheme } from './Verilog2CV'

export const uxvar = {
    smartDropXX: 50,
    smartDropYY: 80,
}
/**
 * @type {number} - Is used to calculate the position where an element from sidebar is dropped
 * @category ux
 */
uxvar.smartDropXX = 50

/**
 * @type {number} - Is used to calculate the position where an element from sidebar is dropped
 * @category ux
 */
uxvar.smartDropYY = 80

// ------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------
/**
 * @type {Object} - Object stores the position of context menu;
 * @category ux
 */
var ctxPos = {
    x: 0,
    y: 0,
    visible: false,
}
// FUNCITON TO SHOW AND HIDE CONTEXT MENU
function hideContextMenu() {
    var el = document.getElementById('contextMenu')
    el.style = 'opacity:0;'
    setTimeout(() => {
        el.style = 'visibility:hidden;'
        ctxPos.visible = false
    }, 200) // Hide after 2 sec
}
/**
 * Function displays context menu
 * @category ux
 */
function showContextMenu() {
    if (layoutModeGet()) return false // Hide context menu when it is in Layout Mode
    document.getElementById('contextMenu').style.visibility = 'visible';
    document.getElementById('contextMenu').style.opacity = 1;

    var windowHeight =
    document.getElementById('simulationArea').clientHeight - document.getElementById('contextMenu').clientHeight - 10
    var windowWidth =
    document.getElementById('simulationArea').clientWidth - document.getElementById('contextMenu').clientWidth - 10
    // for top, left, right, bottom
    var topPosition
    var leftPosition
    var rightPosition
    var bottomPosition
    if (ctxPos.y > windowHeight && ctxPos.x <= windowWidth) {
        //When user click on bottom-left part of window
        leftPosition = ctxPos.x
        bottomPosition = document.body.clientHeight - ctxPos.y
        document.getElementById('contextMenu').style.left = `${leftPosition}px`;
        document.getElementById('contextMenu').style.bottom = `${bottomPosition}px`;
        document.getElementById('contextMenu').style.right = 'auto';
        document.getElementById('contextMenu').style.top = 'auto';  
    } else if (ctxPos.y > windowHeight && ctxPos.x > windowWidth) {
        //When user click on bottom-right part of window
        bottomPosition = document.body.clientHeight - ctxPos.y
        rightPosition = document.body.clientWidth - ctxPos.x
        document.getElementById('contextMenu').style.left = 'auto';
        document.getElementById('contextMenu').style.bottom = `${bottomPosition}px`;
        document.getElementById('contextMenu').style.right = `${rightPosition}px`;
        document.getElementById('contextMenu').style.top = 'auto';
    } else if (ctxPos.y <= windowHeight && ctxPos.x <= windowWidth) {
        //When user click on top-left part of window
        leftPosition = ctxPos.x
        topPosition = ctxPos.y
        document.getElementById('contextMenu').style.left = `${leftPosition}px`;
        document.getElementById('contextMenu').style.bottom = 'auto';
        document.getElementById('contextMenu').style.right = 'auto';
        document.getElementById('contextMenu').style.top = `${topPosition}px`;
    } else {
        //When user click on top-right part of window
        rightPosition = document.body.clientWidth - ctxPos.x
        topPosition = ctxPos.y
        document.getElementById('contextMenu').style.left = 'auto';
        document.getElementById('contextMenu').style.bottom = 'auto';
        document.getElementById('contextMenu').style.right = `${rightPosition}px`;
        document.getElementById('contextMenu').style.top = `${topPosition}px`;
    }
    ctxPos.visible = true
    return false
}

/**
 * adds some UI elements to side bar and
 * menu also attaches listeners to sidebar
 * @category ux
 */
export function setupUI() {
    var ctxEl = document.getElementById('contextMenu');
    document.addEventListener('mousedown', (e) => {
        // Check if mouse is not inside the context menu and menu is visible
        if (
            !(
                e.clientX >= ctxPos.x &&
                e.clientX <= ctxPos.x + ctxEl.offsetWidth &&
                e.clientY >= ctxPos.y &&
                e.clientY <= ctxPos.y + ctxEl.offsetHeight
            ) &&
            ctxPos.visible &&
            e.which !== 3
        ) {
            hideContextMenu()
        }

        // Change the position of context whenever mouse is clicked
        ctxPos.x = e.clientX
        ctxPos.y = e.clientY
    })
    document.getElementById('canvasArea').addEventListener("contextmenu",showContextMenu);

    // commenting jquery-ui (not working)
    // $('#sideBar').resizable({
    //     handles: 'e',
    //     // minWidth:270,
    // });
    // $('#menu, #subcircuitMenu').accordion({
    //     collapsible: true,
    //     active: false,
    //     heightStyle: 'content',
    // });

    document.getElementsByClassName('logixButton').addEventListener('click', function () {
        logixFunction[this.id]()
    });

    // var dummyCounter=0;

    // calling apply on select theme in dropdown
    document.getElementsByClassName('applyTheme').addEventListener('change', function () {
        applyVerilogTheme()
    })

    document.getElementById('report').addEventListener('click', function () {
        var message = document.getElementById('issuetext').value
        var email = document.getElementById('emailtext').value
        message += '\nEmail:' + email
        message += '\nURL: ' + window.location.href
        message += `\nUser Id: ${window.user_id}`
        postUserIssue(message)
        document.getElementById('issuetext').style.display = "none";
        document.getElementById('emailtext').style.display = "none";
        document.getElementById('report').style.display = "none";
        document.getElementById('report-label').style.display = "none";
        document.getElementById('email-label').style.display = "none";
    })
    document.getElementsByClassName('issue').addEventListener('hide.bs.modal', function (e) {
        listenToSimulator = true
        document.getElementById('result').innerHTML = '';
        document.getElementById('issuetext').style.display = "block";
        document.getElementById('emailtext').style.display = "block";
        document.getElementById('issuetext').value = '';
        document.getElementById('emailtext').value = '';
        document.getElementById('report').style.display = "block";
        document.getElementById('report-label').style.display = "block";
        document.getElementById('email-label').style.display = "block";
    })
    document.getElementById('reportIssue').addEventListener('click', function () {
        listenToSimulator = false
    })

    // $('#saveAsImg').on('click',function(){
    //     saveAsImg();
    // });
    // $('#Save').on('click',function(){
    //     Save();
    // });
    // $('#moduleProperty').draggable();
    setupPanels()
    setupVerilogExportCodeWindow()
    setupBitConvertor()
}

/**
 * Keeps in check which property is being displayed
 * @category ux
 */
var prevPropertyObj

export function prevPropertyObjSet(param) {
    prevPropertyObj = param
}

export function prevPropertyObjGet() {
    return prevPropertyObj
}

function checkValidBitWidth() {
    const selector = document.querySelector("[name='newBitWidth']")
    if (
        selector === undefined ||
        selector.value > 32 ||
        selector.value < 1 ||
        isNaN(selector.value)
    ) {
        // fallback to previously saves state
        selector.value = selector.getAttribute('old-val')
    } else {
        selector.getAttribute('old-val', selector.value)
    }
}

export function objectPropertyAttributeUpdate() {
    checkValidBitWidth()
    scheduleUpdate()
    updateCanvasSet(true)
    wireToBeCheckedSet(1)
    // console.log(this)
    let { value } = this
    // console.log(value)
    if (this.type === 'number') {
        value = parseFloat(value)
    }
    if (simulationArea.lastSelected && simulationArea.lastSelected[this.name]) {
        simulationArea.lastSelected[this.name](value)
        // Commented out due to property menu refresh bug
        // prevPropertyObjSet(simulationArea.lastSelected[this.name](this.value)) || prevPropertyObjGet();
    } else {
        circuitProperty[this.name](value)
    }
}

export function objectPropertyAttributeCheckedUpdate() {
    if (this.name === 'toggleLabelInLayoutMode') return // Hack to prevent toggleLabelInLayoutMode from toggling twice
    scheduleUpdate()
    updateCanvasSet(true)
    wireToBeCheckedSet(1)
    if (simulationArea.lastSelected && simulationArea.lastSelected[this.name]) {
        simulationArea.lastSelected[this.name](this.value)
        // Commented out due to property menu refresh bug
        // prevPropertyObjSet(simulationArea.lastSelected[this.name](this.value)) || prevPropertyObjGet();
    } else {
        circuitProperty[this.name](this.checked)
    }
}

export function checkPropertiesUpdate(value = 0) {
    // console.log('update check')

    document.getElementsByClassName('objectPropertyAttribute').addEventListener(
        'change keyup paste click',
        objectPropertyAttributeUpdate
    )

    document.getElementsByClassName('objectPropertyAttributeChecked').addEventListener(
        'change keyup paste click',
        objectPropertyAttributeCheckedUpdate
    )

    //Duplicate of above (Handled above)
    // $('.objectPropertyAttributeChecked').on('click', function () {
    //     if (this.name !== 'toggleLabelInLayoutMode') return // Hack to prevent toggleLabelInLayoutMode from toggling twice
    //     scheduleUpdate()
    //     updateCanvasSet(true)
    //     wireToBeCheckedSet(1)
    //     if (
    //         simulationArea.lastSelected &&
    //         simulationArea.lastSelected[this.name]
    //     ) {
    //         simulationArea.lastSelected[this.name](this.value)
    //         // Commented out due to property menu refresh bug
    //         // prevPropertyObjSet(simulationArea.lastSelected[this.name](this.value)) || prevPropertyObjGet();
    //     } else {
    //         circuitProperty[this.name](this.checked)
    //     }
    // })
}

/**
 * show properties of an object.
 * @param {CircuiElement} obj - the object whose properties we want to be shown in sidebar
 * @category ux
 */
export function showProperties(obj) {
    if (obj === prevPropertyObjGet()) return

    /*
    hideProperties()
    prevPropertyObjSet(obj)
    if (layoutModeGet()) {
        // if an element is selected, show its properties instead of the layout dialog
        if (
            simulationArea.lastSelected === undefined ||
            ['Wire', 'CircuitElement', 'Node'].indexOf(
                simulationArea.lastSelected.objectType
            ) !== -1
        ) {
            $('#moduleProperty').hide()
            $('#layoutDialog').show()
            return
        }

        $('#moduleProperty').show()
        $('#layoutDialog').hide()
        $('#moduleProperty-inner').append(
            "<div id='moduleProperty-header'>" + obj.objectType + '</div>'
        )

        if (obj.subcircuitMutableProperties && obj.canShowInSubcircuit) {
            for (let attr in obj.subcircuitMutableProperties) {
                var prop = obj.subcircuitMutableProperties[attr]
                if (obj.subcircuitMutableProperties[attr].type == 'number') {
                    var s =
                        '<p>' +
                        prop.name +
                        "<input class='objectPropertyAttribute' type='number'  name='" +
                        prop.func +
                        "' min='" +
                        (prop.min || 0) +
                        "' max='" +
                        (prop.max || 200) +
                        "' value=" +
                        obj[attr] +
                        '></p>'
                    $('#moduleProperty-inner').append(s)
                } else if (
                    obj.subcircuitMutableProperties[attr].type == 'text'
                ) {
                    var s =
                        '<p>' +
                        prop.name +
                        "<input class='objectPropertyAttribute' type='text'  name='" +
                        prop.func +
                        "' maxlength='" +
                        (prop.maxlength || 200) +
                        "' value=" +
                        obj[attr] +
                        '></p>'
                    $('#moduleProperty-inner').append(s)
                } else if (
                    obj.subcircuitMutableProperties[attr].type == 'checkbox'
                ) {
                    var s =
                        '<p>' +
                        prop.name +
                        "<label class='switch'> <input type='checkbox' " +
                        ['', 'checked'][
                            obj.subcircuitMetadata.showLabelInSubcircuit + 0
                        ] +
                        " class='objectPropertyAttributeChecked' name='" +
                        prop.func +
                        "'> <span class='slider'></span> </label></p>"
                    $('#moduleProperty-inner').append(s)
                }
            }
            if (!obj.labelDirectionFixed) {
                if (!obj.subcircuitMetadata.labelDirection)
                    obj.subcircuitMetadata.labelDirection = obj.labelDirection
                var s = $(
                    "<select class='objectPropertyAttribute' name='newLabelDirection'>" +
                        "<option value='RIGHT' " +
                        ['', 'selected'][
                            +(obj.subcircuitMetadata.labelDirection == 'RIGHT')
                        ] +
                        " >RIGHT</option><option value='DOWN' " +
                        ['', 'selected'][
                            +(obj.subcircuitMetadata.labelDirection == 'DOWN')
                        ] +
                        " >DOWN</option><option value='LEFT' " +
                        "<option value='RIGHT'" +
                        ['', 'selected'][
                            +(obj.subcircuitMetadata.labelDirection == 'LEFT')
                        ] +
                        " >LEFT</option><option value='UP' " +
                        "<option value='RIGHT'" +
                        ['', 'selected'][
                            +(obj.subcircuitMetadata.labelDirection == 'UP')
                        ] +
                        ' >UP</option>' +
                        '</select>'
                )
                s.val(obj.subcircuitMetadata.labelDirection)
                $('#moduleProperty-inner').append(
                    '<p>Label Direction: ' + $(s).prop('outerHTML') + '</p>'
                )
            }
        }
    } else if (
        simulationArea.lastSelected === undefined ||
        ['Wire', 'CircuitElement', 'Node'].indexOf(
            simulationArea.lastSelected.objectType
        ) !== -1
    ) {
        $('#moduleProperty').show()

        $('#moduleProperty-inner').append(
            `<p><span>Project:</span> <input id='projname' class='objectPropertyAttribute' type='text' autocomplete='off' name='setProjectName'  value='${
                getProjectName() || 'Untitled'
            }'></p>`
        )
        $('#moduleProperty-inner').append(
            `<p><span>Circuit:</span> <input id='circname' class='objectPropertyAttribute' type='text' autocomplete='off' name='changeCircuitName'  value='${
                globalScope.name || 'Untitled'
            }'></p>`
        )
        $('#moduleProperty-inner').append(
            `<p><span>Clock Time (ms):</span> <input class='objectPropertyAttribute' min='50' type='number' style='width:100px' step='10' name='changeClockTime'  value='${simulationArea.timePeriod}'></p>`
        )
        $('#moduleProperty-inner').append(
            `<p><span>Clock Enabled:</span> <label class='switch'> <input type='checkbox' ${
                ['', 'checked'][simulationArea.clockEnabled + 0]
            } class='objectPropertyAttributeChecked' name='changeClockEnable' > <span class='slider'></span></label></p>`
        )
        $('#moduleProperty-inner').append(
            `<p><span>Lite Mode:</span> <label class='switch'> <input type='checkbox' ${
                ['', 'checked'][lightMode + 0]
            } class='objectPropertyAttributeChecked' name='changeLightMode' > <span class='slider'></span> </label></p>`
        )
        $('#moduleProperty-inner').append(
            "<p><button type='button' class='objectPropertyAttributeChecked btn btn-xs custom-btn--primary' name='toggleLayoutMode' >Edit Layout</button><button type='button' class='objectPropertyAttributeChecked btn btn-xs custom-btn--tertiary' name='deleteCurrentCircuit' >Delete Circuit</button> </p>"
        )
        // $('#moduleProperty-inner').append("<p>  ");
    } else {
        $('#moduleProperty').show()

        $('#moduleProperty-inner').append(
            `<div id='moduleProperty-header'>${obj.objectType}</div>`
        )
        // $('#moduleProperty').append("<input type='range' name='points' min='1' max='32' value="+obj.bitWidth+">");
        if (!obj.fixedBitWidth) {
            $('#moduleProperty-inner').append(
                `<p><span>BitWidth:</span> <input class='objectPropertyAttribute' type='number'  name='newBitWidth' min='1' max='32' value=${obj.bitWidth}></p>`
            )
        }

        if (obj.changeInputSize) {
            $('#moduleProperty-inner').append(
                `<p><span>Input Size:</span> <input class='objectPropertyAttribute' type='number'  name='changeInputSize' min='2' max='10' value=${obj.inputSize}></p>`
            )
        }

        if (!obj.propagationDelayFixed) {
            $('#moduleProperty-inner').append(
                `<p><span>Delay:</span> <input class='objectPropertyAttribute' type='number'  name='changePropagationDelay' min='0' max='100000' value=${obj.propagationDelay}></p>`
            )
        }

        if (!obj.disableLabel)
            $('#moduleProperty-inner').append(
                `<p><span>Label:</span> <input class='objectPropertyAttribute' type='text'  name='setLabel' autocomplete='off'  value='${escapeHtml(
                    obj.label
                )}'></p>`
            )

        var s
        if (!obj.labelDirectionFixed) {
            s = $(
                `${
                    "<select class='objectPropertyAttribute' name='newLabelDirection'>" +
                    "<option value='RIGHT' "
                }${
                    ['', 'selected'][+(obj.labelDirection === 'RIGHT')]
                } >RIGHT</option><option value='DOWN' ${
                    ['', 'selected'][+(obj.labelDirection === 'DOWN')]
                } >DOWN</option><option value='LEFT' ` +
                    `<option value='RIGHT'${
                        ['', 'selected'][+(obj.labelDirection === 'LEFT')]
                    } >LEFT</option><option value='UP' ` +
                    `<option value='RIGHT'${
                        ['', 'selected'][+(obj.labelDirection === 'UP')]
                    } >UP</option>` +
                    '</select>'
            )
            s.val(obj.labelDirection)
            $('#moduleProperty-inner').append(
                `<p><span>Label Direction:</span> ${$(s).prop('outerHTML')}</p>`
            )
        }

        if (!obj.directionFixed) {
            s = $(
                `${
                    "<select class='objectPropertyAttribute' name='newDirection'>" +
                    "<option value='RIGHT' "
                }${
                    ['', 'selected'][+(obj.direction === 'RIGHT')]
                } >RIGHT</option><option value='DOWN' ${
                    ['', 'selected'][+(obj.direction === 'DOWN')]
                } >DOWN</option><option value='LEFT' ` +
                    `<option value='RIGHT'${
                        ['', 'selected'][+(obj.direction === 'LEFT')]
                    } >LEFT</option><option value='UP' ` +
                    `<option value='RIGHT'${
                        ['', 'selected'][+(obj.direction === 'UP')]
                    } >UP</option>` +
                    '</select>'
            )
            $('#moduleProperty-inner').append(
                `<p><span>Direction:</span> ${$(s).prop('outerHTML')}</p>`
            )
        } else if (!obj.orientationFixed) {
            s = $(
                `${
                    "<select class='objectPropertyAttribute' name='newDirection'>" +
                    "<option value='RIGHT' "
                }${
                    ['', 'selected'][+(obj.direction === 'RIGHT')]
                } >RIGHT</option><option value='DOWN' ${
                    ['', 'selected'][+(obj.direction === 'DOWN')]
                } >DOWN</option><option value='LEFT' ` +
                    `<option value='RIGHT'${
                        ['', 'selected'][+(obj.direction === 'LEFT')]
                    } >LEFT</option><option value='UP' ` +
                    `<option value='RIGHT'${
                        ['', 'selected'][+(obj.direction === 'UP')]
                    } >UP</option>` +
                    '</select>'
            )
            $('#moduleProperty-inner').append(
                `<p><span>Orientation:</span> ${$(s).prop('outerHTML')}</p>`
            )
        }

        if (obj.mutableProperties) {
            for (const attr in obj.mutableProperties) {
                var prop = obj.mutableProperties[attr]
                if (obj.mutableProperties[attr].type === 'number') {
                    s = `<p><span>${
                        prop.name
                    }</span><input class='objectPropertyAttribute' type='number'  name='${
                        prop.func
                    }' min='${prop.min || 0}' max='${prop.max || 200}' value=${
                        obj[attr]
                    }></p>`
                    $('#moduleProperty-inner').append(s)
                } else if (obj.mutableProperties[attr].type === 'text') {
                    s = `<p><span>${
                        prop.name
                    }</span><input class='objectPropertyAttribute' type='text' autocomplete='off'  name='${
                        prop.func
                    }' maxlength='${prop.maxlength || 200}' value=${
                        obj[attr]
                    }></p>`
                    $('#moduleProperty-inner').append(s)
                } else if (obj.mutableProperties[attr].type === 'button') {
                    s = `<p class='btn-parent'><button class='objectPropertyAttribute btn custom-btn--secondary' type='button'  name='${prop.func}'>${prop.name}</button></p>`
                    $('#moduleProperty-inner').append(s)
                } else if (obj.mutableProperties[attr].type === 'textarea') {
                    s = `<p><span>${prop.name}</span><textarea class='objectPropertyAttribute' type='text' autocomplete='off' rows="9" name='${prop.func}'>${obj[attr]}</textarea></p>`
                    $('#moduleProperty-inner').append(s)
                }
            }
        }
    }

    var helplink = obj && obj.helplink
    console.log(obj)
    if (helplink) {
        $('#moduleProperty-inner').append(
            '<p class="btn-parent"><button id="HelpButton" class="btn btn-primary btn-xs" type="button" >&#9432 Help</button></p>'
        )
        $('#HelpButton').on('click', () => {
            window.open(helplink)
        })
    }
*/
    checkPropertiesUpdate(this)

    // $(".moduleProperty input[type='number']").inputSpinner();
}

/**
 * Hides the properties in sidebar.
 * @category ux
 */
export function hideProperties() {
    document.getElementById('moduleProperty-inner').innerHTML = "";
    document.getElementById('moduleProperty').style.display = "none";
    prevPropertyObjSet(undefined)
    document.getElementsByClassName('objectPropertyAttribute').removeEventListener('change keyup paste click');
}
/**
 * checkss the input is safe or not
 * @param {HTML} unsafe - the html which we wants to escape
 * @category ux
 */
function escapeHtml(unsafe) {
    return unsafe
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;')
}

export function deleteSelected() {
    console.log('Delete Selected Called')
    if (
        simulationArea.lastSelected &&
        !(
            simulationArea.lastSelected.objectType === 'Node' &&
            simulationArea.lastSelected.type !== 2
        )
    ) {
        simulationArea.lastSelected.delete()
    }

    for (var i = 0; i < simulationArea.multipleObjectSelections.length; i++) {
        if (
            !(
                simulationArea.multipleObjectSelections[i].objectType ===
                    'Node' &&
                simulationArea.multipleObjectSelections[i].type !== 2
            )
        )
            simulationArea.multipleObjectSelections[i].cleanDelete()
    }

    simulationArea.multipleObjectSelections = []
    simulationArea.lastSelected = undefined
    showProperties(simulationArea.lastSelected)
    // Updated restricted elements
    updateCanvasSet(true)
    scheduleUpdate()
    updateRestrictedElementsInScope()
}

/**
 * listener for opening the prompt for bin conversion
 * @category ux
 */
document.getElementById('bitconverter').addEventListener('click', () => {
    document.getElementById('bitconverterprompt').show({
        resizable: false,
        buttons: [
            {
                text: 'Reset',
                click() {
                    document.getElementById('decimalInput').value = '0';
                    document.getElementById('binaryInput').value = '0';
                    document.getElementById('octalInput').value = '0';
                    document.getElementById('hexInput').value = '0';
                },
            },
        ],
    })
})

// convertors
const convertors = {
    dec2bin: (x) => `0b${x.toString(2)}`,
    dec2hex: (x) => `0x${x.toString(16)}`,
    dec2octal: (x) => `0${x.toString(8)}`,
}

function setBaseValues(x) {
    if (isNaN(x)) return
    document.getElementById('binaryInput').value = convertors.dec2bin(x);
    document.getElementById('octalInput').value = convertors.dec2octal(x);
    document.getElementById('hexInput').value = convertors.dec2hex(x);
    document.getElementById('decimalInput').value = x;
}

document.getElementById('decimalInput').addEventListener('keyup', () => {
    var x = parseInt(document.getElementById('decimalInput').value, 10)
    setBaseValues(x)
})

document.getElementById('binaryInput').addEventListener('keyup', () => {
    var x = parseInt(document.getElementById('binaryInput').value, 2)
    setBaseValues(x)
})

document.getElementById('hexInput').addEventListener('keyup', () => {
    var x = parseInt(document.getElementById('hexInput').value, 16)
    setBaseValues(x)
})

document.getElementById('octalInput').addEventListener('keyup', () => {
    var x = parseInt(document.getElementById('octalInput').value, 8)
    setBaseValues(x)
})

export function setupPanels() {
    document.getElementById('dragQPanel')
        .addEventListener('mousedown', () =>
        document.getElementsByClassName('quick-btn').setAttribute("draggable", "true")
        )
        .addEventListener('mouseup', () => $('.quick-btn').setAttribute("draggable", "false"))

    setupPanelListeners('.elementPanel')
    setupPanelListeners('.layoutElementPanel')
    setupPanelListeners('#moduleProperty')
    setupPanelListeners('#layoutDialog')
    setupPanelListeners('#verilogEditorPanel')
    setupPanelListeners('.timing-diagram-panel')
    setupPanelListeners('.testbench-manual-panel')

    // Minimize Timing Diagram (takes too much space)
    document.getElementsByClassName('timing-diagram-panel .minimize').click();

    // Update the Testbench Panel UI
    updateTestbenchUI()
    // Minimize Testbench UI
    document.getElementsByClassName('testbench-manual-panel .minimize').click();

    // Hack because minimizing panel then maximizing sets visibility recursively
    // updateTestbenchUI calls some hide()s which are undone by maximization
    // TODO: Remove hack
    document.getElementsByClassName('testbench-manual-panel .maximize').addEventListener('click', setupTestbenchUI);

    document.getElementById('projectName').addEventListener('click', () => {
        document.querySelector("input[name='setProjectName']").focus().select()
    })
}

function setupPanelListeners(panelSelector) {
    var headerSelector = `${panelSelector} .panel-header`
    var minimizeSelector = `${panelSelector} .minimize`
    var maximizeSelector = `${panelSelector} .maximize`
    var bodySelector = `${panelSelector} > .panel-body`
    // Drag Start
    document.querySelector(headerSelector).addEventListener('mousedown', () =>
    document.querySelector(panelSelector).setAttribute("draggable", "true")
    )
    // Drag End
    document.querySelector(headerSelector).addEventListener('mouseup', () =>
        document.querySelector(panelSelector).setAttribute("draggable", "false"))

    // Current Panel on Top
    document.querySelector(panelSelector).addEventListener('mousedown', () => {
        document.getElementsByClassName(`draggable-panel:not(${panelSelector})`).style.zIndex = '99';
        document.querySelector(panelSelector).style.zIndex = '100';
    })
    var minimized = false
    document.querySelector(headerSelector).addEventListener('dblclick', () =>
        minimized
            ? document.querySelector(maximizeSelector).click()
            : document.querySelector(minimizeSelector).click()
    )
    // Minimize
    document.querySelector(minimizeSelector).addEventListener('click', () => {
        document.querySelector(bodySelector).style.display = 'none';
        document.querySelector(minimizeSelector).style.display = 'none';
        document.querySelector(maximizeSelector).style.display = 'block';
        minimized = true
    })
    // Maximize
    document.querySelectodocument.querySelector(maximizeSelector).addEventListener('click', () => {
        document.querySelector(bodySelector).style.display = 'block';
        document.querySelector(minimizeSelector).style.display = 'block';
        document.querySelector(maximizeSelector).style.display = 'none';
        minimized = false
    })
}

export function exitFullView() {
   document.getElementsByClassName('navbar').style.display = 'block';
    document.getElementsByClassName('modules').style.display = 'block';
    document.getElementsByClassName('report-sidebar').style.display = 'block';
    document.getElementById('tabsBar').style.display = 'block';
    document.getElementById('exitViewBtn').remove();
    document.getElementById('moduleProperty').style.display = 'block';
    document.getElementsByClassName('timing-diagram-panel').style.display = 'block';
    document.getElementsByClassName('testbench-manual-panel').style.display = 'block';
}

export function fullView() {
    const markUp = `<button id='exitViewBtn' >Exit Full Preview</button>`
    document.getElementsByClassName('navbar').style.display = 'none';
    document.getElementsByClassName('modules').style.display = 'none';
    document.getElementsByClassName('report-sidebar').style.display = 'none';
    document.getElementById('tabsBar').style.display = 'none';
    document.getElementById('moduleProperty').style.display = 'none';
    document.getElementsByClassName('timing-diagram-panel').style.display = 'none';
    document.getElementsByClassName('testbench-manual-panel').style.display = 'none';
    document.getElementById('exitView').append(markUp)
    document.getElementById('exitViewBtn').addEventListener('click', exitFullView)
}
/** 
    Fills the elements that can be displayed in the subcircuit, in the subcircuit menu
**/
export function fillSubcircuitElements() {
    document.getElementById('subcircuitMenu').innerHTML = "";
    var subCircuitElementExists = false
    for (let el of circuitElementList) {
        if (globalScope[el].length === 0) continue
        if (!globalScope[el][0].canShowInSubcircuit) continue
        let tempHTML = ''

        // add a panel for each existing group
        tempHTML += `<div class="panelHeader">${el}s</div>`
        tempHTML += `<div class="panel">`

        let available = false

        // add an SVG for each element
        for (let i = 0; i < globalScope[el].length; i++) {
            if (!globalScope[el][i].subcircuitMetadata.showInSubcircuit) {
                tempHTML += `<div class="icon subcircuitModule" id="${el}-${i}" data-element-id="${i}" data-element-name="${el}">`
                tempHTML += `<img src= "/img/${el}.svg">`
                tempHTML += `<p class="img__description">${
                    globalScope[el][i].label !== ''
                        ? globalScope[el][i].label
                        : 'unlabeled'
                }</p>`
                tempHTML += '</div>'
                available = true
            }
        }
        tempHTML += '</div>'
        subCircuitElementExists = subCircuitElementExists || available
        if (available) document.getElementById('subcircuitMenu').append(tempHTML)
    }

    if (subCircuitElementExists) {
        document.getElementById('subcircuitMenu').accordion('refresh')
    } else {
        document.getElementById('subcircuitMenu').append('<p>No layout elements available</p>')
    }

    document.getElementsByClassName('subcircuitModule').addEventListener("mousedown", function () {
        let elementName = this.dataset.elementName
        let elementIndex = this.dataset.elementId

        let element = globalScope[elementName][elementIndex]

        element.subcircuitMetadata.showInSubcircuit = true
        element.newElement = true
        simulationArea.lastSelected = element
        this.parentElement.removeChild(this)
    })
}

async function postUserIssue(message) {
    var img = generateImage('jpeg', 'full', false, 1, false).split(',')[1]

    let result
    try {
        result = await fetch('https://api.imgur.com/3/image', {
            method: 'POST',
            body: {
                image: img,
            },
            body: JSON.stringify(data),
            headers: {
                Authorization: 'Client-ID 9a33b3b370f1054',
            },
        })
    } catch (err) {
        console.error('Could not generate image, reporting anyway')
    }

    if (result) message += '\n' + result.data.link

    // Generate circuit data for reporting
    let circuitData
    try {
        // Writing default project name to prevent unnecessary prompt in case the
        // project is unnamed
        circuitData = generateSaveData('Untitled')
    } catch (err) {
        circuitData = `Circuit data generation failed: ${err}`
    }

    fetch('/simulator/post_issue', {
        method: 'POST',
        headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
        },
        body: {
            text: message,
            circuit_data: circuitData,
        },
        }).then(function (response) {
            document.getElementById('result').innerHTML =  "<i class='fa fa-check' style='color:green'></i> You've successfully submitted the issue. Thanks for improving our platform.";
        })
        .catch(function (error){
            document.getElementById('result').innerHTML = "<i class='fa fa-check' style='color:red'></i> There seems to be a network issue. Please reach out to us at support@ciruitverse.org";
        });
}
