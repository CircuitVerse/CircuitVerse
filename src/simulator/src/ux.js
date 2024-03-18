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
import { generateImage, generateSaveData } from './data/save'
import { setupVerilogExportCodeWindow } from './verilog'
import { updateTestbenchUI, setupTestbenchUI } from './testbench'
import { applyVerilogTheme } from './Verilog2CV'
import { dragging } from './drag'

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
    $('#contextMenu').css({
        visibility: 'visible',
        opacity: 1,
    })

    var windowHeight =
        $('#simulationArea').height() - $('#contextMenu').height() - 10
    var windowWidth =
        $('#simulationArea').width() - $('#contextMenu').width() - 10
    // for top, left, right, bottom
    var topPosition
    var leftPosition
    var rightPosition
    var bottomPosition
    if (ctxPos.y > windowHeight && ctxPos.x <= windowWidth) {
        //When user click on bottom-left part of window
        leftPosition = ctxPos.x
        bottomPosition = $(window).height() - ctxPos.y
        $('#contextMenu').css({
            left: `${leftPosition}px`,
            bottom: `${bottomPosition}px`,
            right: 'auto',
            top: 'auto',
        })
    } else if (ctxPos.y > windowHeight && ctxPos.x > windowWidth) {
        //When user click on bottom-right part of window
        bottomPosition = $(window).height() - ctxPos.y
        rightPosition = $(window).width() - ctxPos.x
        $('#contextMenu').css({
            left: 'auto',
            bottom: `${bottomPosition}px`,
            right: `${rightPosition}px`,
            top: 'auto',
        })
    } else if (ctxPos.y <= windowHeight && ctxPos.x <= windowWidth) {
        //When user click on top-left part of window
        leftPosition = ctxPos.x
        topPosition = ctxPos.y
        $('#contextMenu').css({
            left: `${leftPosition}px`,
            bottom: 'auto',
            right: 'auto',
            top: `${topPosition}px`,
        })
    } else {
        //When user click on top-right part of window
        rightPosition = $(window).width() - ctxPos.x
        topPosition = ctxPos.y
        $('#contextMenu').css({
            left: 'auto',
            bottom: 'auto',
            right: `${rightPosition}px`,
            top: `${topPosition}px`,
        })
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
    var ctxEl = document.getElementById('contextMenu')
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
    document.getElementById('canvasArea').oncontextmenu = showContextMenu

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

    $('.logixButton').on('click', function () {
        logixFunction[this.id]()
    })
    // var dummyCounter=0;

    // calling apply on select theme in dropdown

    // $('#saveAsImg').on('click',function(){
    //     saveAsImg();
    // });
    // $('#Save').on('click',function(){
    //     Save();
    // });
    // $('#moduleProperty').draggable();
    setupPanels()
    // setupVerilogExportCodeWindow()
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
    const selector = $("[name='newBitWidth']")
    if (
        selector === undefined ||
        selector.val() > 32 ||
        selector.val() < 1 ||
        !$.isNumeric(selector.val())
    ) {
        // fallback to previously saves state
        selector.val(selector.attr('old-val'))
    } else {
        selector.attr('old-val', selector.val())
    }
}

