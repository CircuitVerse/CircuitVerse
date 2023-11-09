/* eslint-disable no-alert */
/* eslint-disable eqeqeq */
/* eslint-disable no-plusplus */
/* eslint-disable func-names */
/* eslint-disable prefer-const */
/* eslint-disable no-undef */
/* eslint-disable max-len */
// Listeners when circuit is embedded
// Refer listeners.js
import simulationArea from './simulationArea';
import {
    scheduleUpdate, update, updateSelectionsAndPane, wireToBeCheckedSet, updatePositionSet, updateSimulationSet, updateCanvasSet, gridUpdateSet, errorDetectedSet,
} from './engine';
import { changeScale } from './canvasApi';
import {
    ZoomIn, ZoomOut, pinchZoom, getCoordinate,
} from './listeners';

const unit = 10;
let embedCoordinate;
/** *Function embedPanStart
    *This function hepls to initialize mouse and touch
    *For now variable name starts with mouse like mouseDown are used both
     touch and mouse will change in future
*/
function embedPanStart(e) {
    embedCoordinate = getCoordinate(e);
    errorDetectedSet(false);
    updateSimulationSet(true);
    updatePositionSet(true);
    updateCanvasSet(true);

    simulationArea.lastSelected = undefined;
    simulationArea.selected = false;
    simulationArea.hover = undefined;
    const rect = simulationArea.canvas.getBoundingClientRect();
    simulationArea.mouseDownRawX = (embedCoordinate.x - rect.left) * DPR;
    simulationArea.mouseDownRawY = (embedCoordinate.y - rect.top) * DPR;
    simulationArea.mouseDownX = Math.round(((simulationArea.mouseDownRawX - globalScope.ox) / globalScope.scale) / unit) * unit;
    simulationArea.mouseDownY = Math.round(((simulationArea.mouseDownRawY - globalScope.oy) / globalScope.scale) / unit) * unit;
    simulationArea.mouseDown = true;
    simulationArea.oldx = globalScope.ox;
    simulationArea.oldy = globalScope.oy;
    e.preventDefault();
    scheduleUpdate(1);
}

/** *Function embedPanMove
    *This function hepls to move simulator and its elements using touch and mouse
    *For now variable name starts with mouse like mouseDown are used both
     touch and mouse will change in future
*/
function embedPanMove(e) {
    embedCoordinate = getCoordinate(e);
    if (!simulationArea.touch || e.touches.length === 1) {
        const rect = simulationArea.canvas.getBoundingClientRect();
        simulationArea.mouseRawX = (embedCoordinate.x - rect.left) * DPR;
        simulationArea.mouseRawY = (embedCoordinate.y - rect.top) * DPR;
        simulationArea.mouseXf = (simulationArea.mouseRawX - globalScope.ox) / globalScope.scale;
        simulationArea.mouseYf = (simulationArea.mouseRawY - globalScope.oy) / globalScope.scale;
        simulationArea.mouseX = Math.round(simulationArea.mouseXf / unit) * unit;
        simulationArea.mouseY = Math.round(simulationArea.mouseYf / unit) * unit;
        updateCanvasSet(true);
        if (simulationArea.lastSelected == globalScope.root) {
            updateCanvasSet(true);
            let fn;
            fn = function () {
                updateSelectionsAndPane();
            };

            scheduleUpdate(0, 20, fn);
        } else {
            scheduleUpdate(0, 200);
        }
    }

    if (simulationArea.touch && e.touches.length === 2) {
        pinchZoom(e);
    }
}

/** *Function embedPanEnd
    *This function update simulator after mouse and touch end
    *For now variable name starts with mouse like mouseDown are used both
     touch and mouse will change in future
*/
function embedPanEnd() {
    simulationArea.mouseDown = false;
    errorDetectedSet(false);
    updateSimulationSet(true);
    updatePositionSet(true);
    updateCanvasSet(true);
    gridUpdateSet(true);
    wireToBeCheckedSet(1);

    scheduleUpdate(1);
}

/** *Function BlockElementPan
    *This function block the pan of elements since in embed simulator you can only view simulator NOT update
*/
function blockElementPan() {
    const ele = document.getElementById('elementName');
    if (globalScope && simulationArea && simulationArea.objectList) {
        let { objectList } = simulationArea;
        objectList = objectList.filter((val) => val !== 'wires');

        for (let i = 0; i < objectList.length; i++) {
            for (let j = 0; j < globalScope[objectList[i]].length; j++) {
                if (globalScope[objectList[i]][j].isHover()) {
                    ele.style.display = 'block';
                    if (objectList[i] === 'SubCircuit') {
                        ele.innerHTML = `Subcircuit: ${globalScope.SubCircuit[j].data.name}`;
                    } else {
                        ele.innerHTML = `CircuitElement: ${objectList[i]}`;
                    }

                    return;
                }
            }
        }
    }

    ele.style.display = 'none';
    document.getElementById('elementName').innerHTML = '';
}

