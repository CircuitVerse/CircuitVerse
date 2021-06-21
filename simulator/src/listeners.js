/* eslint-disable no-alert */
/* eslint-disable no-plusplus */
/* eslint-disable no-var */
/* eslint-disable vars-on-top */
/* eslint-disable func-names */
/* eslint-disable max-len */
/* eslint-disable no-undef */
/* eslint-disable eqeqeq */
/* eslint-disable prefer-template */
/* eslint-disable no-param-reassign */
// Most Listeners are stored here
import {
    layoutModeGet, tempBuffer, layoutUpdate, setupLayoutModePanelListeners,
} from './layoutMode';
import simulationArea from './simulationArea';
import {
    scheduleUpdate, update, updateSelectionsAndPane,
    wireToBeCheckedSet, updatePositionSet, updateSimulationSet,
    updateCanvasSet, gridUpdateSet, errorDetectedSet,
} from './engine';
import { changeScale, findDimensions } from './canvasApi';
import { scheduleBackup } from './data/backupCircuit';
import {
    hideProperties, deleteSelected, uxvar, fullView, createElement,
} from './ux';
import {
    updateRestrictedElementsList, updateRestrictedElementsInScope, hideRestricted, showRestricted,
} from './restrictedElementDiv';
import { removeMiniMap, updatelastMinimapShown } from './minimap';
import undo from './data/undo';
import { copy, paste, selectAll } from './events';
// Import save from './data/save';
import { verilogModeGet } from './Verilog2CV';
import { setupTimingListeners } from './plotArea';

const unit = 10;
let coordinate;
const returnCoordinate = {
    x: 0,
    y: 0,
};

let currDistance = 0;
let distance = 0;
let pinchZ = 0;
let centreX;
let centreY;
let timeout;
let lastTap = 0;
let initX;
let initY;
let currX;
let currY;

/**
 *
 * @param {event} e
 * @param {elementId} elementId
 * Function to drag element of selected ID
 */

function dragStart(e, elementId) {
    initX = e.touches[0].clientX - elementId.offsetLeft;
    initY = e.touches[0].clientY - elementId.offsetTop;
}

function dragMove(e, elementId) {
    currY = e.touches[0].clientY - initY;
    currX = e.touches[0].clientX - initX;

    elementId.style.left = currX + 'px';
    elementId.style.top = currY + 'px';
}

function dragEnd() {
    initX = currX;
    initY = currY;
}
/**
 *
 * @param {event} e
 * function for double click or double tap
 */
function onDoubleClickorTap(e) {
    updateCanvasSet(true);
    if (simulationArea.lastSelected && simulationArea.lastSelected.dblclick !== undefined) {
        simulationArea.lastSelected.dblclick();
    } else if (!simulationArea.shiftDown) {
        simulationArea.multipleObjectSelections = [];
    }
    scheduleUpdate(2);
    e.preventDefault();
}

/**
 *
 * @param {event} e
 * function to detect tap and double tap
 */
function getTap(e) {
    const currentTime = new Date().getTime();
    const tapLength = currentTime - lastTap;
    clearTimeout(timeout);
    if (tapLength < 500 && tapLength > 0) {
        onDoubleClickorTap(e);
    } else {
    // Single tap
    }

    lastTap = currentTime;
    e.preventDefault();
}

const isIe = (navigator.userAgent.toLowerCase().indexOf('msie') != -1 || navigator.userAgent.toLowerCase().indexOf('trident') != -1);

/* Function to getCoordinate
    *If touch is enable then it will return touch coordinate
    *else it will return mouse coordinate
 */
export function getCoordinate(e) {
    if (simulationArea.touch) {
        returnCoordinate.x = e.touches[0].clientX;
        returnCoordinate.y = e.touches[0].clientY;
        return returnCoordinate;
    }

    if (!simulationArea.touch) {
        returnCoordinate.x = e.clientX;
        returnCoordinate.y = e.clientY;
        return returnCoordinate;
    }

    return returnCoordinate;
}

