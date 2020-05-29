/* eslint-disable no-use-before-define */
/* eslint-disable no-continue */
/* eslint-disable no-param-reassign */
/* eslint-disable no-bitwise */
/**
 * Core of the simulation and rendering algorithm.
 * @module engine
 */

import plotArea from './plotArea';
import { layoutUpdate } from './layoutMode';
import simulationArea from './simulationArea';
import {
    dots, canvasMessage, findDimensions, rect2,
} from './canvasApi';
import { showProperties } from './ux';
import { showError } from './utils';
import miniMapArea from './minimap';

/**
 * Function to render Canvas according th renderupdate order
 * @param {Scope} scope - The circuit whose canvas we want to render
 */
export function renderCanvas(scope) {
    if (layoutMode) { // Different Algorithm
        return;
    }
    var ctx = simulationArea.context;
    // Reset canvas
    simulationArea.clear();
    // Update Grid
    if (gridUpdate) {
        gridUpdate = false;
        dots();
    }
    canvasMessageData = undefined; //  Globally set in draw fn ()
    // Render objects
    for (let i = 0; i < renderOrder.length; i++) {
        for (var j = 0; j < scope[renderOrder[i]].length; j++) { scope[renderOrder[i]][j].draw(); }
    }
    // Show any message
    if (canvasMessageData) {
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
 */
export function updateSelectionsAndPane(scope = globalScope) {
    if (!simulationArea.selected && simulationArea.mouseDown) {
        simulationArea.selected = true;
        simulationArea.lastSelected = scope.root;
        simulationArea.hover = scope.root;
        // Selecting multiple objects
        if (simulationArea.shiftDown) {
            objectSelection = true;
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
            gridUpdate = true;
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
            objectSelection = false;
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
 */
function play(scope = globalScope, resetNodes = false) {
    if (errorDetected) return; // Don't simulate until error is fixed
    if (loading === true) return; // Don't simulate until loaded
    if (!embed) plotArea.stopWatch.Stop(); // Waveform thing
    // Reset Nodes if required
    if (resetNodes || forceResetNodes) {
        scope.reset();
        simulationArea.simulationQueue.reset();
        forceResetNodes = false;
    }
    // Temporarily kept for for future uses
    // else{
    //     // clearBuses(scope);
    //     for(var i=0;i<scope.TriState.length;i++) {
    //         // console.log("HIT2",i);
    //         scope.TriState[i].removePropagation();
    //     }
    // }
    // Add subcircuits if they can be resolved -- needs to be removed/ deprecated
    for (let i = 0; i < scope.SubCircuit.length; i++) {
        if (scope.SubCircuit[i].isResolvable()) simulationArea.simulationQueue.add(scope.SubCircuit[i]);
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
            errorDetected = true;
            forceResetNodes = true;
        }
    }
    // Check for TriState Contentions
    if (simulationArea.contentionPending.length) {
        console.log(simulationArea.contentionPending);
        showError('Contention at TriState');
        forceResetNodes = true;
        errorDetected = true;
    }
    // Setting Flag Values
    for (let i = 0; i < scope.Flag.length; i++) { scope.Flag[i].setPlotValue(); }
}

/**
 * Function to check for any UI update, it is throttled by time
 * @param {number=} count - this is used to force update
 * @param {number=} time - the time throttling parameter
 * @param {functio} fn - function to run before updating UI
 */
export function scheduleUpdate(count = 0, time = 100, fn) {
    if (lightMode) time *= 5;
    if (count && !layoutMode) { // Force update
        update();
        for (let i = 0; i < count; i++) { setTimeout(update, 10 + 50 * i); }
    }
    if (willBeUpdated) return; // Throttling
    willBeUpdated = true;
    if (layoutMode) {
        setTimeout(layoutUpdate, time); // Update layout, different algorithm
        return;
    }
    // Call a function before update ..
    if (fn) {
        setTimeout(() => {
            fn();
            update();
        }, time);
    } else setTimeout(update, time);
}

/**
 * fn that calls update on everything else. If any change
 * is there, it resolves the circuit and draws it again.
 * Also updates simulations, selection, minimap, resolves
 * circuit and redraws canvas if required.
 * @param {Scope=} scope - the circuit to be updated
 * @param {boolean=} updateEverything - if true we update the wires, nodes and modules
 */
export function update(scope = globalScope, updateEverything = false) {
    willBeUpdated = false;
    if (loading === true || layoutMode) return;
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
        updateSubcircuit = false;
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
    if (!embed && prevPropertyObj !== simulationArea.lastSelected) {
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
    updateSimulation = false;
    updateCanvas = false;
    updatePosition = false;
}
