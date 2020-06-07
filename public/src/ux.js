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
const ctxPos = {
    x: 0,
    y: 0,
    visible: false,
};

/**
 * Function hides the context menu
 * @category ux
 */
function hideContextMenu() {
    const el = document.getElementById('contextMenu');
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
        top: `${ctxPos.y}px`,
        left: `${ctxPos.x}px`,
    });
    ctxPos.visible = true;
    return false;
}

/**
 * Function is called when context item is clicked
 * @param {number} id - id of the optoin selected
 * @category ux
 */
function menuItemClicked(id) {
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
    const ctxEl = document.getElementById('contextMenu');
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
    $('#menu').accordion({
        collapsible: true,
        active: false,
        heightStyle: 'content',
    });
    // $( "#plot" ).resizable({
    // handles: 'n',
    //     // minHeight:200,
    // });

    $('.logixModules').mousedown(function () {
        // ////console.log(uxvar.smartDropXX,uxvar.smartDropYY);
        if (simulationArea.lastSelected && simulationArea.lastSelected.newElement) simulationArea.lastSelected.delete();
        const obj = new modules[this.id](); // (simulationArea.mouseX,simulationArea.mouseY);
        // obj = new modules[this.id](); // (simulationArea.mouseX,simulationArea.mouseY);
        simulationArea.lastSelected = obj;
        // simulationArea.lastSelected=obj;
        // simulationArea.mouseDown=true;
        uxvar.smartDropXX += 70;
        if (uxvar.smartDropXX / globalScope.scale > width) {
            uxvar.smartDropXX = 50;
            uxvar.smartDropYY += 80;
        }
    });
    $('.logixButton').click(function () {
        logixFunction[this.id]();
    });
    // let dummyCounter=0;


    $('.logixModules').hover(function () {
        // Tooltip can be statically defined in the prototype.
        const { tooltipText } = modules[this.id].prototype;
        if (!tooltipText) return;
        $('#Help').addClass('show');
        $('#Help').empty();
        // //console.log("SHOWING")
        $('#Help').append(tooltipText);
    }); // code goes in document ready fn only
    $('.logixModules').mouseleave(() => {
        $('#Help').removeClass('show');
    }); // code goes in document ready fn only


    // $('#saveAsImg').click(function(){
    //     saveAsImg();
    // });
    // $('#Save').click(function(){
    //     Save();
    // });
    // $('#moduleProperty').draggable();
}

/**
 * Keeps in check which property is being displayed
 * @category ux
 */