/* Function for Panstop on simulator
   *For now variable name starts with mouse like mouseDown are used both
    touch and mouse will change in future
*/
export function pinchZoom(e, globalScope) {
    gridUpdateSet(true);
    scheduleUpdate();
    updateSimulationSet(true);
    updatePositionSet(true);
    updateCanvasSet(true);
    // Calculating distance between touch to see if its pinchIN or pinchOut
    distance = Math.sqrt((e.touches[1].clientX - e.touches[0].clientX)
  * (e.touches[1].clientX - e.touches[0].clientX), (e.touches[1].clientY - e.touches[0].clientY)
  * (e.touches[1].clientY - e.touches[0].clientY));
    centreX = (e.touches[0].clientX + e.touches[1].clientX) / 2;
    centreY = (e.touches[0].clientY + e.touches[1].clientY) / 2;
    const rect = simulationArea.canvas.getBoundingClientRect();
    const RawX = (centreX - rect.left) * DPR;
    const RawY = (centreY - rect.top) * DPR;
    const Xf = (RawX - globalScope.ox) / globalScope.scale;
    const Yf = (RawY - globalScope.oy) / globalScope.scale;
    const currCentreX = Math.round(Xf / unit) * unit;
    const currCentreY = Math.round(Yf / unit) * unit;
    if (distance >= currDistance) {
        pinchZ += 0.03;
        currDistance = distance;
    } else if (currDistance >= distance) {
        pinchZ -= 0.03;
        currDistance = distance;
    }

    if (pinchZ >= 2) {
        pinchZ = 2;
    } else if (pinchZ <= 1) {
        pinchZ = 1;
    }

    const oldScale = globalScope.scale;
    globalScope.scale = Math.max(0.5, Math.min(4 * DPR, pinchZ * 2));
    globalScope.scale = Math.round(globalScope.scale * 10) / 10;
    globalScope.ox -= Math.round(currCentreX * (globalScope.scale - oldScale));
    globalScope.oy -= Math.round(currCentreY * (globalScope.scale - oldScale));
    gridUpdateSet(true);
    scheduleUpdate(1);
}

/*
 *Function to start the pan in simulator
 *Works for both touch and Mouse
 *For now variable name starts from mouse like mouseDown are used both
  touch and mouse will change in future
 */
function panStart(e) {
    coordinate = getCoordinate(e);
    simulationArea.mouseDown = true;
    // Deselect Input
    if (document.activeElement instanceof HTMLElement) {
        document.activeElement.blur();
    }

    errorDetectedSet(false);
    updateSimulationSet(true);
    updatePositionSet(true);
    updateCanvasSet(true);
    simulationArea.lastSelected = undefined;
    simulationArea.selected = false;
    simulationArea.hover = undefined;
    const rect = simulationArea.canvas.getBoundingClientRect();
    simulationArea.mouseDownRawX = (coordinate.x - rect.left) * DPR;
    simulationArea.mouseDownRawY = (coordinate.y - rect.top) * DPR;
    simulationArea.mouseDownX = Math.round(((simulationArea.mouseDownRawX - globalScope.ox) / globalScope.scale) / unit) * unit;
    simulationArea.mouseDownY = Math.round(((simulationArea.mouseDownRawY - globalScope.oy) / globalScope.scale) / unit) * unit;
    if (simulationArea.touch) {
        simulationArea.mouseX = simulationArea.mouseDownX;
        simulationArea.mouseY = simulationArea.mouseDownY;
    }

    simulationArea.oldx = globalScope.ox;
    simulationArea.oldy = globalScope.oy;
    e.preventDefault();
    scheduleBackup();
    scheduleUpdate(1);
    $('.dropdown.open').removeClass('open');
}

/*
 * Function to pan in simulator
 * Works for both touch and Mouse
 * Pinch to zoom also implemented in the same
 * For now variable name starts from mouse like mouseDown are used both
   touch and mouse will change in future
 */