export function objectPropertyAttributeUpdate() {
    checkValidBitWidth()
    scheduleUpdate()
    updateCanvasSet(true)
    wireToBeCheckedSet(1)
    let { value } = this
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
    $('.objectPropertyAttribute').off(
        'change keyup paste click',
        objectPropertyAttributeUpdate
    )
    $('.objectPropertyAttribute').on(
        'change keyup paste click',
        objectPropertyAttributeUpdate
    )

    $('.objectPropertyAttributeChecked').off(
        'change keyup paste click',
        objectPropertyAttributeCheckedUpdate
    )
    $('.objectPropertyAttributeChecked').on(
        'change keyup paste click',
        objectPropertyAttributeCheckedUpdate
    )
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
    $('#moduleProperty-inner').empty()
    $('#moduleProperty').hide()
    prevPropertyObjSet(undefined)
    $('.objectPropertyAttribute').unbind('change keyup paste click')
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

export function setupPanels() {
    // $('#dragQPanel')
    //     .on('mousedown', () =>
    //         $('.quick-btn').draggable({
    //             disabled: false,
    //             containment: 'window',
    //         })
    //     )
    //     .on('mouseup', () => $('.quick-btn').draggable({ disabled: true }))

    // let position = { x: 0, y: 0 }
    // interact('.quick-btn').draggable({
    //     allowFrom: '#dragQPanel',
    //     listeners: {
    //         move(event) {
    //             position.x = position.x + event.dx
    //             position.y = position.y + event.dy
    //             event.target.style.transform = `translate(${position.x}px, ${position.y}px)`
    //         },
    //     },
    // })

    dragging('#dragQPanel', '.quick-btn')

    setupPanelListeners('.elementPanel')
    setupPanelListeners('.layoutElementPanel')
    setupPanelListeners('#moduleProperty')
    setupPanelListeners('#layoutDialog')
    setupPanelListeners('#verilogEditorPanel')
    setupPanelListeners('.timing-diagram-panel')
    setupPanelListeners('.testbench-manual-panel')

    // Minimize Timing Diagram (takes too much space)
    $('.timing-diagram-panel .minimize').trigger('click')

    // Update the Testbench Panel UI
    updateTestbenchUI()
    // Minimize Testbench UI
    $('.testbench-manual-panel .minimize').trigger('click')

    // Hack because minimizing panel then maximizing sets visibility recursively
    // updateTestbenchUI calls some hide()s which are undone by maximization
    // TODO: Remove hack
    $('.testbench-manual-panel .maximize').on('click', setupTestbenchUI)

    $('#projectName').on('click', () => {
        $("input[name='setProjectName']").focus().select()
    })
}

function setupPanelListeners(panelSelector) {
    var headerSelector = `${panelSelector} .panel-header`
    var minimizeSelector = `${panelSelector} .minimize`
    var maximizeSelector = `${panelSelector} .maximize`
    var bodySelector = `${panelSelector} > .panel-body`

    dragging(headerSelector, panelSelector)
    // let position = { x: 0, y: 0 }
    // Drag Start
    // $(headerSelector).on('mousedown', () =>
    // $(panelSelector).draggable({ disabled: false, containment: 'window' })
    // interact(panelSelector).draggable({
    //     allowFrom: headerSelector,
    //     listeners: {
    //         move(event) {
    //             position.x += event.dx
    //             position.y += event.dy

    //             event.target.style.transform = `translate(${position.x}px, ${position.y}px)`
    //         },
    //     },
    // })
    // )
    // // Drag End
    // $(headerSelector).on('mouseup', () =>
    //     $(panelSelector).draggable({ disabled: true })
    // )
    // Current Panel on Top
    var minimized = false
    $(headerSelector).on('dblclick', () =>
        minimized
            ? $(maximizeSelector).trigger('click')
            : $(minimizeSelector).trigger('click')
    )
    // Minimize
    $(minimizeSelector).on('click', () => {
        $(bodySelector).hide()
        $(minimizeSelector).hide()
        $(maximizeSelector).show()
        minimized = true
    })
    // Maximize
    $(maximizeSelector).on('click', () => {
        $(bodySelector).show()
        $(minimizeSelector).show()
        $(maximizeSelector).hide()
        minimized = false
    })
}

export function exitFullView() {
    const exitViewBtn = document.querySelector('#exitViewBtn')
    if (exitViewBtn) exitViewBtn.remove()

    const elements = document.querySelectorAll(
        '.navbar, .modules, .report-sidebar, #tabsBar, #moduleProperty, .timing-diagram-panel, .testbench-manual-panel, .quick-btn'
    )
    elements.forEach((element) => {
        if (element instanceof HTMLElement) {
            element.style.display = ''
        }
    })
}

export function fullView() {
    const app = document.querySelector('#app')

    const exitViewEl = document.createElement('button')
    exitViewEl.id = 'exitViewBtn'
    exitViewEl.textContent = 'Exit Full Preview'

    const elements = document.querySelectorAll(
        '.navbar, .modules, .report-sidebar, #tabsBar, #moduleProperty, .timing-diagram-panel, .testbench-manual-panel, .quick-btn'
    )
    elements.forEach((element) => {
        if (element instanceof HTMLElement) {
            element.style.display = 'none'
        }
    })

    app.appendChild(exitViewEl)
    exitViewEl.addEventListener('click', exitFullView)
}

/** 
    Fills the elements that can be displayed in the subcircuit, in the subcircuit menu
**/
export function fillSubcircuitElements() {
    $('#subcircuitMenu').empty()
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
        if (available) $('#subcircuitMenu').append(tempHTML)
    }

    if (subCircuitElementExists) {
        // $('#subcircuitMenu').accordion('refresh')
    } else {
        $('#subcircuitMenu').append('<p>No layout elements available</p>')
    }

    $('.subcircuitModule').mousedown(function () {
        let elementName = this.dataset.elementName
        let elementIndex = this.dataset.elementId

        let element = globalScope[elementName][elementIndex]

        element.subcircuitMetadata.showInSubcircuit = true
        element.newElement = true
        simulationArea.lastSelected = element
        this.parentElement.removeChild(this)
    })
}
