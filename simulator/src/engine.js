/* eslint-disable import/no-cycle */
/* eslint-disable no-use-before-define */
/* eslint-disable no-continue */
/* eslint-disable no-param-reassign */
/* eslint-disable no-bitwise */
import { layoutModeGet, layoutUpdate } from './layoutMode';
import plotArea from './plotArea';
import simulationArea from './simulationArea';
import {
    dots, canvasMessage, findDimensions, rect2,
} from './canvasApi';
import { showProperties, prevPropertyObjGet } from './ux';
import { showError } from './utils';
import miniMapArea from './minimap';
import { resetup } from './setup';
import { verilogModeGet } from './Verilog2CV';

/**
 * Core of the simulation and rendering algorithm.
 */

/**
 * @type {number} engine
 * @category engine
 */
var wireToBeChecked = 0;

/**
 * Used to set wireChecked boolean which updates wires in UI if true (or 1). 2 if some problem and it is handled.
 * @param {number} param - value of wirechecked
 * @category engine
 */
export function wireToBeCheckedSet(param) {
    wireToBeChecked = param;
}

/**
 * scheduleUpdate() will be called if true
 * @type {boolean}
 * @category engine
 */
var willBeUpdated = false;

/**
 * used to set willBeUpdated variable
 * @type {boolean}
 * @category engine
 * @category engine
 */
export function willBeUpdatedSet(param) {
    willBeUpdated = param;
}

/**
 * true if we have an element selected and 
 * is used when we are paning the grid.
 * @type {boolean}
 * @category engine
 */
var objectSelection = false;

/**
 * used to set the value of object selection,
 * @param {boolean} param 
 * @category engine
 */
export function objectSelectionSet(param) {
    objectSelection = param;
}

/**
 * Flag for updating position
 * @type {boolean}
 * @category engine
 */
var updatePosition = true;

/**
 * used to set the value of updatePosition.
 * @param {boolean} param 
 * @category engine
 */
export function updatePositionSet(param) {
    updatePosition = param;
}

/**
 * Flag for updating simulation
 * @type {boolean}
 * @category engine
 */
var updateSimulation = true;

/**
 * used to set the value of updateSimulation.
 * @param {boolean} param
 * @category engine
 */
export function updateSimulationSet(param) {
    updateSimulation = param;
}
/**
 * Flag for rendering
 * @type {boolean}
 * @category engine
 */
var updateCanvas = true;

/**
 * used to set the value of updateCanvas.
 * @param {boolean} param
 * @category engine
 */
export function updateCanvasSet(param) {
    updateCanvas = param;
}

/**
 *  Flag for updating grid
 * @type {boolean}
 * @category engine
 */
var gridUpdate = true;

/**
 * used to set gridUpdate
 * @param {boolean} param
 * @category engine
 */
export function gridUpdateSet(param) {
    gridUpdate = param;
}

/**
 * used to get gridUpdate
 * @return {boolean}
 * @category engine
 */
export function gridUpdateGet() {
    return gridUpdate;
}
/**
 *  Flag for updating grid
 * @type {boolean}
 * @category engine
 */
var forceResetNodes = true;

/**
 * used to set forceResetNodes
 * @param {boolean} param
 * @category engine
 */
export function forceResetNodesSet(param) {
    forceResetNodes = param;
}
/**
 *  Flag for updating grid
 * @type {boolean}
 * @category engine
 */
var errorDetected = false;

/**
 * used to set errorDetected
 * @param {boolean} param
 * @category engine
 */
export function errorDetectedSet(param) {
    errorDetected = param;
}

/**
 * used to set errorDetected
 * @returns {boolean} errorDetected
 * @category engine
 */
export function errorDetectedGet() {
    return errorDetected;
}

/**
 * details of where and what canvas message has to be shown.
 * @type {Object}
 * @property {number} x - x cordinate of message
 * @property {number} y - x cordinate of message
 * @property {number} string - the message
 * @category engine
*/
export var canvasMessageData = {
    x: undefined,
    y: undefined,
    string: undefined,
};

/**
 *  Flag for updating subCircuits
 * @type {boolean}
 * @category engine
 */
var updateSubcircuit = true;

/**
 * used to set updateSubcircuit
 * @param {boolean} param
 * @category engine
 */
export function updateSubcircuitSet(param) {
    if (updateSubcircuit != param) {
        updateSubcircuit = param;
        return true;
    }
    updateSubcircuit = param;
    return false;
}

/**
 * turn light mode on
 * @param {boolean} val -- new value for light mode
 * @category engine
 */
export function changeLightMode(val) {
    if (!val && lightMode) {
        lightMode = false;
        DPR = window.devicePixelRatio || 1;
        globalScope.scale *= DPR;
    } else if (val && !lightMode) {
        lightMode = true;
        globalScope.scale /= DPR;
        DPR = 1
        $('#miniMap').fadeOut('fast');
    }
    resetup();
}