function panMove(e) {
// If only one  it touched
// pan left or right
    if (!simulationArea.touch || e.touches.length === 1) {
        coordinate = getCoordinate(e);
        const rect = simulationArea.canvas.getBoundingClientRect();
        simulationArea.mouseRawX = (coordinate.x - rect.left) * DPR;
        simulationArea.mouseRawY = (coordinate.y - rect.top) * DPR;
        simulationArea.mouseXf = (simulationArea.mouseRawX - globalScope.ox) / globalScope.scale;
        simulationArea.mouseYf = (simulationArea.mouseRawY - globalScope.oy) / globalScope.scale;
        simulationArea.mouseX = Math.round(simulationArea.mouseXf / unit) * unit;
        simulationArea.mouseY = Math.round(simulationArea.mouseYf / unit) * unit;
        updateCanvasSet(true);
        if (simulationArea.lastSelected && (simulationArea.mouseDown || simulationArea.lastSelected.newElement)) {
            updateCanvasSet(true);
            let fn;

            if (simulationArea.lastSelected == globalScope.root) {
                fn = function () {
                    updateSelectionsAndPane();
                };
            } else {
                fn = function () {
                    if (simulationArea.lastSelected) {
                        simulationArea.lastSelected.update();
                    }
                };
            }

            scheduleUpdate(0, 20, fn);
        } else {
            scheduleUpdate(0, 200);
        }
    }

    // If two fingures are touched
    // pinchZoom
    if (simulationArea.touch && e.touches.length === 2) {
        pinchZoom(e, globalScope);
    }
}

function panStop(e) {
    simulationArea.mouseDown = false;
    if (!lightMode) {
        updatelastMinimapShown();
        setTimeout(removeMiniMap, 2000);
    }

    errorDetectedSet(false);
    updateSimulationSet(true);
    updatePositionSet(true);
    updateCanvasSet(true);
    gridUpdateSet(true);
    wireToBeCheckedSet(1);

    scheduleUpdate(1);
    simulationArea.mouseDown = false;

    // eslint-disable-next-line no-plusplus
    for (let i = 0; i < 2; i++) {
        updatePositionSet(true);
        wireToBeCheckedSet(1);
        update();
    }

    errorDetectedSet(false);
    updateSimulationSet(true);
    updatePositionSet(true);
    updateCanvasSet(true);
    gridUpdateSet(true);
    wireToBeCheckedSet(1);

    scheduleUpdate(1);
    // Var rect = simulationArea.canvas.getBoundingClientRect();

    if (!(simulationArea.mouseRawX < 0 || simulationArea.mouseRawY < 0 || simulationArea.mouseRawX > width || simulationArea.mouseRawY > height)) {
        uxvar.smartDropXX = simulationArea.mouseX + 100; // Math.round(((simulationArea.mouseRawX - globalScope.ox+100) / globalScope.scale) / unit) * unit;
        uxvar.smartDropYY = simulationArea.mouseY - 50; // Math.round(((simulationArea.mouseRawY - globalScope.oy+100) / globalScope.scale) / unit) * unit;
    }

    if (simulationArea.touch) {
    // Current circuit element should not spwan above last circuit element
        findDimensions(globalScope);
        simulationArea.mouseX = 100 + simulationArea.maxWidth || 0;
        simulationArea.mouseY = simulationArea.minHeight || 0;
        getTap(e);
    }
}

/* Function for Pinch zoom
    *This function is used to ZoomIN and Zoomout on Simulator using touch
*/

