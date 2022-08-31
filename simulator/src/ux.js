/* eslint-disable import/no-cycle */
/* eslint-disable guard-for-in */
/* eslint-disable no-restricted-syntax */
/* eslint-disable no-restricted-syntax */
/* eslint-disable guard-for-in */

import { layoutModeGet } from './layoutMode';
import {
    scheduleUpdate, wireToBeCheckedSet, updateCanvasSet, update, updateSimulationSet,
} from './engine';
import simulationArea from './simulationArea';
import logixFunction from './data';
import { createNewCircuitScope, circuitProperty } from './circuit';
import modules from './modules';
import { updateRestrictedElementsInScope } from './restrictedElementDiv';
import { paste } from './events';
import { setProjectName, getProjectName } from './data/save';
import { changeScale } from './canvasApi';
import updateTheme from "./themer/themer";
import { generateImage, generateSaveData } from './data/save';
import { setupVerilogExportCodeWindow } from './verilog';
import { setupBitConvertor} from './utils';
import { currentScreen } from './listeners';
import { updateTestbenchUI, setupTestbenchUI } from './testbench';
import { applyVerilogTheme } from './Verilog2CV';

export const uxvar = {
    smartDropXX: 50,
    smartDropYY: 80,
};
/**
 * @type {number} - Is used to calculate the position where an element from sidebar is dropped
 * @category ux
 */
uxvar.smartDropXX = 50;

/**
 * @type {number} - Is used to calculate the position where an element from sidebar is dropped
 * @category ux
 */
uxvar.smartDropYY = 80;

/**
 * @type {Object} - Object stores the position of context menu;
 * @category ux
 */
var ctxPos = {
    x: 0,
    y: 0,
    visible: false,
};

/**
 * Function hides the context menu
 * @category ux
 */
function hideContextMenu() {
    var el = document.getElementById('contextMenu');
    el.style = 'opacity:0;';
    setTimeout(() => {
        el.style = 'visibility:hidden;';
        ctxPos.visible = false;
    }, 200); // Hide after 2 sec
}

/**
 * Function displays context menu
 * @category ux
 */
function showContextMenu() {
    if (layoutModeGet()) return false; // Hide context menu when it is in Layout Mode
    $('#contextMenu').css({
        visibility: 'visible',
        opacity: 1,
    });

    var windowHeight = $("#simulationArea").height() - $("#contextMenu").height() - 10;
    var windowWidth = $("#simulationArea").width() - $("#contextMenu").width() - 10;
    // for top, left, right, bottom
    var topPosition;
    var leftPosition;
    var rightPosition;
    var bottomPosition;
    if (ctxPos.y > windowHeight && ctxPos.x <= windowWidth) {
        //When user click on bottom-left part of window
        leftPosition = ctxPos.x;
        bottomPosition = $(window).height() - ctxPos.y;
        $("#contextMenu").css({
            left: `${leftPosition}px`,
            bottom: `${bottomPosition}px`,
            right: 'auto',
            top: 'auto',
        });
    } else if (ctxPos.y > windowHeight && ctxPos.x > windowWidth) {
        //When user click on bottom-right part of window
        bottomPosition = $(window).height() - ctxPos.y;
        rightPosition = $(window).width() - ctxPos.x;
        $("#contextMenu").css({
            left: 'auto',
            bottom: `${bottomPosition}px`,
            right: `${rightPosition}px`,
            top: 'auto',
        });
    } else if (ctxPos.y <= windowHeight && ctxPos.x <= windowWidth) {
        //When user click on top-left part of window
        leftPosition = ctxPos.x;
        topPosition = ctxPos.y;
        $("#contextMenu").css({
            left: `${leftPosition}px`,
            bottom: 'auto',
            right: 'auto',
            top: `${topPosition}px`,
        });
    } else {
        //When user click on top-right part of window
        rightPosition = $(window).width() - ctxPos.x;
        topPosition = ctxPos.y;
        $("#contextMenu").css({
            left: 'auto',
            bottom: 'auto',
            right: `${rightPosition}px`,
            top: `${topPosition}px`,
        });
    }
    ctxPos.visible = true;
    return false;
}

/**
 * Function is called when context item is clicked
 * @param {number} id - id of the optoin selected
 * @category ux
 */
function menuItemClicked(id, code="") {
    hideContextMenu();
    if (id === 0) {
        document.execCommand('copy');
    } else if (id === 1) {
        document.execCommand('cut');
    } else if (id === 2) {
        // document.execCommand('paste'); it is restricted to sove this problem we use dataPasted variable
        paste(localStorage.getItem('clipboardData'));
    } else if (id === 3) {
        deleteSelected();
    } else if (id === 4) {
        undo();
        undo();
    } else if (id === 5) {
        createNewCircuitScope();
    } else if (id === 6) {
        logixFunction.createSubCircuitPrompt();
    } else if (id === 7) {
        globalScope.centerFocus(false);
    }
}
window.menuItemClicked = menuItemClicked;

/**
 * adds some UI elements to side bar and
 * menu also attaches listeners to sidebar
 * @category ux
 */