/**
 * Function to render Canvas according th renderupdate order
 * @param {Scope} scope - The circuit whose canvas we want to render
 * @category engine
 */
export function renderCanvas(scope) {
    if (layoutModeGet() || verilogModeGet()) { // Different Algorithm
        return;
    }
    var ctx = simulationArea.context;
    // Reset canvas
    simulationArea.clear();
    // Update Grid
    if (gridUpdate) {
        gridUpdateSet(false);
        dots();
    }
    canvasMessageData = {
        x: undefined,
        y: undefined,
        string: undefined,
    }; //  Globally set in draw fn ()
    // Render objects
    for (let i = 0; i < renderOrder.length; i++) {
        for (var j = 0; j < scope[renderOrder[i]].length; j++) { scope[renderOrder[i]][j].draw(); }
    }
    // Show any message
    if (canvasMessageData.string !== undefined) {
        canvasMessage(ctx, canvasMessageData.string, canvasMessageData.x, canvasMessageData.y);
    }
    // If multiple object selections are going on, show selected area
    if (objectSelection) {
        ctx.beginPath();
        ctx.lineWidth = 2;
        ctx.strokeStyle = 'black';
        ctx.fillStyle = 'rgba(0,0,0,0.1)';
        rect2(ctx, simulationArea.mouseDownX, simulationArea.mouseDownY, simulationArea.mouseX - simulationArea.mouseDownX, simulationArea.mouseY - simulationArea.mouseDownY, 0, 0, 'RIGHT');
        ctx.stroke();
        ctx.fill();
    }
    if (simulationArea.hover !== undefined) {
        simulationArea.canvas.style.cursor = 'pointer';
    } else if (simulationArea.mouseDown) {
        simulationArea.canvas.style.cursor = 'grabbing';
    } else {
        simulationArea.canvas.style.cursor = 'default';
    }
}

/**
 * Function to move multiple objects and panes window
 * deselected using dblclick right now (PR open for esc key)
 * @param {Scope=} scope - the circuit in which we are selecting stuff
 * @category engine
 */
export function updateSelectionsAndPane(scope = globalScope) {
    if (!simulationArea.selected && simulationArea.mouseDown) {
        simulationArea.selected = true;
        simulationArea.lastSelected = scope.root;
        simulationArea.hover = scope.root;
        // Selecting multiple objects
        if (simulationArea.shiftDown) {
            objectSelectionSet(true);
        } else if (!embed) {
            findDimensions(scope);
            miniMapArea.setup();
            $('#miniMap').show();
        }
    } else if (simulationArea.lastSelected === scope.root && simulationArea.mouseDown) {
        // pane canvas to give an idea of grid moving
        if (!objectSelection) {
            globalScope.ox = (simulationArea.mouseRawX - simulationArea.mouseDownRawX) + simulationArea.oldx;
            globalScope.oy = (simulationArea.mouseRawY - simulationArea.mouseDownRawY) + simulationArea.oldy;
            globalScope.ox = Math.round(globalScope.ox);
            globalScope.oy = Math.round(globalScope.oy);
            gridUpdateSet(true);
            if (!embed && !lightMode) miniMapArea.setup();
        } else {
            // idea: kind of empty
        }
    } else if (simulationArea.lastSelected === scope.root) {
        /*
        Select multiple objects by adding them to the array
        simulationArea.multipleObjectSelections when we select
        using shift + mouse movement to select an area but
        not shift + click
        */
        simulationArea.lastSelected = undefined;
        simulationArea.selected = false;
        simulationArea.hover = undefined;
        if (objectSelection) {
            objectSelectionSet(false);
            var x1 = simulationArea.mouseDownX;
            var x2 = simulationArea.mouseX;
            var y1 = simulationArea.mouseDownY;
            var y2 = simulationArea.mouseY;
            // Sort those four points to make a selection pane
            if (x1 > x2) {
                const temp = x1;
                x1 = x2;
                x2 = temp;
            }
            if (y1 > y2) {
                const temp = y1;
                y1 = y2;
                y2 = temp;
            }
            // Select the objects, push them into a list
            for (let i = 0; i < updateOrder.length; i++) {
                for (var j = 0; j < scope[updateOrder[i]].length; j++) {
                    var obj = scope[updateOrder[i]][j];
                    if (simulationArea.multipleObjectSelections.contains(obj)) continue;
                    var x; var
                        y;
                    if (obj.objectType === 'Node') {
                        x = obj.absX();
                        y = obj.absY();
                    } else if (obj.objectType !== 'Wire') {
                        x = obj.x;
                        y = obj.y;
                    } else {
                        continue;
                    }
                    if (x > x1 && x < x2 && y > y1 && y < y2) {
                        simulationArea.multipleObjectSelections.push(obj);
                    }
                }
            }
        }
    }
}

/**
 * Main fn that resolves circuit using event driven simulation
 * All inputs are added to a scope using scope.addinput() and
 * the simulation starts to play.
 * @param {Scope=} scope - the circuit we want to simulate
 * @param {boolean} resetNodes - boolean to reset all nodes
 * @category engine
 */