export default function startListeners() {
    $('#deleteSelected').on('click', () => {
        deleteSelected();
    });

    $('#zoomIn').on('click', () => {
        changeScale(0.2, 'zoomButton', 'zoomButton', 2);
    });

    $('#zoomOut').on('click', () => {
        changeScale(-0.2, 'zoomButton', 'zoomButton', 2);
    });

    $('#undoButton').on('click', () => {
        undo();
    });

    $('#viewButton').on('click', () => {
        fullView();
    });

    $('#projectName').on('click', () => {
        simulationArea.lastSelected = globalScope.root;
        setTimeout(() => {
            document.getElementById('projname').select();
        }, 100);
    });
    /* Makes tabs reordering possible by making them sortable */
    $('#tabsBar').sortable({
        containment: 'parent',
        items: '> div',
        revert: false,
        opacity: 0.5,
        tolerance: 'pointer',
        placeholder: 'placeholder',
        forcePlaceholderSize: true,
    });

    document.getElementById('simulationArea').addEventListener('mousedown', (e) => {
        simulationArea.touch = false;
        panStart(e);
    });
    document.getElementById('simulationArea').addEventListener('mouseup', () => {
        if (simulationArea.lastSelected) {
            simulationArea.lastSelected.newElement = false;
        }
        /*
        Handling restricted circuit elements
        */

        if (simulationArea.lastSelected && restrictedElements.includes(simulationArea.lastSelected.objectType) && !globalScope.restrictedCircuitElementsUsed.includes(simulationArea.lastSelected.objectType)) {
            globalScope.restrictedCircuitElementsUsed.push(simulationArea.lastSelected.objectType);
            updateRestrictedElementsList();
        }

        //       Deselect multible elements with click
        if (!simulationArea.shiftDown && simulationArea.multipleObjectSelections.length > 0
        ) {
            if (
                !simulationArea.multipleObjectSelections.includes(
                    simulationArea.lastSelected,
                )
            ) {
                simulationArea.multipleObjectSelections = [];
            }
        }
    });
    document.getElementById('simulationArea').addEventListener('mousemove', (e) => {
        simulationArea.touch = false;
        panMove(e);
    });
    document.getElementById('simulationArea').addEventListener('mouseup', (e) => {
        simulationArea.touch = false;
        panStop(e);
    });

    /** Implementating touch listerners
          *All Main basic touch listerners are
           present here
    */
    document.getElementById('simulationArea').addEventListener('touchstart', (e) => {
        simulationArea.touch = true;
        panStart(e);
    });
    document.getElementById('simulationArea').addEventListener('touchmove', (e) => {
        simulationArea.touch = true;
        panMove(e);
    });
    document.getElementById('simulationArea').addEventListener('touchend', (e) => {
        simulationArea.touch = true;
        panStop(e);
    });
    window.addEventListener('keyup', (e) => {
        scheduleUpdate(1);
        simulationArea.shiftDown = e.shiftKey;
        if (e.keyCode == 16) {
            simulationArea.shiftDown = false;
        }

        if (e.key == 'Meta' || e.key == 'Control') {
            simulationArea.controlDown = false;
        }
    });

    window.addEventListener('keydown', (e) => {
        if (document.activeElement.tagName == 'INPUT') {
            return;
        }

        if (document.activeElement != document.body) {
            return;
        }

        simulationArea.shiftDown = e.shiftKey;
        if (e.key == 'Meta' || e.key == 'Control') {
            simulationArea.controlDown = true;
        }

        if (simulationArea.controlDown && e.key.charCodeAt(0) == 122) { // Detect the special CTRL-Z code
            undo();
        }

        if (listenToSimulator) {
            // If mouse is focusing on input element, then override any action
            // if($(':focus').length){
            //     return;
            // }

            if (document.activeElement.tagName == 'INPUT' || simulationArea.mouseRawX < 0 || simulationArea.mouseRawY < 0 || simulationArea.mouseRawX > width || simulationArea.mouseRawY > height) {
                return;
            }

            // HACK TO REMOVE FOCUS ON PROPERTIES
            if (document.activeElement.type == 'number') {
                hideProperties();
                showProperties(simulationArea.lastSelected);
            }

            errorDetectedSet(false);
            updateSimulationSet(true);
            updatePositionSet(true);
            simulationArea.shiftDown = e.shiftKey;

            if (e.key == 'Meta' || e.key == 'Control') {
                simulationArea.controlDown = true;
            }

            // Zoom in (+)
            if ((simulationArea.controlDown && (e.keyCode == 187 || e.keyCode == 171)) || e.keyCode == 107) {
                e.preventDefault();
                // eslint-disable-next-line no-use-before-define
                ZoomIn();
            }

            // Zoom out (-)
            if ((simulationArea.controlDown && (e.keyCode == 189 || e.keyCode == 173)) || e.keyCode == 109) {
                e.preventDefault();
                // eslint-disable-next-line no-use-before-define
                ZoomOut();
            }

            if (simulationArea.mouseRawX < 0 || simulationArea.mouseRawY < 0 || simulationArea.mouseRawX > width || simulationArea.mouseRawY > height) {
                return;
            }

            scheduleUpdate(1);
            updateCanvasSet(true);
            wireToBeCheckedSet(1);

            // Needs to be deprecated, moved to more recent listeners
            if (simulationArea.controlDown && (e.key == 'C' || e.key == 'c')) {
                //    SimulationArea.copyList=simulationArea.multipleObjectSelections.slice();
                //    if(simulationArea.lastSelected&&simulationArea.lastSelected!==simulationArea.root&&!simulationArea.copyList.contains(simulationArea.lastSelected)){
                //        simulationArea.copyList.push(simulationArea.lastSelected);
                //    }
                //    copy(simulationArea.copyList);
            }

            if (simulationArea.lastSelected && simulationArea.lastSelected.keyDown) {
                if (e.key.toString().length == 1 || e.key.toString() == 'Backspace' || e.key.toString() == 'Enter') {
                    simulationArea.lastSelected.keyDown(e.key.toString());
                    e.cancelBubble = true;
                    e.returnValue = false;

                    // E.stopPropagation works in Firefox.
                    if (e.stopPropagation) {
                        e.stopPropagation();
                        e.preventDefault();
                    }

                    return;
                }
            }

            if (simulationArea.lastSelected && simulationArea.lastSelected.keyDown2) {
                if (e.key.toString().length == 1) {
                    simulationArea.lastSelected.keyDown2(e.key.toString());
                    return;
                }
            }

            if (simulationArea.lastSelected && simulationArea.lastSelected.keyDown3) {
                if (e.key.toString() != 'Backspace' && e.key.toString() != 'Delete') {
                    simulationArea.lastSelected.keyDown3(e.key.toString());
                    return;
                }
            }

            if (e.keyCode == 16) {
                simulationArea.shiftDown = true;
                if (simulationArea.lastSelected && !simulationArea.lastSelected.keyDown && simulationArea.lastSelected.objectType != 'Wire' && simulationArea.lastSelected.objectType != 'CircuitElement' && !simulationArea.multipleObjectSelections.contains(simulationArea.lastSelected)) {
                    simulationArea.multipleObjectSelections.push(simulationArea.lastSelected);
                }
            }

            // Detect offline save shortcut (CTRL+SHIFT+S)
            if (simulationArea.controlDown && e.keyCode == 83 && simulationArea.shiftDown) {
                saveOffline();
                e.preventDefault();
            }

            // Detect Select all Shortcut
            if (simulationArea.controlDown && (e.keyCode == 65 || e.keyCode == 97)) {
                selectAll();
                e.preventDefault();
            }

            // Deselect all Shortcut
            if (e.keyCode == 27) {
                simulationArea.multipleObjectSelections = [];
                simulationArea.lastSelected = undefined;
                e.preventDefault();
            }

            if ((e.keyCode == 113 || e.keyCode == 81) && simulationArea.lastSelected != undefined) {
                if (simulationArea.lastSelected.bitWidth !== undefined) {
                    simulationArea.lastSelected.newBitWidth(parseInt(prompt('Enter new bitWidth'), 10));
                }
            }

            if (simulationArea.controlDown && (e.key == 'T' || e.key == 't')) {
                // E.preventDefault(); //browsers normally open a new tab
                simulationArea.changeClockTime(prompt('Enter Time:'));
            }
        }

        if (e.keyCode == 8 || e.key == 'Delete') {
            deleteSelected();
        }
    }, true);

    document.getElementById('simulationArea').addEventListener('dblclick', (e) => {
        onDoubleClickorTap(e);
    });

    function MouseScroll(event) {
        updateCanvasSet(true);
        event.preventDefault();
        // eslint-disable-next-line vars-on-top
        // eslint-disable-next-line no-var
        var deltaY = event.wheelDelta ? event.wheelDelta : -event.detail;
        event.preventDefault();
        // eslint-disable-next-line no-redeclare
        var deltaY = event.wheelDelta ? event.wheelDelta : -event.detail;
        const direction = deltaY > 0 ? 1 : -1;
        // eslint-disable-next-line no-use-before-define
        handleZoom(direction);
        updateCanvasSet(true);
        gridUpdateSet(true);

        if (layoutModeGet()) {
            layoutUpdate();
        } else {
            update();
        } // Schedule update not working, this is INEFFICIENT
    }
    document.getElementById('simulationArea').addEventListener('mousewheel', MouseScroll);
    document.getElementById('simulationArea').addEventListener('DOMMouseScroll', MouseScroll);

    document.addEventListener('cut', (e) => {
        if (verilogModeGet()) {
            return;
        }

        if (document.activeElement.tagName == 'INPUT') {
            return;
        }

        if (document.activeElement.tagName != 'BODY') {
            return;
        }

        if (listenToSimulator) {
            simulationArea.copyList = simulationArea.multipleObjectSelections.slice();
            if (simulationArea.lastSelected && simulationArea.lastSelected !== simulationArea.root && !simulationArea.copyList.contains(simulationArea.lastSelected)) {
                simulationArea.copyList.push(simulationArea.lastSelected);
            }

            const textToPutOnClipboard = copy(simulationArea.copyList, true);

            // Updated restricted elements
            updateRestrictedElementsInScope();
            localStorage.setItem('clipboardData', textToPutOnClipboard);
            e.preventDefault();
            if (textToPutOnClipboard == undefined) {
                return;
            }

            if (isIe) {
                window.clipboardData.setData('Text', textToPutOnClipboard);
            } else {
                e.clipboardData.setData('text/plain', textToPutOnClipboard);
            }
        }
    });

    document.addEventListener('copy', (e) => {
        if (verilogModeGet()) {
            return;
        }

        if (document.activeElement.tagName == 'INPUT') {
            return;
        }

        if (document.activeElement.tagName != 'BODY') {
            return;
        }

        if (listenToSimulator) {
            simulationArea.copyList = simulationArea.multipleObjectSelections.slice();
            if (simulationArea.lastSelected && simulationArea.lastSelected !== simulationArea.root && !simulationArea.copyList.contains(simulationArea.lastSelected)) {
                simulationArea.copyList.push(simulationArea.lastSelected);
            }

            const textToPutOnClipboard = copy(simulationArea.copyList);

            // Updated restricted elements
            updateRestrictedElementsInScope();
            localStorage.setItem('clipboardData', textToPutOnClipboard);
            e.preventDefault();
            if (textToPutOnClipboard == undefined) {
                return;
            }

            if (isIe) {
                window.clipboardData.setData('Text', textToPutOnClipboard);
            } else {
                e.clipboardData.setData('text/plain', textToPutOnClipboard);
            }
        }
    });

    document.addEventListener('paste', (e) => {
        if (document.activeElement.tagName == 'INPUT') {
            return;
        }

        if (document.activeElement.tagName != 'BODY') {
            return;
        }

        if (listenToSimulator) {
            let data;
            if (isIe) {
                data = window.clipboardData.getData('Text');
            } else {
                data = e.clipboardData.getData('text/plain');
            }

            paste(data);

            // Updated restricted elements
            updateRestrictedElementsInScope();

            e.preventDefault();
        }
    });

    // 'drag and drop' event listener for subcircuit elements in layout mode
    $('#subcircuitMenu').on('dragstop', '.draggableSubcircuitElement', function (event, ui) {
        const sideBarWidth = $('#guide_1')[0].clientWidth;
        let tempElement;

        if (ui.position.top > 10 && ui.position.left > sideBarWidth) {
            // Make a shallow copy of the element with the new coordinates
            tempElement = globalScope[this.dataset.elementName][this.dataset.elementId];
            // Changing the coordinate doesn't work yet, nodes get far from element
            tempElement.x = ui.position.left - sideBarWidth;
            tempElement.y = ui.position.top;
            // eslint-disable-next-line no-restricted-syntax
            for (const node of tempElement.nodeList) {
                node.x = ui.position.left - sideBarWidth;
                node.y = ui.position.top;
            }

            tempBuffer.subElements.push(tempElement);
            this.parentElement.removeChild(this);
        }
    });

    restrictedElements.forEach((element) => {
        $(`#${element}`).mouseover(() => {
            showRestricted();
        });

        $(`#${element}`).mouseout(() => {
            hideRestricted();
        });
    });

    $('.search-input').on('keyup', function () {
        const parentElement = $(this).parent().parent();
        const closeButton = $('.search-close', parentElement);
        const searchInput = $('.search-input', parentElement);
        const searchResults = $('.search-results', parentElement);
        const menu = $('.accordion', parentElement);

        searchResults.css('display', 'block');
        closeButton.css('display', 'block');
        menu.css('display', 'none');
        const value = $(this).val().toLowerCase();

        closeButton.on('click', () => {
            searchInput.val('');
            menu.css('display', 'block');
            searchResults.css('display', 'none');
            closeButton.css('display', 'none');
        });
        if (value.length === 0) {
            menu.css('display', 'block');
            searchResults.css('display', 'none');
            closeButton.css('display', 'none');
            return;
        }

        let htmlIcons = '';
        const result = elementPanelList.filter((ele) => ele.toLowerCase().includes(value));
        if (!result.length) {
            searchResults.text('No elements found ...');
        } else {
            result.forEach((e) => {
                // eslint-disable-next-line no-use-before-define
                htmlIcons += createIcon(e);
            });
            searchResults
                .html(htmlIcons);
            $('.filterElements').mousedown(createElement);
        }
    });
    function createIcon(element) {
        return `<div class="${element} icon logixModules filterElements" id="${element}" title="${element}">
            <img  src= "/img/${element}.svg" >
        </div>`;
    }

    // eslint-disable-next-line no-use-before-define
    zoomSliderListeners();
    setupLayoutModePanelListeners();
    if (!embed) {
        setupTimingListeners();
    }

    /**
 * Listerners of CircuitElement panel ,properties panel,time diagram, quichbtn
 */
    const modulePropertyListners = document.getElementById('moduleProperty');
    const moduleQueryslector = document.querySelector('#moduleProperty');
    const circuitElementListner = document.getElementById('guide_1');
    const CircuitElementQuerySelector = document.querySelector('#guide_1');
    const QuickPanelListner = document.getElementById('quick-btn-id');
    const QuickPanelQuerySelector = document.querySelector('#quick-btn-id');
    const timingDiagramListner = document.getElementById('time-Diagram');
    const timingDiagramQuerySelector = document.querySelector('#time-Diagram');

    moduleQueryslector.addEventListener('touchstart', (e) => {
        dragStart(e, modulePropertyListners);
    });
    moduleQueryslector.addEventListener('touchmove', (e) => {
        dragMove(e, modulePropertyListners);
    });
    moduleQueryslector.addEventListener('touchend', () => {
        dragEnd();
    });

    CircuitElementQuerySelector.addEventListener('touchstart', (e) => {
        dragStart(e, circuitElementListner);
    });
    CircuitElementQuerySelector.addEventListener('touchmove', (e) => {
        dragMove(e, circuitElementListner);
    });
    CircuitElementQuerySelector.addEventListener('touchend', () => {
        dragEnd();
    });
    QuickPanelQuerySelector.addEventListener('touchstart', (e) => {
        dragStart(e, QuickPanelQuerySelector);
    });
    QuickPanelQuerySelector.addEventListener('touchmove', (e) => {
        dragMove(e, QuickPanelListner);
    });
    QuickPanelQuerySelector.addEventListener('touchend', () => {
        dragEnd();
    });
    timingDiagramQuerySelector.addEventListener('touchstart', (e) => {
        $('.timing-diagram-panel').draggable().draggable('enable');
        timingDiagramListner.style.position = 'absolute';
        dragStart(e, timingDiagramListner);
    });
    timingDiagramQuerySelector.addEventListener('touchmove', (e) => {
        dragMove(e, timingDiagramListner);
    });
    timingDiagramQuerySelector.addEventListener('touchend', () => {
        dragEnd();
    });
}