export function setupUI() {
    var ctxEl = document.getElementById('contextMenu');
    document.addEventListener('mousedown', (e) => {
        // Check if mouse is not inside the context menu and menu is visible
        if (!((e.clientX >= ctxPos.x && e.clientX <= ctxPos.x + ctxEl.offsetWidth)
            && (e.clientY >= ctxPos.y && e.clientY <= ctxPos.y + ctxEl.offsetHeight))
            && (ctxPos.visible && e.which !== 3)) {
            hideContextMenu();
        }

        // Change the position of context whenever mouse is clicked
        ctxPos.x = e.clientX;
        ctxPos.y = e.clientY;
    });
    document.getElementById('canvasArea').oncontextmenu = showContextMenu;

    $('#sideBar').resizable({
        handles: 'e',
        // minWidth:270,
    });
    $('#menu, #subcircuitMenu').accordion({
        collapsible: true,
        active: false,
        heightStyle: 'content',
    });
    $('#menu2, #subcircuitMenu').accordion({
        collapsible: true,
        active: false,
        heightStyle: 'content',
    });

    $('.logixModules').mousedown(createElement);

    $('.logixButton').on('click',function () {
        logixFunction[this.id]();
    });
    // var dummyCounter=0;

    // calling apply on select theme in dropdown
    $('.applyTheme').on('change',function () {
        applyVerilogTheme();
    });


    $('.logixModules').hover(function () {
        // Tooltip can be statically defined in the prototype.
        var { tooltipText } = modules[this.id].prototype;
        if (!tooltipText) return;
        $('#Help').addClass('show');
        $('#Help').empty();
        $('#Help').append(tooltipText);
    }); // code goes in document ready fn only
    $('.logixModules').mouseleave(() => {
        $('#Help').removeClass('show');
    }); // code goes in document ready fn only

    $('#report').on('click', function() {
        var message=$('#issuetext').val();
        var email=$('#emailtext').val();
        message += "\nEmail:"+ email
        message += "\nURL: " + window.location.href;
        message += `\nUser Id: ${window.user_id}`
        postUserIssue(message)
        $('#issuetext').hide();
        $('#emailtext').hide();
        $('#report').hide();
        $('#report-label').hide();
        $('#email-label').hide();
        })
    $('.issue').on('hide.bs.modal', function(e) {
        listenToSimulator=true
        $('#result').html("");
        $('#issuetext').show();
        $('#emailtext').show();
        $('#issuetext').val("");
        $('#emailtext').val("");
        $('#report').show();
        $('#report-label').show();
        $('#email-label').show();
    })
    $('#reportIssue').on('click',function(){
      listenToSimulator=false
    })

    // $('#saveAsImg').on('click',function(){
    //     saveAsImg();
    // });
    // $('#Save').on('click',function(){
    //     Save();
    // });
    // $('#moduleProperty').draggable();
    setupPanels();
    setupVerilogExportCodeWindow();
    setupBitConvertor();
}

export function createElement() {
    if (simulationArea.lastSelected && simulationArea.lastSelected.newElement) simulationArea.lastSelected.delete();
    var obj = new modules[this.id]();
    simulationArea.lastSelected = obj;
    uxvar.smartDropXX += 70;
    if (uxvar.smartDropXX / globalScope.scale > width) {
        uxvar.smartDropXX = 50;
        uxvar.smartDropYY += 80;
    }
}

/**
 * Keeps in check which property is being displayed
 * @category ux
 */
var prevPropertyObj;

export function prevPropertyObjSet(param) {
    prevPropertyObj = param;
}

export function prevPropertyObjGet() {
    return prevPropertyObj;
}

var moduleProperty = currentScreen();
/**
 * show properties of an object.
 * @param {CircuiElement} obj - the object whose properties we want to be shown in sidebar
 * @category ux
 */
