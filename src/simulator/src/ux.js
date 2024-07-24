/* eslint-disable import/no-cycle */
/* eslint-disable guard-for-in */
/* eslint-disable no-restricted-syntax */
/* eslint-disable no-restricted-syntax */
/* eslint-disable guard-for-in */
import { layoutModeGet } from './layoutMode'
import {
    scheduleUpdate,
    wireToBeCheckedSet,
    updateCanvasSet
} from './engine'
import { simulationArea } from './simulationArea'
import logixFunction from './data'
import { circuitProperty } from './circuit'
import { updateRestrictedElementsInScope } from './restrictedElementDiv'
import { updateTestbenchUI, setupTestbenchUI } from './testbench'
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

    $('.logixButton').on('click', function () {
        logixFunction[this.id]()
    })
    setupPanels()
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
    checkPropertiesUpdate(this)
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

/**
 * listener for opening the prompt for bin conversion
 * @category ux
 */
$('#bitconverter').on('click', () => {
    $('#bitconverterprompt').dialog({
        resizable: false,
        buttons: [
            {
                text: 'Reset',
                click() {
                    $('#decimalInput').val('0')
                    $('#binaryInput').val('0')
                    $('#octalInput').val('0')
                    $('#hexInput').val('0')
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
    $('#binaryInput').val(convertors.dec2bin(x))
    $('#octalInput').val(convertors.dec2octal(x))
    $('#hexInput').val(convertors.dec2hex(x))
    $('#decimalInput').val(x)
}

$('#decimalInput').on('keyup', () => {
    var x = parseInt($('#decimalInput').val(), 10)
    setBaseValues(x)
})

$('#binaryInput').on('keyup', () => {
    var x = parseInt($('#binaryInput').val(), 2)
    setBaseValues(x)
})

$('#hexInput').on('keyup', () => {
    var x = parseInt($('#hexInput').val(), 16)
    setBaseValues(x)
})

$('#octalInput').on('keyup', () => {
    var x = parseInt($('#octalInput').val(), 8)
    setBaseValues(x)
})

export function setupPanels() {
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

    if (!subCircuitElementExists) {
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