export function play(scope = globalScope, resetNodes = false) {
    if (errorDetected) return; // Don't simulate until error is fixed
    if (loading === true) return; // Don't simulate until loaded

    simulationArea.simulationQueue.reset();
    plotArea.setExecutionTime(); // Waveform thing
    // Reset Nodes if required
    if (resetNodes || forceResetNodes) {
        scope.reset();
        simulationArea.simulationQueue.reset();
        forceResetNodesSet(false);
    }

    // To store list of circuitselements that have shown contention but kept temporarily
    // Mainly to resolve tristate bus issues
    simulationArea.contentionPending = [];
    // add inputs to the simulation queue
    scope.addInputs();
    // to check if we have infinite loop in circuit
    let stepCount = 0;
    let elem;
    while (!simulationArea.simulationQueue.isEmpty()) {
        if (errorDetected) {
            simulationArea.simulationQueue.reset();
            return;
        }
        elem = simulationArea.simulationQueue.pop();
        elem.resolve();
        stepCount++;
        if (stepCount > 1000000) { // Cyclic or infinite Circuit Detection
            showError('Simulation Stack limit exceeded: maybe due to cyclic paths or contention');
            errorDetectedSet(true);
            forceResetNodesSet(true);
        }
    }
    // Check for TriState Contentions
    if (simulationArea.contentionPending.length) {
        showError('Contention at TriState');
        forceResetNodesSet(true);
        errorDetectedSet(true);
    }
}

/**
 * Function to check for any UI update, it is throttled by time
 * @param {number=} count - this is used to force update
 * @param {number=} time - the time throttling parameter
 * @param {function} fn - function to run before updating UI
 * @category engine
 */
export function scheduleUpdate(count = 0, time = 100, fn) {
    if (lightMode) time *= 5;
    var updateFn = layoutModeGet() ? layoutUpdate : update;
    if (count) { // Force update
        updateFn();
        for (let i = 0; i < count; i++) { setTimeout(updateFn, 10 + 50 * i); }
    }
    if (willBeUpdated) return; // Throttling
    willBeUpdatedSet(true);
    // Call a function before update ..
    if (fn) {
        setTimeout(() => {
            fn();
            updateFn();
        }, time);
    } else setTimeout(updateFn, time);
}

/**
 * fn that calls update on everything else. If any change
 * is there, it resolves the circuit and draws it again.
 * Also updates simulations, selection, minimap, resolves
 * circuit and redraws canvas if required.
 * @param {Scope=} scope - the circuit to be updated
 * @param {boolean=} updateEverything - if true we update the wires, nodes and modules
 * @category engine
 */
export function update(scope = globalScope, updateEverything = false) {
    willBeUpdatedSet(false);
    if (loading === true || layoutModeGet()) return;
    var updated = false;
    simulationArea.hover = undefined;
    // Update wires
    if (wireToBeChecked || updateEverything) {
        if (wireToBeChecked === 2) wireToBeChecked = 0; // this required due to timing issues
        else wireToBeChecked++;
        // WHY IS THIS REQUIRED ???? we are checking inside wire ALSO
        // Idea: we can just call length again instead of doing it during loop.
        var prevLength = scope.wires.length;
        for (let i = 0; i < scope.wires.length; i++) {
            scope.wires[i].checkConnections();
            if (scope.wires.length !== prevLength) {
                prevLength--;
                i--;
            }
        }
        scheduleUpdate();
    }
    // Update subcircuits
    if (updateSubcircuit || updateEverything) {
        for (let i = 0; i < scope.SubCircuit.length; i++) { scope.SubCircuit[i].reset(); }
        updateSubcircuitSet(false);
    }
    // Update UI position
    if (updatePosition || updateEverything) {
        for (let i = 0; i < updateOrder.length; i++) {
            for (let j = 0; j < scope[updateOrder[i]].length; j++) {
                updated |= scope[updateOrder[i]][j].update();
            }
        }
    }
    // Updates multiple objectselections and panes window
    if (updatePosition || updateEverything) {
        updateSelectionsAndPane(scope);
    }
    // Update MiniMap
    if (!embed && simulationArea.mouseDown && simulationArea.lastSelected && simulationArea.lastSelected !== globalScope.root) {
        if (!lightMode) { $('#miniMap').fadeOut('fast'); }
    }
    // Run simulation
    if (updateSimulation) {
        play();
    }
    // Show properties of selected element
    if (!embed && prevPropertyObjGet() !== simulationArea.lastSelected) {
        if (simulationArea.lastSelected && simulationArea.lastSelected.objectType !== 'Wire') {
            // ideas: why show properties of project in Nodes but not wires?
            showProperties(simulationArea.lastSelected);
        } else {
            // hideProperties();
        }
    }
    // Draw, render everything
    if (updateCanvas) {
        renderCanvas(scope);
    }
    updateSimulationSet(false);
    updateCanvas = false;
    updatePositionSet(false);
}
