/* eslint-disable import/no-cycle */
// Listeners when circuit is embedded
// Refer listeners.js
import simulationArea from './simulationArea';
import {
    scheduleUpdate, update, updateSelectionsAndPane,
    wireToBeCheckedSet, updatePositionSet, updateSimulationSet,
    updateCanvasSet, gridUpdateSet, errorDetectedSet,
} from './engine';
import { changeScale } from './canvasApi';
import { copy, paste } from './events';

const unit = 10;
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

    document.getElementById('simulationArea').addEventListener('mousedown', (e) => {
        errorDetectedSet(false);
        updateSimulationSet(true);
        updatePositionSet(true);
        updateCanvasSet(true);

        simulationArea.lastSelected = undefined;
        simulationArea.selected = false;
        simulationArea.hover = undefined;
        const rect = simulationArea.canvas.getBoundingClientRect();
        simulationArea.mouseDownRawX = (e.clientX - rect.left) * DPR;
        simulationArea.mouseDownRawY = (e.clientY - rect.top) * DPR;
        simulationArea.mouseDownX = Math.round(((simulationArea.mouseDownRawX - globalScope.ox) / globalScope.scale) / unit) * unit;
        simulationArea.mouseDownY = Math.round(((simulationArea.mouseDownRawY - globalScope.oy) / globalScope.scale) / unit) * unit;
        simulationArea.mouseDown = true;
        simulationArea.oldx = globalScope.ox;
        simulationArea.oldy = globalScope.oy;


        e.preventDefault();
        scheduleUpdate(1);
    });

    document.getElementById('simulationArea').addEventListener('mousemove', () => {
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
    });

    window.addEventListener('mousemove', (e) => {
        const rect = simulationArea.canvas.getBoundingClientRect();
        simulationArea.mouseRawX = (e.clientX - rect.left) * DPR;
        simulationArea.mouseRawY = (e.clientY - rect.top) * DPR;
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
    });
    window.addEventListener('keydown', (e) => {
        errorDetectedSet(false);
        updateSimulationSet(true);
        updatePositionSet(true);

        // zoom in (+)
        if (e.key == 'Meta' || e.key == 'Control') {
            simulationArea.controlDown = true;
        }

        if (simulationArea.controlDown && (e.keyCode == 187 || e.KeyCode == 171)) {
            e.preventDefault();
            if (globalScope.scale < 4 * DPR) { changeScale(0.1 * DPR); }
        }

        // zoom out (-)
        if (simulationArea.controlDown && (e.keyCode == 189 || e.Keycode == 173)) {
            e.preventDefault();
            if (globalScope.scale > 0.5 * DPR) { changeScale(-0.1 * DPR); }
        }


        if (simulationArea.mouseRawX < 0 || simulationArea.mouseRawY < 0 || simulationArea.mouseRawX > width || simulationArea.mouseRawY > height) return;

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

        // if (simulationArea.lastSelected && simulationArea.lastSelected.keyDown3) {
        //     if (e.key.toString() != "Backspace" && e.key.toString() != "Delete") {
        //         simulationArea.lastSelected.keyDown3(e.key.toString());
        //         return;
        //     }

        // }

        if (e.key == 'T' || e.key == 't') {
            simulationArea.changeClockTime(prompt('Enter Time:'));
        }
    });
    document.getElementById('simulationArea').addEventListener('dblclick', (e) => {
        scheduleUpdate(2);
        if (simulationArea.lastSelected && simulationArea.lastSelected.dblclick !== undefined) {
            simulationArea.lastSelected.dblclick();
        }
    });


    window.addEventListener('mouseup', (e) => {
        simulationArea.mouseDown = false;
        errorDetectedSet(false);
        updateSimulationSet(true);
        updatePositionSet(true);
        updateCanvasSet(true);
        gridUpdateSet(true);
        wireToBeCheckedSet(1);

        scheduleUpdate(1);
    });
    window.addEventListener('mousedown', function (e) {
        this.focus();
    });

    document.getElementById('simulationArea').addEventListener('mousewheel', MouseScroll);
    document.getElementById('simulationArea').addEventListener('DOMMouseScroll', MouseScroll);

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

    document.addEventListener('cut', (e) => {
        simulationArea.copyList = simulationArea.multipleObjectSelections.slice();
        if (simulationArea.lastSelected && simulationArea.lastSelected !== simulationArea.root && !simulationArea.copyList.contains(simulationArea.lastSelected)) {
            simulationArea.copyList.push(simulationArea.lastSelected);
        }

        const textToPutOnClipboard = cut(simulationArea.copyList);
        if (isIe) {
            window.clipboardData.setData('Text', textToPutOnClipboard);
        } else {
            e.clipboardData.setData('text/plain', textToPutOnClipboard);
        }
        e.preventDefault();
    });
    document.addEventListener('copy', (e) => {
        simulationArea.copyList = simulationArea.multipleObjectSelections.slice();
        if (simulationArea.lastSelected && simulationArea.lastSelected !== simulationArea.root && !simulationArea.copyList.contains(simulationArea.lastSelected)) {
            simulationArea.copyList.push(simulationArea.lastSelected);
        }

        const textToPutOnClipboard = copy(simulationArea.copyList);
        if (isIe) {
            window.clipboardData.setData('Text', textToPutOnClipboard);
        } else {
            e.clipboardData.setData('text/plain', textToPutOnClipboard);
        }
        e.preventDefault();
    });

    document.addEventListener('paste', (e) => {
        let data;
        if (isIe) {
            data = window.clipboardData.getData('Text');
        } else {
            data = e.clipboardData.getData('text/plain');
        }

        paste(data);
        e.preventDefault();
    });
}


let isIe = (navigator.userAgent.toLowerCase().indexOf('msie') != -1
    || navigator.userAgent.toLowerCase().indexOf('trident') != -1);