let prevPropertyObj;

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
    // console.log(obj)
    if (obj === prevPropertyObjGet()) return;
    hideProperties();
    prevPropertyObjSet(obj);
    if (simulationArea.lastSelected === undefined || ['Wire', 'CircuitElement', 'Node'].indexOf(simulationArea.lastSelected.objectType) !== -1) {
        $('#moduleProperty').show();
        $('#moduleProperty-inner').append("<div id='moduleProperty-header'>" + 'Project Properties' + '</div>');
        $('#moduleProperty-inner').append(`<p>Project : <input class='objectPropertyAttribute' type='text'  name='setProjectName'  value='${projectName || 'Untitled'}'></p>`);
        $('#moduleProperty-inner').append(`<p>Circuit : <input class='objectPropertyAttribute' type='text'  name='changeCircuitName'  value='${globalScope.name || 'Untitled'}'></p>`);
        $('#moduleProperty-inner').append(`<p>Clock Time : <input class='objectPropertyAttribute' min='50' type='number' style='width:100px' step='10' name='changeClockTime'  value='${simulationArea.timePeriod}'>ms</p>`);
        $('#moduleProperty-inner').append(`<p>Clock Enabled : <label class='switch'> <input type='checkbox' ${['', 'checked'][simulationArea.clockEnabled + 0]} class='objectPropertyAttributeChecked' name='changeClockEnable' > <span class='slider'></span> </label></p>`);
        $('#moduleProperty-inner').append(`<p>Lite Mode : <label class='switch'> <input type='checkbox' ${['', 'checked'][lightMode + 0]} class='objectPropertyAttributeChecked' name='changeLightMode' > <span class='slider'></span> </label></p>`);
        // $('#moduleProperty-inner').append("<p>  ");
        $('#moduleProperty-inner').append("<p><button type='button' class='objectPropertyAttributeChecked btn btn-danger btn-xs' name='deleteCurrentCircuit' >Delete Circuit</button>  <button type='button' class='objectPropertyAttributeChecked btn btn-primary btn-xs' name='toggleLayoutMode' >Edit Layout</button> </p>");
    } else {
        $('#moduleProperty').show();

        $('#moduleProperty-inner').append(`<div id='moduleProperty-header'>${obj.objectType}</div>`);
        // $('#moduleProperty').append("<input type='range' name='points' min='1' max='32' value="+obj.bitWidth+">");
        if (!obj.fixedBitWidth) { $('#moduleProperty-inner').append(`<p>BitWidth: <input class='objectPropertyAttribute' type='number'  name='newBitWidth' min='1' max='32' value=${obj.bitWidth}></p>`); }

        if (obj.changeInputSize) { $('#moduleProperty-inner').append(`<p>Input Size: <input class='objectPropertyAttribute' type='number'  name='changeInputSize' min='2' max='10' value=${obj.inputSize}></p>`); }

        if (!obj.propagationDelayFixed) { $('#moduleProperty-inner').append(`<p>Delay: <input class='objectPropertyAttribute' type='number'  name='changePropagationDelay' min='0' max='100000' value=${obj.propagationDelay}></p>`); }


        $('#moduleProperty-inner').append(`<p>Label: <input class='objectPropertyAttribute' type='text'  name='setLabel'  value='${escapeHtml(obj.label)}'></p>`);

        let s;
        if (!obj.labelDirectionFixed) {
            s = $(`${"<select class='objectPropertyAttribute' name='newLabelDirection'>" + "<option value='RIGHT' "}${['', 'selected'][+(obj.labelDirection === 'RIGHT')]} >RIGHT</option><option value='DOWN' ${['', 'selected'][+(obj.labelDirection === 'DOWN')]} >DOWN</option><option value='LEFT' ` + `<option value='RIGHT'${['', 'selected'][+(obj.labelDirection === 'LEFT')]} >LEFT</option><option value='UP' ` + `<option value='RIGHT'${['', 'selected'][+(obj.labelDirection === 'UP')]} >UP</option>` + '</select>');
            s.val(obj.labelDirection);
            $('#moduleProperty-inner').append(`<p>Label Direction: ${$(s).prop('outerHTML')}</p>`);
        }


        if (!obj.directionFixed) {
            s = $(`${"<select class='objectPropertyAttribute' name='newDirection'>" + "<option value='RIGHT' "}${['', 'selected'][+(obj.direction === 'RIGHT')]} >RIGHT</option><option value='DOWN' ${['', 'selected'][+(obj.direction === 'DOWN')]} >DOWN</option><option value='LEFT' ` + `<option value='RIGHT'${['', 'selected'][+(obj.direction === 'LEFT')]} >LEFT</option><option value='UP' ` + `<option value='RIGHT'${['', 'selected'][+(obj.direction === 'UP')]} >UP</option>` + '</select>');
            $('#moduleProperty-inner').append(`<p>Direction: ${$(s).prop('outerHTML')}</p>`);
        } else if (!obj.orientationFixed) {
            s = $(`${"<select class='objectPropertyAttribute' name='newDirection'>" + "<option value='RIGHT' "}${['', 'selected'][+(obj.direction === 'RIGHT')]} >RIGHT</option><option value='DOWN' ${['', 'selected'][+(obj.direction === 'DOWN')]} >DOWN</option><option value='LEFT' ` + `<option value='RIGHT'${['', 'selected'][+(obj.direction === 'LEFT')]} >LEFT</option><option value='UP' ` + `<option value='RIGHT'${['', 'selected'][+(obj.direction === 'UP')]} >UP</option>` + '</select>');
            $('#moduleProperty-inner').append(`<p>Orientation: ${$(s).prop('outerHTML')}</p>`);
        }

        if (obj.mutableProperties) {
            for (const attr in obj.mutableProperties) {
                const prop = obj.mutableProperties[attr];
                if (obj.mutableProperties[attr].type === 'number') {
                    s = `<p>${prop.name}<input class='objectPropertyAttribute' type='number'  name='${prop.func}' min='${prop.min || 0}' max='${prop.max || 200}' value=${obj[attr]}></p>`;
                    $('#moduleProperty-inner').append(s);
                } else if (obj.mutableProperties[attr].type === 'text') {
                    s = `<p>${prop.name}<input class='objectPropertyAttribute' type='text'  name='${prop.func}' maxlength='${prop.maxlength || 200}' value=${obj[attr]}></p>`;
                    $('#moduleProperty-inner').append(s);
                } else if (obj.mutableProperties[attr].type === 'button') {
                    s = `<p><button class='objectPropertyAttribute btn btn-primary btn-xs' type='button'  name='${prop.func}'>${prop.name}</button></p>`;
                    $('#moduleProperty-inner').append(s);
                }
            }
        }
    }

    const helplink = obj && (obj.helplink);
    if (helplink) {
        $('#moduleProperty-inner').append('<p><button id="HelpButton" class="btn btn-primary btn-xs" type="button" >Help &#9432</button></p>');
        $('#HelpButton').click(() => {
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
        // return;
        // ////console.log(this.name+":"+this.value);
        checkValidBitWidth();
        scheduleUpdate();
        updateCanvasSet(true);
        wireToBeCheckedSet(1);
        if (simulationArea.lastSelected && simulationArea.lastSelected[this.name]) {
            prevPropertyObjSet(simulationArea.lastSelected[this.name](this.value) || prevPropertyObjGet());
        } else {
            circuitProperty[this.name](this.value);
        }
    });
    $('.objectPropertyAttributeChecked').on('change keyup paste click', function () {
        // return;
        // console.log(this.name+":"+this.value);
        scheduleUpdate();
        updateCanvasSet(true);
        wireToBeCheckedSet(1);
        if (simulationArea.lastSelected && simulationArea.lastSelected[this.name]) {
            prevPropertyObjSet(simulationArea.lastSelected[this.name](this.value) || prevPropertyObjGet());
        } else {
            circuitProperty[this.name](this.checked);
        }
    });
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
    $('input').blur();
    if (simulationArea.lastSelected && !(simulationArea.lastSelected.objectType === 'Node' && simulationArea.lastSelected.type !== 2)) simulationArea.lastSelected.delete();
    for (let i = 0; i < simulationArea.multipleObjectSelections.length; i++) {
        if (!(simulationArea.multipleObjectSelections[i].objectType === 'Node' && simulationArea.multipleObjectSelections[i].type !== 2)) simulationArea.multipleObjectSelections[i].cleanDelete();
    }
    hideProperties();
    simulationArea.multipleObjectSelections = [];

    // Updated restricted elements
    updateCanvasSet(true);
    scheduleUpdate();
    updateRestrictedElementsInScope();
}

$('#bitconverterprompt').append(`
<label style='color:grey'>Decimal value</label><br><input  type='text' id='decimalInput' label="Decimal" name='text1'><br><br>
<label  style='color:grey'>Binary value</label><br><input  type='text' id='binaryInput' label="Binary" name='text1'><br><br>
<label  style='color:grey'>Octal value</label><br><input  type='text' id='octalInput' label="Octal" name='text1'><br><br>
<label  style='color:grey'>Hexadecimal value</label><br><input  type='text' id='hexInput' label="Hex" name='text1'><br><br>
`);
/**
 * listener for opening the prompt for bin conversion
 * @category ux
 */
$('#bitconverter').click(() => {
    $('#bitconverterprompt').dialog({
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
    const x = parseInt($('#decimalInput').val(), 10);
    setBaseValues(x);
});

$('#binaryInput').on('keyup', () => {
    const x = parseInt($('#binaryInput').val(), 2);
    setBaseValues(x);
});

$('#hexInput').on('keyup', () => {
    const x = parseInt($('#hexInput').val(), 16);
    setBaseValues(x);
});

$('#octalInput').on('keyup', () => {
    const x = parseInt($('#octalInput').val(), 8);
    setBaseValues(x);
});