export function showProperties(obj) {
    if (obj === prevPropertyObjGet()) return;
    hideProperties();
    prevPropertyObjSet(obj);
    if(layoutModeGet()){
        // if an element is selected, show its properties instead of the layout dialog
        if (simulationArea.lastSelected === undefined || ['Wire', 'CircuitElement', 'Node'].indexOf(simulationArea.lastSelected.objectType) !== -1){
            $('#moduleProperty').hide();
            $('#layoutDialog').show();
            return;
        }

        $('#moduleProperty').show();
        $('#layoutDialog').hide();
        $(moduleProperty.modulePropertyInner).append("<div class='moduleProperty-header'>" + obj.objectType + "</div>");

        if (obj.subcircuitMutableProperties && obj.canShowInSubcircuit) {
            for (let attr in obj.subcircuitMutableProperties) {
                var prop = obj.subcircuitMutableProperties[attr];
                if (obj.subcircuitMutableProperties[attr].type == "number") {
                    var s = "<p>" + prop.name + "<input class='objectPropertyAttribute' type='number'  name='" + prop.func + "' min='" + (prop.min || 0) + "' max='" + (prop.max || 200) + "' value=" + obj[attr] + "></p>";
                    $(moduleProperty.modulePropertyInner).append(s);
                }
                else if (obj.subcircuitMutableProperties[attr].type == "text") {
                    var s = "<p>" + prop.name + "<input class='objectPropertyAttribute' type='text'  name='" + prop.func + "' maxlength='" + (prop.maxlength || 200) + "' value=" + obj[attr] + "></p>";
                    $(moduleProperty.modulePropertyInner).append(s);
                }
                else if (obj.subcircuitMutableProperties[attr].type == "checkbox"){
                    var s = "<p>" + prop.name + "<label class='switch'> <input type='checkbox' " + ["", "checked"][obj.subcircuitMetadata.showLabelInSubcircuit + 0] + " class='objectPropertyAttributeChecked' name='" + prop.func + "'> <span class='slider'></span> </label></p>";
                    $(moduleProperty.modulePropertyInner).append(s);
                }
            }
            if (!obj.labelDirectionFixed) {
                if(!obj.subcircuitMetadata.labelDirection) obj.subcircuitMetadata.labelDirection = obj.labelDirection;
                var s = $("<select class='objectPropertyAttribute' name='newLabelDirection'>" + "<option value='RIGHT' " + ["", "selected"][+(obj.subcircuitMetadata.labelDirection == "RIGHT")] + " >RIGHT</option><option value='DOWN' " + ["", "selected"][+(obj.subcircuitMetadata.labelDirection == "DOWN")] + " >DOWN</option><option value='LEFT' " + "<option value='RIGHT'" + ["", "selected"][+(obj.subcircuitMetadata.labelDirection == "LEFT")] + " >LEFT</option><option value='UP' " + "<option value='RIGHT'" + ["", "selected"][+(obj.subcircuitMetadata.labelDirection == "UP")] + " >UP</option>" + "</select>");
                s.val(obj.subcircuitMetadata.labelDirection);
                $(moduleProperty.modulePropertyInner).append("<p>Label Direction: " + $(s).prop('outerHTML') + "</p>");
            }
        }

    }
    else if (simulationArea.lastSelected === undefined || ['Wire', 'CircuitElement', 'Node'].indexOf(simulationArea.lastSelected.objectType) !== -1) {
        $('#moduleProperty').show();
        $(moduleProperty.modulePropertyInner).append("<div class='moduleProperty-header'>" + 'Project Properties' + '</div>');
        $(moduleProperty.modulePropertyInner).append(`<p><span>Project:</span> <input id='projname' class='objectPropertyAttribute' type='text' autocomplete='off' name='setProjectName'  value='${getProjectName() || 'Untitled'}' aria-label='project'></p>`);
        $(moduleProperty.modulePropertyInner).append(`<p><span>Circuit:</span> <input id='circname' class='objectPropertyAttribute' type='text' autocomplete='off' name='changeCircuitName'  value='${globalScope.name || 'Untitled'}' aria-label='circuit'></p>`);
        $(moduleProperty.modulePropertyInner).append(`<p><span>Clock Time (ms):</span> <input class='objectPropertyAttribute' min='50' type='number' style='width:100px' step='10' name='changeClockTime'  value='${simulationArea.timePeriod}' aria-label='clock time'></p>`);
        $(moduleProperty.modulePropertyInner).append(`<p><span>Clock Enabled:</span> <label class='switch'> <input type='checkbox' ${['', 'checked'][simulationArea.clockEnabled + 0]} class='objectPropertyAttributeChecked' name='changeClockEnable' aria-label='clock enabled'> <span class='slider'></span></label></p>`);
        $(moduleProperty.modulePropertyInner).append(`<p><span>Lite Mode:</span> <label class='switch'> <input type='checkbox' ${['', 'checked'][lightMode + 0]} class='objectPropertyAttributeChecked' name='changeLightMode' aria-label='lite mode'> <span class='slider'></span> </label></p>`);
        $(moduleProperty.modulePropertyInner).append("<p><button type='button' class='objectPropertyAttributeChecked btn btn-xs custom-btn--primary' name='toggleLayoutMode' >Edit Layout</button><button type='button' class='objectPropertyAttributeChecked btn btn-xs custom-btn--tertiary' name='deleteCurrentCircuit' >Delete Circuit</button> </p>");
        // $('#moduleProperty-inner').append("<p>  ");
    } else {
        $('#moduleProperty').show();

        $(moduleProperty.modulePropertyInner).append(`<div class='moduleProperty-header'>${obj.objectType}</div>`);
        // $('#moduleProperty').append("<input type='range' name='points' min='1' max='32' value="+obj.bitWidth+">");
        if (!obj.fixedBitWidth) { $(moduleProperty.modulePropertyInner).append(`<p><span>BitWidth:</span> <input class='objectPropertyAttribute' type='number'  name='newBitWidth' min='1' max='32' value=${obj.bitWidth} aria-label='bitwidth'></p>`); }

        if (obj.changeInputSize) { $(moduleProperty.modulePropertyInner).append(`<p><span>Input Size:</span> <input class='objectPropertyAttribute' type='number'  name='changeInputSize' min='2' max='10' value=${obj.inputSize} aria-label='InputSize'></p>`); }

        if (!obj.propagationDelayFixed) { $(moduleProperty.modulePropertyInner).append(`<p><span>Delay:</span> <input class='objectPropertyAttribute' type='number'  name='changePropagationDelay' min='0' max='100000' value=${obj.propagationDelay} aria-label='propagation Delay'></p>`); }

        if (!obj.disableLabel)
            $(moduleProperty.modulePropertyInner).append(`<p><span>Label:</span> <input class='objectPropertyAttribute' type='text' name='setLabel' autocomplete='off' value='${escapeHtml(obj.label)}' aria-label='label'></p>`);

        var s;
        if (!obj.labelDirectionFixed) {
            s = $(`${"<select class='objectPropertyAttribute' name='newLabelDirection'>" + "<option value='RIGHT' "}${['', 'selected'][+(obj.labelDirection === 'RIGHT')]} >RIGHT</option><option value='DOWN' ${['', 'selected'][+(obj.labelDirection === 'DOWN')]} >DOWN</option><option value='LEFT' ` + `<option value='RIGHT'${['', 'selected'][+(obj.labelDirection === 'LEFT')]} >LEFT</option><option value='UP' ` + `<option value='RIGHT'${['', 'selected'][+(obj.labelDirection === 'UP')]} >UP</option>` + '</select>');
            s.val(obj.labelDirection);
            $(moduleProperty.modulePropertyInner).append(`<p><span>Label Direction:</span> ${$(s).prop('outerHTML')}</p>`);
        }


        if (!obj.directionFixed) {
            s = $(`${"<select class='objectPropertyAttribute' name='newDirection'>" + "<option value='RIGHT' "}${['', 'selected'][+(obj.direction === 'RIGHT')]} >RIGHT</option><option value='DOWN' ${['', 'selected'][+(obj.direction === 'DOWN')]} >DOWN</option><option value='LEFT' ` + `<option value='RIGHT'${['', 'selected'][+(obj.direction === 'LEFT')]} >LEFT</option><option value='UP' ` + `<option value='RIGHT'${['', 'selected'][+(obj.direction === 'UP')]} >UP</option>` + '</select>');
            $(moduleProperty.modulePropertyInner).append(`<p><span>Direction:</span> ${$(s).prop('outerHTML')}</p>`);
        } else if (!obj.orientationFixed) {
            s = $(`${"<select class='objectPropertyAttribute' name='newDirection'>" + "<option value='RIGHT' "}${['', 'selected'][+(obj.direction === 'RIGHT')]} >RIGHT</option><option value='DOWN' ${['', 'selected'][+(obj.direction === 'DOWN')]} >DOWN</option><option value='LEFT' ` + `<option value='RIGHT'${['', 'selected'][+(obj.direction === 'LEFT')]} >LEFT</option><option value='UP' ` + `<option value='RIGHT'${['', 'selected'][+(obj.direction === 'UP')]} >UP</option>` + '</select>');
            $(moduleProperty.modulePropertyInner).append(`<p><span>Orientation:</span> ${$(s).prop('outerHTML')}</p>`);
        }

        if (obj.mutableProperties) {
            for (const attr in obj.mutableProperties) {
                var prop = obj.mutableProperties[attr];
                if (obj.mutableProperties[attr].type === 'number') {
                    s = `<p><span>${prop.name}</span><input class='objectPropertyAttribute' type='number'  name='${prop.func}' min='${prop.min || 0}' max='${prop.max || 200}' value=${obj[attr]}></p>`;
                    $(moduleProperty.modulePropertyInner).append(s);
                } else if (obj.mutableProperties[attr].type === 'text') {
                    s = `<p><span>${prop.name}</span><input class='objectPropertyAttribute' type='text' autocomplete='off'  name='${prop.func}' maxlength='${prop.maxlength || 200}' value=${obj[attr]}></p>`;
                    $(moduleProperty.modulePropertyInner).append(s);
                } else if (obj.mutableProperties[attr].type === 'button') {
                    s = `<p class='btn-parent'><button class='objectPropertyAttribute btn custom-btn--secondary' type='button'  name='${prop.func}'>${prop.name}</button></p>`;
                    $(moduleProperty.modulePropertyInner).append(s);
                }
                else if (obj.mutableProperties[attr].type === 'textarea') {
                    s = `<p><span>${prop.name}</span><textarea class='objectPropertyAttribute' type='text' autocomplete='off' rows="9" name='${prop.func}'>${obj[attr]}</textarea></p>`;
                    $(moduleProperty.modulePropertyInner).append(s);
                }
            }
        }
    }

    var helplink = obj && (obj.helplink);
    if (helplink) {
        $(moduleProperty.modulePropertyInner).append('<p class="btn-parent"><button id="HelpButton" class="btn btn-primary btn-xs" type="button" >&#9432 Help</button></p>');
        $('#HelpButton').on('click',() => {
            window.open(helplink);
        });
    }

    function checkValidBitWidth() {
        const selector = $("[name='newBitWidth']");
        if (selector === undefined
            || selector.val() > 32
            || selector.val() < 1
            || !$.isNumeric(selector.val())) {
            // fallback to previously saves state
            selector.val(selector.attr('old-val'));
        } else {
            selector.attr('old-val', selector.val());
        }
    }

    $('.objectPropertyAttribute').on('change keyup paste click', function () {
        checkValidBitWidth();
        scheduleUpdate();
        updateCanvasSet(true);
        wireToBeCheckedSet(1);
        let { value } = this;
        if (this.type === 'number') {
            value = parseFloat(value);
        }
        if (simulationArea.lastSelected && simulationArea.lastSelected[this.name]) {
            simulationArea.lastSelected[this.name](value);
            // Commented out due to property menu refresh bug
            // prevPropertyObjSet(simulationArea.lastSelected[this.name](this.value)) || prevPropertyObjGet();
        } else {
            circuitProperty[this.name](value);
        }
    });

    $('.objectPropertyAttributeChecked').on('change keyup paste click', function () {
        if(this.name === "toggleLabelInLayoutMode") return; // Hack to prevent toggleLabelInLayoutMode from toggling twice
        scheduleUpdate();
        updateCanvasSet(true);
        wireToBeCheckedSet(1);
        if (simulationArea.lastSelected && simulationArea.lastSelected[this.name]) {
            simulationArea.lastSelected[this.name](this.value);
            // Commented out due to property menu refresh bug
            // prevPropertyObjSet(simulationArea.lastSelected[this.name](this.value)) || prevPropertyObjGet();
        } else {
                circuitProperty[this.name](this.checked);
            }
    });

    $('.objectPropertyAttributeChecked').on('click', function () {
        if(this.name !== "toggleLabelInLayoutMode") return; // Hack to prevent toggleLabelInLayoutMode from toggling twice
        scheduleUpdate();
        updateCanvasSet(true);
        wireToBeCheckedSet(1);
        if (simulationArea.lastSelected && simulationArea.lastSelected[this.name]) {
            simulationArea.lastSelected[this.name](this.value);
            // Commented out due to property menu refresh bug
            // prevPropertyObjSet(simulationArea.lastSelected[this.name](this.value)) || prevPropertyObjGet();
        } else {
                circuitProperty[this.name](this.checked);
            }
    });

    $(".moduleProperty input[type='number']").inputSpinner();
}