function resizeTabs() {
    const $windowsize = $('body').width();
    const $sideBarsize = $('.side').width();
    const $maxwidth = ($windowsize - $sideBarsize);
    $('#tabsBar div').each(function () {
        $(this).css({ 'max-width': $maxwidth - 30 });
    });
}

window.addEventListener('resize', resizeTabs);
resizeTabs();
$(() => {
    $('[data-toggle="tooltip"]').tooltip();
});
// Direction is only 1 or -1
function handleZoom(direction) {
    if (globalScope.scale > 0.5 * DPR) {
        changeScale(direction * 0.1 * DPR);
    } else if (globalScope.scale < 4 * DPR) {
        changeScale(direction * 0.1 * DPR);
    }

    gridUpdateSet(true);
    scheduleUpdate();
}

export function ZoomIn() {
    handleZoom(1);
}

export function ZoomOut() {
    handleZoom(-1);
}

function zoomSliderListeners() {
    document.getElementById('customRange1').value = 5;
    // eslint-disable-next-line no-use-before-define
    document.getElementById('simulationArea').addEventListener('DOMMouseScroll', zoomSliderScroll);
    // eslint-disable-next-line no-use-before-define
    document.getElementById('simulationArea').addEventListener('mousewheel', zoomSliderScroll);
    let curLevel = document.getElementById('customRange1').value;
    $(document).on('input change', '#customRange1', function () {
        const newValue = $(this).val();
        const changeInScale = newValue - curLevel;
        updateCanvasSet(true);
        changeScale(changeInScale * 0.1, 'zoomButton', 'zoomButton', 3);
        gridUpdateSet(true);
        curLevel = newValue;
    });
    function zoomSliderScroll(e) {
        let zoomLevel = document.getElementById('customRange1').value;
        const deltaY = e.wheelDelta ? e.wheelDelta : -e.detail;
        const directionY = deltaY > 0 ? 1 : -1;
        if (directionY > 0) {
            zoomLevel++;
        } else {
            zoomLevel--;
        }

        if (zoomLevel >= 45) {
            zoomLevel = 45;
            document.getElementById('customRange1').value = 45;
        } else if (zoomLevel <= 0) {
            zoomLevel = 0;
            document.getElementById('customRange1').value = 0;
        } else {
            document.getElementById('customRange1').value = zoomLevel;
            curLevel = zoomLevel;
        }
    }

    function sliderZoomButton(direction) {
        const zoomSlider = $('#customRange1');
        let currentSliderValue = parseInt(zoomSlider.val(), 10);
        if (direction === -1) {
            currentSliderValue--;
        } else {
            currentSliderValue++;
        }

        zoomSlider.val(currentSliderValue).change();
    }

    $('#decrement').click(() => {
        sliderZoomButton(-1);
    });
    $('#increment').click(() => {
        sliderZoomButton(1);
    });
}
