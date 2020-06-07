import { resetScopeList, newCircuit, switchCircuit } from '../circuit';
import { setProjectName } from './save';
import {
    scheduleUpdate, update, updateSimulationSet, updateCanvasSet, gridUpdateSet,
} from '../engine';
import { updateRestrictedElementsInScope } from '../restrictedElementDiv';
import simulationArea from '../simulationArea';

import { loadSubCircuit } from '../subcircuit';
import { scheduleBackup } from './backupCircuit';
import { showProperties } from '../ux';
import { constructNodeConnections, loadNode, replace } from '../node';
import { generateId } from '../utils';
import modules from '../modules';
import { oppositeDirection } from '../canvasApi';

/**
 * Backward compatibility - needs to be deprecated
 * @param {CircuitElement} obj - the object to be rectified
 * @category data
 */
function rectifyObjectType(obj) {
    const rectify = {
        FlipFlop: 'DflipFlop',
        Ram: 'Rom',
    };
    return rectify[obj] || obj;
}

/**
 * Function to load CircuitElements
 * @param {JSON} data - JSOn data
 * @param {Scope} scope - circuit in which we want to load modules
 * @category data
 */
function loadModule(data, scope) {
    // Create circuit element
    const obj = new modules[rectifyObjectType(data.objectType)](data.x, data.y, scope, ...data.customData.constructorParamaters || []);
    // Sets directions
    obj.label = data.label;
    obj.labelDirection = data.labelDirection || oppositeDirection[fixDirection[obj.direction]];

    // Sets delay
    obj.propagationDelay = data.propagationDelay || obj.propagationDelay;
    obj.fixDirection();

    // Restore other values
    if (data.customData.values) {
        for (const prop in data.customData.values) {
            obj[prop] = data.customData.values[prop];
        }
    }

    // Replace new nodes with the correct old nodes (with connections)
    if (data.customData.nodes) {
        for (const node in data.customData.nodes) {
            const n = data.customData.nodes[node];
            if (n instanceof Array) {
                for (let i = 0; i < n.length; i++) {
                    obj[node][i] = replace(obj[node][i], n[i]);
                }
            } else {
                obj[node] = replace(obj[node], n);
            }
        }
    }
}

/**
 * This function shouldn't ideally exist. But temporary fix
 * for some issues while loading nodes.
 * @category data
 */
function removeBugNodes(scope = globalScope) {
    let x = scope.allNodes.length;
    for (let i = 0; i < x; i++) {
        if (scope.allNodes[i].type !== 2 && scope.allNodes[i].parent.objectType === 'CircuitElement') { scope.allNodes[i].delete(); }
        if (scope.allNodes.length !== x) {
            i = 0;
            x = scope.allNodes.length;
        }
    }
}

/**
 * Function to load a full circuit
 * @param {Scope} scope
 * @param {JSON} data
 * @category data
 */
export function loadScope(scope, data) {
    const ML = moduleList.slice(); // Module List copy
    scope.restrictedCircuitElementsUsed = data.restrictedCircuitElementsUsed;

    // Load all nodes
    data.allNodes.map((x) => loadNode(x, scope));

    // Make all connections
    for (let i = 0; i < data.allNodes.length; i++) { constructNodeConnections(scope.allNodes[i], data.allNodes[i]); }
    // Load all modules
    for (let i = 0; i < ML.length; i++) {
        if (data[ML[i]]) {
            if (ML[i] === 'SubCircuit') {
                // Load subcircuits differently
                for (let j = 0; j < data[ML[i]].length; j++) { loadSubCircuit(data[ML[i]][j], scope); }
            } else {
                // Load everything else similarly
                for (let j = 0; j < data[ML[i]].length; j++) {
                    loadModule(data[ML[i]][j], scope);
                }
            }
        }
    }
    // Update wires according
    scope.wires.map((x) => {
        x.updateData(scope);
    });
    removeBugNodes(scope); // To be deprecated
    // If layout exists, then restore
    if (data.layout) {
        scope.layout = data.layout;
    } else {
        // Else generate new layout according to how it would have been otherwise (backward compatibility)
        scope.layout = {};
        scope.layout.width = 100;
        scope.layout.height = Math.max(scope.Input.length, scope.Output.length) * 20 + 20;
        scope.layout.title_x = 50;
        scope.layout.title_y = 13;
        for (let i = 0; i < scope.Input.length; i++) {
            scope.Input[i].layoutProperties = {
                x: 0,
                y: scope.layout.height / 2 - scope.Input.length * 10 + 20 * i + 10,
                id: generateId(),
            };
        }
        for (let i = 0; i < scope.Output.length; i++) {
            scope.Output[i].layoutProperties = {
                x: scope.layout.width,
                y: scope.layout.height / 2 - scope.Output.length * 10 + 20 * i + 10,
                id: generateId(),
            };
        }
    }
    // Backward compatibility
    if (scope.layout.titleEnabled === undefined) { scope.layout.titleEnabled = true; }
}


// Function to load project from data
/**
 * loads a saved project
 * @param {JSON} data - the json data of the
 * @category data
 * @exports load
 */
export default function load(data) {
    // If project is new and no data is there, then just set project name
    if (!data) {
        setProjectName(projectName);
        return;
    }

    const { projectId } = data;
    let projectName = data.name;

    if (data.name === 'Untitled') { projectName = undefined; } else { setProjectName(data.name); }

    globalScope = undefined;
    resetScopeList(); // Remove default scope
    $('.circuits').remove(); // Delete default scope

    // Load all circuits according to the dependency order
    for (let i = 0; i < data.scopes.length; i++) {
        // Create new circuit
        const scope = newCircuit(data.scopes[i].name || 'Untitled', data.scopes[i].id);

        // Load circuit data
        loadScope(scope, data.scopes[i]);

        // Focus circuit
        globalScope = scope;

        // Center circuit
        if (embed) { globalScope.centerFocus(true); } else { globalScope.centerFocus(false); }

        // update and backup circuit once
        update(globalScope, true);

        // Updating restricted element list initially on loading
        updateRestrictedElementsInScope();

        scheduleBackup();
    }

    // Restore clock
    simulationArea.changeClockTime(data.timePeriod || 500);
    simulationArea.clockEnabled = data.clockEnabled === undefined ? true : data.clockEnabled;


    if (!embed) { showProperties(simulationArea.lastSelected); }

    // Switch to last focussedCircuit
    if (data.focussedCircuit) switchCircuit(data.focussedCircuit);


    updateSimulationSet(true);
    updateCanvasSet(true);
    gridUpdateSet(true);
    scheduleUpdate();
}
