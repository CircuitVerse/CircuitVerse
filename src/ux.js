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
import { newCircuit, circuitProperty } from './circuit';
import modules from './modules';
import { updateRestrictedElementsInScope } from './restrictedElementDiv';
import { paste } from './events';
import { setProjectName, getProjectName } from './data/save';
import { changeScale } from './canvasApi';
import updateTheme from "./themer/themer";
import { generateImage, generateSaveData } from './data/save';
import { setupVerilogExportCodeWindow } from './verilog';
import { setupBitConvertor} from './utils';
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
        newCircuit();
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

    $('#report').on('click',function(){
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
        $('#moduleProperty-inner').append("<div id='moduleProperty-header'>" + obj.objectType + "</div>");

        if (obj.subcircuitMutableProperties && obj.canShowInSubcircuit) {
            for (let attr in obj.subcircuitMutableProperties) {
                var prop = obj.subcircuitMutableProperties[attr];
                if (obj.subcircuitMutableProperties[attr].type == "number") {
                    var s = "<p>" + prop.name + "<input class='objectPropertyAttribute' type='number'  name='" + prop.func + "' min='" + (prop.min || 0) + "' max='" + (prop.max || 200) + "' value=" + obj[attr] + "></p>";
                    $('#moduleProperty-inner').append(s);
                }
                else if (obj.subcircuitMutableProperties[attr].type == "text") {
                    var s = "<p>" + prop.name + "<input class='objectPropertyAttribute' type='text'  name='" + prop.func + "' maxlength='" + (prop.maxlength || 200) + "' value=" + obj[attr] + "></p>";
                    $('#moduleProperty-inner').append(s);
                }
                else if (obj.subcircuitMutableProperties[attr].type == "checkbox"){
                    var s = "<p>" + prop.name + "<label class='switch'> <input type='checkbox' " + ["", "checked"][obj.subcircuitMetadata.showLabelInSubcircuit + 0] + " class='objectPropertyAttributeChecked' name='" + prop.func + "'> <span class='slider'></span> </label></p>";
                    $('#moduleProperty-inner').append(s);
                }
            }
            if (!obj.labelDirectionFixed) {
                if(!obj.subcircuitMetadata.labelDirection) obj.subcircuitMetadata.labelDirection = obj.labelDirection;
                var s = $("<select class='objectPropertyAttribute' name='newLabelDirection'>" + "<option value='RIGHT' " + ["", "selected"][+(obj.subcircuitMetadata.labelDirection == "RIGHT")] + " >RIGHT</option><option value='DOWN' " + ["", "selected"][+(obj.subcircuitMetadata.labelDirection == "DOWN")] + " >DOWN</option><option value='LEFT' " + "<option value='RIGHT'" + ["", "selected"][+(obj.subcircuitMetadata.labelDirection == "LEFT")] + " >LEFT</option><option value='UP' " + "<option value='RIGHT'" + ["", "selected"][+(obj.subcircuitMetadata.labelDirection == "UP")] + " >UP</option>" + "</select>");
                s.val(obj.subcircuitMetadata.labelDirection);
                $('#moduleProperty-inner').append("<p>Label Direction: " + $(s).prop('outerHTML') + "</p>");
            }
        }
            
    }
    else if (simulationArea.lastSelected === undefined || ['Wire', 'CircuitElement', 'Node'].indexOf(simulationArea.lastSelected.objectType) !== -1) {
        $('#moduleProperty').show();
        $('#moduleProperty-inner').append("<div id='moduleProperty-header'>" + 'Project Properties' + '</div>');
        $('#moduleProperty-inner').append(`<p><span>Project:</span> <input id='projname' class='objectPropertyAttribute' type='text' autocomplete='off' name='setProjectName'  value='${getProjectName() || 'Untitled'}'></p>`);
        $('#moduleProperty-inner').append(`<p><span>Circuit:</span> <input id='circname' class='objectPropertyAttribute' type='text' autocomplete='off' name='changeCircuitName'  value='${globalScope.name || 'Untitled'}'></p>`);
        $('#moduleProperty-inner').append(`<p><span>Clock Time (ms):</span> <input class='objectPropertyAttribute' min='50' type='number' style='width:100px' step='10' name='changeClockTime'  value='${simulationArea.timePeriod}'></p>`);
        $('#moduleProperty-inner').append(`<p><span>Clock Enabled:</span> <label class='switch'> <input type='checkbox' ${['', 'checked'][simulationArea.clockEnabled + 0]} class='objectPropertyAttributeChecked' name='changeClockEnable' > <span class='slider'></span></label></p>`);
        $('#moduleProperty-inner').append(`<p><span>Lite Mode:</span> <label class='switch'> <input type='checkbox' ${['', 'checked'][lightMode + 0]} class='objectPropertyAttributeChecked' name='changeLightMode' > <span class='slider'></span> </label></p>`);
        $('#moduleProperty-inner').append("<p><button type='button' class='objectPropertyAttributeChecked btn btn-xs custom-btn--primary' name='toggleLayoutMode' >Edit Layout</button><button type='button' class='objectPropertyAttributeChecked btn btn-xs custom-btn--tertiary' name='deleteCurrentCircuit' >Delete Circuit</button> </p>");
        // $('#moduleProperty-inner').append("<p>  ");
    } else {
        $('#moduleProperty').show();

        $('#moduleProperty-inner').append(`<div id='moduleProperty-header'>${obj.objectType}</div>`);
        // $('#moduleProperty').append("<input type='range' name='points' min='1' max='32' value="+obj.bitWidth+">");
        if (!obj.fixedBitWidth) { $('#moduleProperty-inner').append(`<p><span>BitWidth:</span> <input class='objectPropertyAttribute' type='number'  name='newBitWidth' min='1' max='32' value=${obj.bitWidth}></p>`); }

        if (obj.changeInputSize) { $('#moduleProperty-inner').append(`<p><span>Input Size:</span> <input class='objectPropertyAttribute' type='number'  name='changeInputSize' min='2' max='10' value=${obj.inputSize}></p>`); }
        
        if (!obj.propagationDelayFixed) { $('#moduleProperty-inner').append(`<p><span>Delay:</span> <input class='objectPropertyAttribute' type='number'  name='changePropagationDelay' min='0' max='100000' value=${obj.propagationDelay}></p>`); }
        
        if (!obj.disableLabel)
        $('#moduleProperty-inner').append(`<p><span>Label:</span> <input class='objectPropertyAttribute' type='text'  name='setLabel' autocomplete='off'  value='${escapeHtml(obj.label)}'></p>`);

        var s;
        if (!obj.labelDirectionFixed) {
            s = $(`${"<select class='objectPropertyAttribute' name='newLabelDirection'>" + "<option value='RIGHT' "}${['', 'selected'][+(obj.labelDirection === 'RIGHT')]} >RIGHT</option><option value='DOWN' ${['', 'selected'][+(obj.labelDirection === 'DOWN')]} >DOWN</option><option value='LEFT' ` + `<option value='RIGHT'${['', 'selected'][+(obj.labelDirection === 'LEFT')]} >LEFT</option><option value='UP' ` + `<option value='RIGHT'${['', 'selected'][+(obj.labelDirection === 'UP')]} >UP</option>` + '</select>');
            s.val(obj.labelDirection);
            $('#moduleProperty-inner').append(`<p><span>Label Direction:</span> ${$(s).prop('outerHTML')}</p>`);
        }


        if (!obj.directionFixed) {
            s = $(`${"<select class='objectPropertyAttribute' name='newDirection'>" + "<option value='RIGHT' "}${['', 'selected'][+(obj.direction === 'RIGHT')]} >RIGHT</option><option value='DOWN' ${['', 'selected'][+(obj.direction === 'DOWN')]} >DOWN</option><option value='LEFT' ` + `<option value='RIGHT'${['', 'selected'][+(obj.direction === 'LEFT')]} >LEFT</option><option value='UP' ` + `<option value='RIGHT'${['', 'selected'][+(obj.direction === 'UP')]} >UP</option>` + '</select>');
            $('#moduleProperty-inner').append(`<p><span>Direction:</span> ${$(s).prop('outerHTML')}</p>`);
        } else if (!obj.orientationFixed) {
            s = $(`${"<select class='objectPropertyAttribute' name='newDirection'>" + "<option value='RIGHT' "}${['', 'selected'][+(obj.direction === 'RIGHT')]} >RIGHT</option><option value='DOWN' ${['', 'selected'][+(obj.direction === 'DOWN')]} >DOWN</option><option value='LEFT' ` + `<option value='RIGHT'${['', 'selected'][+(obj.direction === 'LEFT')]} >LEFT</option><option value='UP' ` + `<option value='RIGHT'${['', 'selected'][+(obj.direction === 'UP')]} >UP</option>` + '</select>');
            $('#moduleProperty-inner').append(`<p><span>Orientation:</span> ${$(s).prop('outerHTML')}</p>`);
        }

        if (obj.mutableProperties) {
            for (const attr in obj.mutableProperties) {
                var prop = obj.mutableProperties[attr];
                if (obj.mutableProperties[attr].type === 'number') {
                    s = `<p><span>${prop.name}</span><input class='objectPropertyAttribute' type='number'  name='${prop.func}' min='${prop.min || 0}' max='${prop.max || 200}' value=${obj[attr]}></p>`;
                    $('#moduleProperty-inner').append(s);
                } else if (obj.mutableProperties[attr].type === 'text') {
                    s = `<p><span>${prop.name}</span><input class='objectPropertyAttribute' type='text' autocomplete='off'  name='${prop.func}' maxlength='${prop.maxlength || 200}' value=${obj[attr]}></p>`;
                    $('#moduleProperty-inner').append(s);
                } else if (obj.mutableProperties[attr].type === 'button') {
                    s = `<p class='btn-parent'><button class='objectPropertyAttribute btn custom-btn--secondary' type='button'  name='${prop.func}'>${prop.name}</button></p>`;
                    $('#moduleProperty-inner').append(s);
                }
                else if (obj.mutableProperties[attr].type === 'textarea') {
                    s = `<p><span>${prop.name}</span><textarea class='objectPropertyAttribute' type='text' autocomplete='off' rows="9" name='${prop.func}'>${obj[attr]}</textarea></p>`;
                    $('#moduleProperty-inner').append(s);
                }
            }
        }
    }

    var helplink = obj && (obj.helplink);
    if (helplink) {
        $('#moduleProperty-inner').append('<p class="btn-parent"><button id="HelpButton" class="btn btn-primary btn-xs" type="button" >&#9432 Help</button></p>');
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
    $('#moduleProperty-inner').empty();
    $('#moduleProperty').hide();
    prevPropertyObjSet(undefined);
    $('.objectPropertyAttribute').unbind('change keyup paste click');
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

/**
 * listener for opening the prompt for bin conversion
 * @category ux
 */
$('#bitconverter').on('click',() => {
    $('#bitconverterprompt').dialog({
    resizable:false,
        buttons: [
            {
                text: 'Reset',
                click() {
                    $('#decimalInput').val('0');
                    $('#binaryInput').val('0');
                    $('#octalInput').val('0');
                    $('#hexInput').val('0');
                },
            },
        ],
    });
});

// convertors
const convertors = {
    dec2bin: (x) => `0b${x.toString(2)}`,
    dec2hex: (x) => `0x${x.toString(16)}`,
    dec2octal: (x) => `0${x.toString(8)}`,
};

function setBaseValues(x) {
    if (isNaN(x)) return;
    $('#binaryInput').val(convertors.dec2bin(x));
    $('#octalInput').val(convertors.dec2octal(x));
    $('#hexInput').val(convertors.dec2hex(x));
    $('#decimalInput').val(x);
}

$('#decimalInput').on('keyup', () => {
    var x = parseInt($('#decimalInput').val(), 10);
    setBaseValues(x);
});

$('#binaryInput').on('keyup', () => {
    var x = parseInt($('#binaryInput').val(), 2);
    setBaseValues(x);
});

$('#hexInput').on('keyup', () => {
    var x = parseInt($('#hexInput').val(), 16);
    setBaseValues(x);
});

$('#octalInput').on('keyup', () => {
    var x = parseInt($('#octalInput').val(), 8);
    setBaseValues(x);
});

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