/**
 * Hides the properties in sidebar.
 * @category ux
 */
export function hideProperties() {
    $(moduleProperty.modulePropertyInner).empty();
    $('#moduleProperty').hide();
    prevPropertyObjSet(undefined);
    $('.objectPropertyAttribute').unbind('change keyup paste click');
}
/**
 * checkss the input is safe or not
 * @param {HTML} unsafe - the html which we wants to escape
 * @category ux
 */
export function escapeHtml(unsafe) {
    return unsafe
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

export function deleteSelected() {
    if (simulationArea.lastSelected && !(simulationArea.lastSelected.objectType === 'Node' && simulationArea.lastSelected.type !== 2)) {
        simulationArea.lastSelected.delete();
    }

    for (var i = 0; i < simulationArea.multipleObjectSelections.length; i++) {
        if (!(simulationArea.multipleObjectSelections[i].objectType === 'Node' && simulationArea.multipleObjectSelections[i].type !== 2))
            simulationArea.multipleObjectSelections[i].cleanDelete();
    }

    simulationArea.multipleObjectSelections = [];
    simulationArea.lastSelected = undefined;
    showProperties(simulationArea.lastSelected);
    // Updated restricted elements
    updateCanvasSet(true);
    scheduleUpdate();
    updateRestrictedElementsInScope();
}
export function setupPanels() {
    $('#dragQPanel')
        .on('mousedown', () => $('.quick-btn').draggable({ disabled: false, containment: 'window' }))
        .on('mouseup', () => $('.quick-btn').draggable({ disabled: true }));

    setupPanelListeners('.elementPanel');
    setupPanelListeners('.layoutElementPanel');
    setupPanelListeners('#moduleProperty');
    setupPanelListeners('#layoutDialog');
    setupPanelListeners('#verilogEditorPanel');
    setupPanelListeners('.timing-diagram-panel');
    setupPanelListeners('.testbench-manual-panel');

    // Minimize Timing Diagram (takes too much space)
    $('.timing-diagram-panel .minimize').trigger('click');

    // Update the Testbench Panel UI
    updateTestbenchUI();
    // Minimize Testbench UI
    $('.testbench-manual-panel .minimize').trigger('click');

    // Hack because minimizing panel then maximizing sets visibility recursively
    // updateTestbenchUI calls some hide()s which are undone by maximization
    // TODO: Remove hack
    $('.testbench-manual-panel .maximize').on('click', setupTestbenchUI);

    $('#projectName').on('click', () => {
        $("input[name='setProjectName']").focus().select();
    });

}

function setupPanelListeners(panelSelector) {
    var headerSelector = `${panelSelector} .panel-header`;
    var minimizeSelector = `${panelSelector} .minimize`;
    var maximizeSelector = `${panelSelector} .maximize`;
    var bodySelector = `${panelSelector} > .panel-body`;
    // Drag Start
    $(headerSelector).on('mousedown', () => $(panelSelector).draggable({ disabled: false, containment: 'window'}));
    // Drag End
    $(headerSelector).on('mouseup', () => $(panelSelector).draggable({ disabled: true }));
    // Current Panel on Top
    $(panelSelector).on('mousedown', () => {
        $(`.draggable-panel:not(${panelSelector})`).css('z-index', '99');
        $(panelSelector).css('z-index', '100');
    })
    var minimized = false;
    $(headerSelector).on('dblclick', ()=> minimized ?
                                        $(maximizeSelector).trigger('click') :
                                        $(minimizeSelector).trigger('click'));
    // Minimize
    $(minimizeSelector).on('click', () => {
        $(bodySelector).hide();
        $(minimizeSelector).hide();
        $(maximizeSelector).show();
        minimized = true;
    });
    // Maximize
    $(maximizeSelector).on('click', () => {
        $(bodySelector).show();
        $(minimizeSelector).show();
        $(maximizeSelector).hide();
        minimized = false;
    });
}

export function exitFullView(){
    $('.navbar').show();
    $('.modules').show();
    $('.report-sidebar').show();
    $('#tabsBar').show();
    $('#exitViewBtn').remove();
    $('#moduleProperty').show();
    $('.timing-diagram-panel').show();
    $('.testbench-manual-panel').show();
}

export function fullView () {
    const markUp = `<button id='exitViewBtn' >Exit Full Preview</button>`
    $('.navbar').hide()
    $('.modules').hide()
    $('.report-sidebar').hide()
    $('#tabsBar').hide()
    $('#moduleProperty').hide()
    $('.timing-diagram-panel').hide();
    $('.testbench-manual-panel').hide();
    $('#exitView').append(markUp);
    $('#exitViewBtn').on('click', exitFullView);
}
/**
    Fills the elements that can be displayed in the subcircuit, in the subcircuit menu
**/
export function fillSubcircuitElements() {
    $('#subcircuitMenu').empty();
    var subCircuitElementExists = false;
    for(let el of circuitElementList) {
        if(globalScope[el].length === 0) continue;
        if(!globalScope[el][0].canShowInSubcircuit) continue;
        let tempHTML = '';

        // add a panel for each existing group
        tempHTML += `<div class="panelHeader">${el}s</div>`;
        tempHTML += `<div class="panel">`;

        let available = false;

        // add an SVG for each element
        for(let i = 0; i < globalScope[el].length; i++){
            if (!globalScope[el][i].subcircuitMetadata.showInSubcircuit) {
                tempHTML += `<div class="icon subcircuitModule" id="${el}-${i}" data-element-id="${i}" data-element-name="${el}">`;
                tempHTML += `<img src= "/img/${el}.svg">`;
                tempHTML += `<p class="img__description">${(globalScope[el][i].label !== "")? globalScope[el][i].label : 'unlabeled'}</p>`;
                tempHTML += '</div>';
                available = true;
            }

        }
        tempHTML += '</div>';
        subCircuitElementExists = subCircuitElementExists || available;
        if (available)
            $('#subcircuitMenu').append(tempHTML);
    }

    if(subCircuitElementExists) {
        $('#subcircuitMenu').accordion("refresh");
    }
    else {
        $('#subcircuitMenu').append("<p>No layout elements available</p>");
    }

    $('.subcircuitModule').mousedown(function () {
        let elementName = this.dataset.elementName;
        let elementIndex = this.dataset.elementId;

        let element = globalScope[elementName][elementIndex];

        element.subcircuitMetadata.showInSubcircuit = true;
        element.newElement = true;
        simulationArea.lastSelected = element;
        this.parentElement.removeChild(this);
    });
}

async function postUserIssue(message) {

    var img = generateImage("jpeg", "full", false, 1, false).split(',')[1];

    let result;
    try {
        result = await $.ajax({
                url: 'https://api.imgur.com/3/image',
                type: 'POST',
                data: {
                    image: img
                },
                dataType: 'json',
                headers: {
                    Authorization: 'Client-ID 9a33b3b370f1054'
                },
            });
    } catch (err) {
        console.error("Could not generate image, reporting anyway");
    }

    if (result) message += "\n" + result.data.link;

    // Generate circuit data for reporting
    let circuitData;
    try {
        // Writing default project name to prevent unnecessary prompt in case the
        // project is unnamed
        circuitData = generateSaveData("Untitled");
    } catch (err) {
        circuitData = `Circuit data generation failed: ${err}`;
    }

    $.ajax({
        url: '/simulator/post_issue',
        type: 'POST',
        beforeSend: function(xhr) {
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
        },
        data: {
            "text": message,
            "circuit_data": circuitData,
        },
        success: function(response) {
            $('#result').html("<i class='fa fa-check' style='color:green'></i> You've successfully submitted the issue. Thanks for improving our platform.");
        },
        failure: function(err) {
            $('#result').html("<i class='fa fa-check' style='color:red'></i> There seems to be a network issue. Please reach out to us at support@ciruitverse.org");
        }
    });
}

var isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);