export default function startListeners() {
    window.addEventListener('keyup', (e) => {
        scheduleUpdate(1);
        if (e.keyCode == 16) {
            simulationArea.shiftDown = false;
        }

        if (e.key == 'Meta' || e.key == 'Control') {
            simulationArea.controlDown = false;
        }
    });
    // All event listeners starts from here
    document.getElementById('simulationArea').addEventListener('mousedown', (e) => {
        simulationArea.touch = false;
        embedPanStart(e);
    });
    document.getElementById('simulationArea').addEventListener('mousemove', () => {
        simulationArea.touch = false;
        blockElementPan();
    });
    document.getElementById('simulationArea').addEventListener('touchstart', (e) => {
        simulationArea.touch = true;
        embedPanStart(e);
    });
    document.getElementById('simulationArea').addEventListener('touchmove', (e) => {
        simulationArea.touch = true;
        blockElementPan();
    });
    window.addEventListener('mousemove', (e) => {
        embedPanMove(e);
    });
    window.addEventListener('touchmove', (e) => {
        embedPanMove(e);
    });
    window.addEventListener('mouseup', () => {
        embedPanEnd();
    });
    window.addEventListener('mousedown', function () {
        this.focus();
    });

    window.addEventListener('touchend', () => {
        embedPanEnd();
    });
    window.addEventListener('touchstart', function () {
        this.focus();
    });
    function MouseScroll(event) {
        updateCanvasSet(true);

        event.preventDefault();
        const deltaY = event.wheelDelta ? event.wheelDelta : -event.detail;
        const scrolledUp = deltaY < 0;
        const scrolledDown = deltaY > 0;

        if (event.ctrlKey) {
            if (scrolledUp && globalScope.scale > 0.5 * DPR) {
                changeScale(-0.1 * DPR);
            }

            if (scrolledDown && globalScope.scale < 4 * DPR) {
                changeScale(0.1 * DPR);
            }
        } else {
            if (scrolledUp && globalScope.scale < 4 * DPR) {
                changeScale(0.1 * DPR);
            }

            if (scrolledDown && globalScope.scale > 0.5 * DPR) {
                changeScale(-0.1 * DPR);
            }
        }

        updateCanvasSet(true);
        gridUpdateSet(true);
        update(); // Schedule update not working, this is INEFFICENT
    }
    document.getElementById('simulationArea').addEventListener('mousewheel', MouseScroll);
    document.getElementById('simulationArea').addEventListener('DOMMouseScroll', MouseScroll);
    // eslint-disable-next-line complexity
    window.addEventListener('keydown', (e) => {
        errorDetectedSet(false);
        updateSimulationSet(true);
        updatePositionSet(true);

        // Zoom in (+)
        if (e.key == 'Meta' || e.key == 'Control') {
            simulationArea.controlDown = true;
        }

        if (simulationArea.controlDown && (e.keyCode == 187 || e.KeyCode == 171)) {
            e.preventDefault();
            ZoomIn();
        }

        // Zoom out (-)
        if (simulationArea.controlDown && (e.keyCode == 189 || e.Keycode == 173)) {
            e.preventDefault();
            ZoomOut();
        }

        if (simulationArea.mouseRawX < 0 || simulationArea.mouseRawY < 0 || simulationArea.mouseRawX > width || simulationArea.mouseRawY > height) {
            return;
        }

        scheduleUpdate(1);
        updateCanvasSet(true);

        if (simulationArea.lastSelected && simulationArea.lastSelected.keyDown) {
            if (e.key.toString().length == 1 || e.key.toString() == 'Backspace') {
                simulationArea.lastSelected.keyDown(e.key.toString());
                return;
            }
        }

        if (simulationArea.lastSelected && simulationArea.lastSelected.keyDown2) {
            if (e.key.toString().length == 1) {
                simulationArea.lastSelected.keyDown2(e.key.toString());
                return;
            }
        }

        // If (simulationArea.lastSelected && simulationArea.lastSelected.keyDown3) {
        //     if (e.key.toString() != "Backspace" && e.key.toString() != "Delete") {
        //         simulationArea.lastSelected.keyDown3(e.key.toString());
        //         return;
        //     }

        // }

        if (e.key == 'T' || e.key == 't') {
            simulationArea.changeClockTime(prompt('Enter Time:'));
        }
    });
    document.getElementById('simulationArea').addEventListener('dblclick', () => {
        scheduleUpdate(2);
        if (simulationArea.lastSelected && simulationArea.lastSelected.dblclick !== undefined) {
            simulationArea.lastSelected.dblclick();
        }
    });
}

// eslint-disable-next-line no-unused-vars
const isIe = (navigator.userAgent.toLowerCase().indexOf('msie') != -1
    || navigator.userAgent.toLowerCase().indexOf('trident') != -1);