if (isMobile) {
    var head = document.getElementsByTagName('HEAD')[0];

    // Create new link Element
    var style = document.createElement('style');
    style.textContent = `
@media screen and (max-device-width: 1366px) {
    #tabsBar button {
      font-size: 18px;
      padding: 2px;
    }
    .testbench-manual-panel{
      display: none;
    }
    .tabsCloseButton {
      font-size: 20px;
    }
    #logoWrap{
      height: 100px;
      text-align: right;
      padding: auto;
      bottom: 0;
      padding-bottom: 10px;
      margin-bottom:10px;
    }
    .touchNavlogo{
      background-color:#4AA96C;
    }
    .logo {
      padding-top: 25px;
      height: 70px;
      width: 250px;
      padding-bottom: 15px;
    }

    #tabsBar button {
      order: 99; /* could have better solution */
      width: 25px;
      height: 25px;
    }

    .smallscreen-navbar {
      display: block;
      height:0%;
      width: 100%;
      position: fixed;
      z-index: 999;
      left: 0;
      top: 0;
      overflow-x: hidden;
      transition: 0.5s;
      text-align: left;

    }
    .smallscreen-navbar-inner{
      margin: 0 auto;
      text-align:left;
      padding-left: 2%;
      padding-right: 0%;
      transition: 0.5s;
      height: 0%;
      overflow-y: auto;
      max-height: 125px;
    }

    .smallscreen-navbar-inner li{
      position: relative;
      list-style-type:none;
      font-size: 16px;
      font-family: inherit;
      margin: 10px;
      width: 290px;
      height: 40px;
      text-align: center;
      border-radius: 10px;
      padding: 10px;
      font-weight: bold;
      display: inline-block;
      vertical-align: top;
    }
    .smallNavbar-navbar-ul{

      display:flex;
      font-family: inherit;
      font-weight: bold;
      font-size: 25px;
      margin: 10px;
      padding: 25px;
      width: 100%;
      text-align:  left;

    }

    .smallNavbar-navbar-ul .ulicon{
      position: absolute;
      text-align: right;
      right: 0px;
      padding-right: 20px;
      transform: translate(0px)rotate(0deg);
      transition: 0.7s;
    }
    .smallNavbar-navbar-ul .ulicon.active{
       transform: translate(0px)rotate(180deg);
    }

    #ProjectID{
      font-family: inherit;
      font-weight: bold;
      font-size: 30px;
      padding-right: 50px;
      text-align: center;
      margin: 55px;
    }

    .mobileUserSignIn{
      font-size: 20px;
    }

    .fa-chevron-down{
      font-size: 20px;
      padding-left: 20px;
    }


  .ce-panel{
    display: none;
  }
  .navbar {
      display: none;
  }
  #smallNavbarMenu-btn{
    display: flex;
    position: fixed;
    width: 40px;
    height: 30px;
    z-index: 1000;
    cursor: pointer;
    top: 5px;
    right: 10px;
    justify-content: center;
    border-radius: 5px;
    align-items: center;
    transition: 0.5s;
  }


  #smallNavbarMenu-btn::before{
   content: '';
   position: absolute;
   width: 20px;
   height: 2px;
   transform:translateY(-5px);
   transition: 0.1s;
  }
  #smallNavbarMenu-btn::after{
    content: '';
    position: absolute;
    width: 20px;
    height: 2px;
    transition:0.1s;
    transform: translateY(5px);
  }
  #smallNavbarMenu-btn.active::before{
    transform:translateY(0px) rotate(45deg);
  }
   #smallNavbarMenu-btn.active::after{

     transform: translateY(0px)rotate(-45deg);
   }

  #tabsBar {
    top: 0px;
    position: absolute;
    height: 40px;
    overflow-y: scroll;
    padding-right: 50px;

  }
  .circuits {
    height: 27px;
  }
  .circuitName {
    font-size: large;
  }
  .logixButton {
    line-height: 1em;
    display: inline-block;
    text-decoration: none;
    padding: 5px;
    margin: 7px;
  }
  .logixButton:hover {
    color: seagreen;
  }
  .projectName {
    font-size: 25px;
  }

  #miniMapArea{
    display: none;
  }
  .report-sidebar{
    display: none;
  }
  .icon {
    position: relative;
    width: 35px;
    margin: 5px;
    font-size: 8px;
  }
  #TouchCe-panel {
    color: var(--text-panel);
    width: 235px;
    top: 80px;
    right: 80px;
    display: flex;
    border-radius: 5px;
    z-index: 100;
    transition: background .5s ease-out;
    position: fixed;
    margin: auto;
    padding-top: 10px;
    visibility: hidden;
    font-size: 12px;
    height: 300px;
    background-color: var(--primary);
  }
  #TouchCe-panel::before {
  position: absolute;
  top: 5px;
  content: "";
  right: calc(50% - 154px);
  border-style: solid;
  border-width: 0px 15px 15px 15px;
  transform: rotate(90deg);
  transition: background .5s ease-out;
  padding-top: 30px;

  }
  .Touch-Ce-Menu {
  border-radius: 5px;
  z-index: 100;
  transition: background .5s ease-out;
  position: fixed;
  width: 235px;
  top: 90px;
  right: 80px;
  overflow: auto;
  overflow-x: hidden;
  height: 300px;
  margin: auto;
  box-shadow: rgba(155, 160, 165, 0.2) 0px 8px 24px;
  }
  .ce-name{
    height: 0%;
    width: 100%;
    margin-bottom: 10px;
  font-size: 15px;
  padding-bottom: 25px;
  padding-left: 10px;
  text-align: left;
  font-weight: bold;
  }
  .mp-name{
    height: 0%;
    width: 100%;
    margin-bottom: 10px;
  font-size: 15px;
  padding-bottom: 25px;
  text-align: left;
  font-weight: bold;
  }
  .quickMenu-name{
    height: 0%;
    width: 100%;
    margin-bottom: 10px;
  font-size: 15px;
  padding-bottom: 10px;
  padding-left: 10px;
  text-align: left;
  font-weight: bold;
  }
  #Mobile-menu {
    font: inherit;
    height: 240px;
    transition: background .5s ease-out;
  }
  .mobilepanelHeader {
    border: none;
    border-radius: 0;
    transition: background .5s ease-out;
    ;
  }


  .mobilepanelHeader:after,
  .mobilepanelHeader:before {
    content: "";
    height: 8px;
    display: inline-block;
    right: 12px;
    position: absolute;
    border-radius: 5px;
    top: 50%;
    transform: translateY(-50%) rotate(120deg);
    transition: background .5s ease-out;
    background-color: white;
  }

  .mobilepanelHeader:after {
    transform: translate(260%, -50%) rotate(226deg);
  }
  .ui-accordion-header-active:before {
    transition: background .5s ease-out;
    transform-origin: left;
    transform: translate(29%, -45%) rotate(50deg);
    top: 46%;
  }

  .ui-accordion-header-active:after {
    transform-origin: bottom;
    transform: translate(400%, -50%) rotate(310deg);
    transition: background .5s ease-out;
    top: 46%;
  }
  .properties-panel{
    visibility: hidden;
  }
  #touchElement-property {
    font: inherit;
    width: 240px;
    top: 105px;
    right: 82px;
    position: fixed;
    height: 310px;
    margin: auto;
    transition: background .5s ease-out;
    z-index: 100;
    visibility: hidden;
    font-size: 12px;
  }

  #touchElement-property:before {
    position: absolute;
    top: 39px;
    content: "";
    right: calc(50% - 154px);
    border-style: solid;
    border-width: 0px 15px 15px 15px;
    transform: rotate(90deg);
    transition: background .5s ease-out;
    padding-top: 30px;
  }
  #touch-module-property {
    border-radius: 5px;
    display: inline;
    top: 90px;
    right: 80px;
    position: fixed;
    overflow: scroll;
    height: 330px;
    visibility: none;
    margin: auto;
    transition: background .5s ease-out;
    z-index: 100;
    padding: 15px;
    box-shadow: rgba(155, 160, 165, 0.2) 0px 8px 24px;
  }
  #moduleProperty-inner-2 {
    display: inline;
    width: 85%;
    margin: auto;
    transition: background .5s ease-out;
    z-index: 100;
  }

  #moduleProperty-inner-2>p span {
    display: inline-block;
    font-weight: bold;
  }

  #moduleProperty-inner-2>p button {
    border-radius: 2px;
    margin: 3px;
  }

  #moduleProperty-inner-2:last-child {
    margin-bottom: 15px;
  }
  .slider{
    transition: background .5s ease-out;
  }
  .slider::before{
    transition: background .5s ease-out;
  }

  .timing-diagram-panel{
    display: none;
  }
  .td-name{
    height: 0%;
    width: 100%;
    margin-bottom: 10px;
  font-size: 20px;
  padding-bottom: 0px;
  padding-top: 20px;
  padding-left: 10px;
  text-align: left;
  font-weight: bold;
  font-size: 15px;
  }
  #touchtD-popover{
    display: inline;
    font: inherit;
    width: 400px;
    top: 150px;
    right: 85px;
    position: fixed;
    z-index: 100;
    box-shadow: rgba(155, 160, 165, 0.2) 0px 8px 24px;
    visibility: hidden;
    }
  #touchtD-popover::before {
    position: absolute;
    top: 55px;
    content: "";
    right: calc(50% - 233px);
    border-style: solid;
    border-width: 0px 15px 15px 15px;
    transform: rotate(90deg);
    transition: background .5s ease-out;
    padding-top: 30px;
    z-index: 100;
  }
  #touch-time-daigram {
    width: 400px;
    right: 85px;
    display: inline;
    font: inherit;
    position: fixed;
    margin: auto;
    transition: background .5s ease-out;
    z-index: 100;
    padding: 5px;
    overflow: scroll;
    max-height: 250px;
  }


  .touch-timing-diagram-toolbar {
      padding-left: 4px;
      padding: 2px;
      cursor: default;
  }

  .touch-timing-diagram-toolbar input {
      width: 150px;
      background: transparent !important;
  }
  .touch-panel-button {
      cursor: pointer;
      display: inline;
      width: 30px;
      height: 30px;
      text-align:center;
  }

  #touch-cycle-unit {
      background-color: brown;
      margin-bottom: 10px;
  }

  #touch-timing-diagram-log {
      font-size: 12.5px;
      margin-left: 5px;
      border-radius: 3px;
      padding: 3px;
  }
  #quickmenu-Popover{
    display: inline;
    width: 180px;
    top: 70px;
    right: 85px;
    position: fixed;
    z-index: 100;
    border-color: transparent transparent white transparent;
    visibility: hidden;
    background-color: transparent;
  }

  #quickmenu-Popover::before{
    position: absolute;
    top: 195px;
    content: "";
    right: calc(50% - 125px);
    border-style: solid;
    border-width: 0px 15px 15px 15px;
    transform: rotate(90deg);
    transition: background .5s ease-out;
    padding-top: 30px;
  }
  #quickMenu{
    display: inline;
    border-radius: 5px;
    padding: 10px;
    z-index: 100;
    position: fixed;
    margin: auto;
    width: 180px;
    padding-left: 0px;
    padding-right: 0px;
    font: inherit;
    font-weight: bold;
    text-align: center;
    font-size: 12px;
    overflow: scroll;
    max-height: 250px;
    box-shadow: rgba(155, 160, 165, 0.2) 0px 8px 24px;
  }


  #quickMenu-Inner{
     display: flex;
      flex-wrap: wrap;
      justify-content:center;
      padding-top: 10px;
      padding-left: 10px;
      padding-right: 10px;
  }

  .QuickMenuIcon{
   font-size: 12px;
    padding: 10px;

  }
  .QuickMenuIcon:hover{
    background-color: #42b983;
  }
  .quicMenu-align{
    width: 150px;
    height: 30px;
    padding: 5px;
    font-size: 12px;
    transition: 0.5s;
    border-radius: 0px;
    transition: background .5s ease-out;
    margin: 5px;
    border-radius: 5px;
  }
  .quicMenu-align :hover{
    cursor: default;
  }
  .quicMenu-align-text{
    margin: 15px;
  }
  #touchMenu{
    display: flex;
    flex-direction: column;
    z-index: 100;
    position: fixed;
    top:80px;
    right: 10px;
  }

  .touchMenuIcon{
    font-size: 20px;
    text-align: center;
    padding: 10px;
    height: 45px;
    width: 45px;
    border-radius: 10px;
  }
  #liveMenu{
    display: flex;
    z-index: 99;
    position: fixed;
    top: 90%;
    right: 40px;
  }
  .liveMenuIcon{
    font-size: 18px;
    text-align: center;
    padding: 10px;
    height: 40px;
    width: 40px;
    border-radius: 10px;
    margin:0px;
    position: relative;
  }
  .panelclose{
    position: absolute;
    padding-right: 15px;
    right: 0px;
    background-color:transparent;
  }
  #combinationalAnalysis table {
    width: 460px;
    height: 200px;
  }

  #booleanTable {
    width: 200px;
    height: 200px;
  }
  #logoWrap{
    padding: 10px;
    padding-top: 10px;
  }
  }
  @media screen and (max-device-width: 1024px) {
    #Mobile-menu {
    font: inherit;
    height: 240px;
    transition: background .5s ease-out;
  }
  .mobilepanelHeader {
    border: none;
    border-radius: 0;
    transition: background .5s ease-out;

  }

  .mobilepanelHeader:hover {
    border-radius: 3px;
    opacity: 0.9;
  }
  #touch-time-daigram::before {
    right: calc(50% - 462px);
  }

  }

  @media screen and (max-device-width: 717px) {
    #touchtD-popover{
      top: 25%;
      right: 8%;
    }

  }

  @media screen and (max-device-width: 823px) {
    .Touch-Ce-Menu{
      padding-top: 10px;
      top: 10%;
      right: 93px;
      width:  230px;
      font-size: small;
    }
  #TouchCe-panel{
    top:9%;
    right: 9%;
  }
  #TouchCe-panel::before {
    top: 11%;
  }
  #touch-module-property{
    width: 220px;
  }
  #touchElement-property {
    height: 250px;
    top: 15%;
    right: 8%;
  }

  #touchElement-property:before {
    top: 22%;
    right: calc(50% - 151px);
  }

  #touch-time-daigram {
    width: 350px;
    max-height: 250px;
  }

  .touch-panel-button {
      cursor: pointer;
      display: inline;
      width: 25px;
      height: 25px;
      text-align:center;
  }

  #touchtD-popover{
    width: 350px;
    top: 20%;
    right: 8.6%;
  }
  #touchtD-popover::before {
    top: 200%;
    content: "";
    right: calc(50% - 208px);
  }
  #liveMenu{
    top: 85%;
    right: 70px;
  }
  #quickMenu{
    width: 250px;
    height:250px;
  }
  #quickmenu-Popover{
    font-size: 12px;
    font-family: inherit;
    width: 250px;
    height:250px;
    top: 15%;
    right: 8%;
  }

  .QuickMenuIcon{

     padding: 10px;
  }
   .quicMenu-align{
    font-size: 14px;
     width: 170px;
     height: 35px;
     padding: 5px;
   }
  #quickmenu-Popover::before{
    top: 183px;
    right: calc(50% - 160px);
  }
  .quickMenu-name{
    height: 0%;
    width: 100%;
  font-size: 15px;
  padding-bottom: 20px;
  }

   #touchMenu{
    display: flex;
    flex-direction: column;
    position: fixed;
    top: 15%;
    right: 10px;
  }

  .touchMenuIcon{
    font-size: 19px;
    text-align: center;
    padding: 10px;
    height: 45px;
    width: 45px;
    border-radius: 10px;
  }
  .colorThemesDialog {
    top: 20%;
    height: 200px !important;
    overflow-x: auto;
  }
  #saveImageDialog {
    height: 50px;
  }
  .download-dialog-section-2 {
    background: transparent;
    width: 80%;
    display: inline-flex;
    justify-content: space-around;
  }
  .liveMenuIcon{
    font-size: 15px;
    text-align: center;
    padding: 10px;
    height: 40px;
    width: 40px;
  }
  #combinationalAnalysis table {
    width: 460px;
    height: 100px;
  }

  #booleanTable {
    width: 200px;
    height: 200px;
  }
  }`;
    head.appendChild(style);
}
