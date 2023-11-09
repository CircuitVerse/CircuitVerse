/* eslint-disable import/no-cycle */
import Scope, { scopeList, switchCircuit, newCircuit } from './circuit';

import { loadScope } from './data/load';
import {
    scheduleUpdate, updateSimulationSet, updateSubcircuitSet, forceResetNodesSet,
} from './engine';
import { backUp } from './data/backupCircuit';
import { getNextPosition } from './modules';
import { generateId } from './utils';
import simulationArea from './simulationArea';
import { TestbenchData } from './testbench';

/**
 * Helper function to paste
 * @param {JSON} copyData - the data to be pasted
 * @category events
 */
export function paste(copyData) {
    if (copyData === undefined) return;
    var data = JSON.parse(copyData);
    if (!data.logixClipBoardData) return;

    var currentScopeId = globalScope.id;
    for (let i = 0; i < data.scopes.length; i++) {
        if (scopeList[data.scopes[i].id] === undefined) {
            var isVerilogCircuit = false;
            var isMainCircuit = false;
            if(data.scopes[i].verilogMetadata) {
                isVerilogCircuit = data.scopes[i].verilogMetadata.isVerilogCircuit;
                isMainCircuit = data.scopes[i].verilogMetadata.isMainCircuit;
            }
            var scope = newCircuit(data.scopes[i].name, data.scopes[i].id, isVerilogCircuit, isMainCircuit);
            loadScope(scope, data.scopes[i]);
            scopeList[data.scopes[i].id] = scope;
        }
    }

    switchCircuit(currentScopeId);
    var tempScope = new Scope(globalScope.name, globalScope.id);
    var oldOx = globalScope.ox;
    var oldOy = globalScope.oy;
    var oldScale = globalScope.scale;
    loadScope(tempScope, data);

    var prevLength = tempScope.allNodes.length;
    for (let i = 0; i < tempScope.allNodes.length; i++) {
        tempScope.allNodes[i].checkDeleted();
        if (tempScope.allNodes.length != prevLength) {
            prevLength--;
            i--;
        }
    }

    var approxX = 0;
    var approxY = 0;
    var count = 0;

    for (let i = 0; i < updateOrder.length; i++) {
        for (let j = 0; j < tempScope[updateOrder[i]].length; j++) {
            const obj = tempScope[updateOrder[i]][j];
            obj.updateScope(globalScope);
            if (obj.objectType != 'Wire') {
                approxX += obj.x;
                approxY += obj.y;
                count++;
            }
        }
    }

    for (let j = 0; j < tempScope.CircuitElement.length; j++) {
        const obj = tempScope.CircuitElement[j];
        obj.updateScope(globalScope);
    }

    approxX /= count;
    approxY /= count;

    approxX = Math.round(approxX / 10) * 10;
    approxY = Math.round(approxY / 10) * 10;


    for (let i = 0; i < updateOrder.length; i++) {
        for (let j = 0; j < tempScope[updateOrder[i]].length; j++) {
            const obj = tempScope[updateOrder[i]][j];
            if (obj.objectType !== 'Wire') {
                obj.x += simulationArea.mouseX - approxX;
                obj.y += simulationArea.mouseY - approxY;
            }
        }
    }

    Object.keys(tempScope).forEach((l) => {
        if (tempScope[l] instanceof Array && l !== 'objects' && l !== 'CircuitElement') {
            globalScope[l].extend(tempScope[l]);
        }
    });
    for (let i = 0; i < tempScope.Input.length; i++) {
        tempScope.Input[i].layoutProperties.y = getNextPosition(0, globalScope);
        tempScope.Input[i].layoutProperties.id = generateId();
    }
    for (let i = 0; i < tempScope.Output.length; i++) {
        tempScope.Output[i].layoutProperties.x = globalScope.layout.width;
        tempScope.Output[i].layoutProperties.id = generateId();
        tempScope.Output[i].layoutProperties.y = getNextPosition(globalScope.layout.width, globalScope);
    }
    var canvasUpdate = true;
    updateSimulationSet(true);
    updateSubcircuitSet(true);
    scheduleUpdate();
    globalScope.ox = oldOx;
    globalScope.oy = oldOy;
    globalScope.scale = oldScale;


    forceResetNodesSet(true);
}
/**
 * Helper function for cut
 * @param {JSON} copyList - The selected elements
 * @category events
 */
export function cut(copyList) {
    if (copyList.length === 0) return;
    var tempScope = new Scope(globalScope.name, globalScope.id);
    var oldOx = globalScope.ox;
    var oldOy = globalScope.oy;
    var oldScale = globalScope.scale;
    d = backUp(globalScope);
    loadScope(tempScope, d);
    scopeList[tempScope.id] = tempScope;

    for (let i = 0; i < copyList.length; i++) {
        const obj = copyList[i];
        if (obj.objectType === 'Node') obj.objectType = 'allNodes';
        for (let j = 0; j < tempScope[obj.objectType].length; j++) {
            if (tempScope[obj.objectType][j].x === obj.x && tempScope[obj.objectType][j].y === obj.y && (obj.objectType != 'Node' || obj.type === 2)) {
                tempScope[obj.objectType][j].delete();
                break;
            }
        }
    }
    tempScope.backups = globalScope.backups;
    for (let i = 0; i < updateOrder.length; i++) {
        let prevLength = globalScope[updateOrder[i]].length; // LOL length of list will reduce automatically when deletion starts
        for (let j = 0; j < globalScope[updateOrder[i]].length; j++) {
            const obj = globalScope[updateOrder[i]][j];
            if (obj.objectType != 'Wire') { // }&&obj.objectType!='CircuitElement'){//}&&(obj.objectType!='Node'||obj.type==2)){
                if (!copyList.contains(globalScope[updateOrder[i]][j])) {
                    globalScope[updateOrder[i]][j].cleanDelete();
                }
            }

            if (globalScope[updateOrder[i]].length != prevLength) {
                prevLength--;
                j--;
            }
        }
    }

    var prevLength = globalScope.wires.length;
    for (let i = 0; i < globalScope.wires.length; i++) {
        globalScope.wires[i].checkConnections();
        if (globalScope.wires.length != prevLength) {
            prevLength--;
            i--;
        }
    }

    updateSimulationSet(true);

    var data = backUp(globalScope);
    data.logixClipBoardData = true;
    var dependencyList = globalScope.getDependencies();
    data.dependencies = {};
    Object.keys(dependencyList).forEach((dependency) => {
        data.dependencies[dependency] = backUp(scopeList[dependency]);
    });
    data.logixClipBoardData = true;
    data = JSON.stringify(data);

    simulationArea.multipleObjectSelections = []; // copyList.slice();
    simulationArea.copyList = []; // copyList.slice();
    var canvasUpdate = true;
    updateSimulationSet(true);
    globalScope = tempScope;
    scheduleUpdate();
    globalScope.ox = oldOx;
    globalScope.oy = oldOy;
    globalScope.scale = oldScale;
    forceResetNodesSet(true);
    // eslint-disable-next-line consistent-return
    return data;
}
/**
 * Helper function for copy
 * @param {JSON} copyList - The data to copied
 * @param {boolean} cutflag - flase if we want to copy
 * @category events
 */
export function copy(copyList, cutflag = false) {
    if (copyList.length === 0) return;
    var tempScope = new Scope(globalScope.name, globalScope.id);
    var oldOx = globalScope.ox;
    var oldOy = globalScope.oy;
    var oldScale = globalScope.scale;
    var d = backUp(globalScope);
    const oldTestbenchData = globalScope.testbenchData;

    loadScope(tempScope, d);
    scopeList[tempScope.id] = tempScope;

    if (cutflag) {
        for (let i = 0; i < copyList.length; i++) {
            const obj = copyList[i];
            if (obj.objectType === 'Node') obj.objectType = 'allNodes';
            for (let j = 0; j < tempScope[obj.objectType].length; j++) {
                if (tempScope[obj.objectType][j].x === obj.x && tempScope[obj.objectType][j].y === obj.y && (obj.objectType != 'Node' || obj.type === 2)) {
                    tempScope[obj.objectType][j].delete();
                    break;
                }
            }
        }
    }
    tempScope.backups = globalScope.backups;
    for (let i = 0; i < updateOrder.length; i++) {
        let prevLength = globalScope[updateOrder[i]].length; // LOL length of list will reduce automatically when deletion starts
        for (let j = 0; j < globalScope[updateOrder[i]].length; j++) {
            const obj = globalScope[updateOrder[i]][j];
            if (obj.objectType != 'Wire') { // }&&obj.objectType!='CircuitElement'){//}&&(obj.objectType!='Node'||obj.type==2)){
                if (!copyList.contains(globalScope[updateOrder[i]][j])) {
                    globalScope[updateOrder[i]][j].cleanDelete();
                }
            }

            if (globalScope[updateOrder[i]].length != prevLength) {
                prevLength--;
                j--;
            }
        }
    }

    var prevLength = globalScope.wires.length;
    for (let i = 0; i < globalScope.wires.length; i++) {
        globalScope.wires[i].checkConnections();
        if (globalScope.wires.length != prevLength) {
            prevLength--;
            i--;
        }
    }

    updateSimulationSet(true);

    var data = backUp(globalScope);
    data.scopes = [];
    var dependencyList = {};
    var requiredDependencies = globalScope.getDependencies();
    var completed = {};
    Object.keys(scopeList).forEach((id) => {
        dependencyList[id] = scopeList[id].getDependencies();
    });
    function saveScope(id) {
        if (completed[id]) return;
        for (let i = 0; i < dependencyList[id].length; i++) { saveScope(dependencyList[id][i]); }
        completed[id] = true;
        data.scopes.push(backUp(scopeList[id]));
    }
    for (let i = 0; i < requiredDependencies.length; i++) { saveScope(requiredDependencies[i]); }
    data.logixClipBoardData = true;
    data.testbenchData = undefined // Don't copy testbench data
    data = JSON.stringify(data);
    simulationArea.multipleObjectSelections = []; // copyList.slice();
    simulationArea.copyList = []; // copyList.slice();
    var canvasUpdate = true;
    updateSimulationSet(true);
    globalScope = tempScope;
    scheduleUpdate();
    globalScope.ox = oldOx;
    globalScope.oy = oldOy;
    globalScope.scale = oldScale;
    // Restore testbench data
    if (oldTestbenchData) {
        globalScope.testbenchData = new TestbenchData(
            oldTestbenchData.testData,
            oldTestbenchData.currentGroup,
            oldTestbenchData.currentCase
        );
    }

    forceResetNodesSet(true);
    // needs to be fixed
    // eslint-disable-next-line consistent-return
    return data;
}

/**
 * Function selects all the elements from the scope
 * @category events
 */
export function selectAll(scope = globalScope) {
    moduleList.forEach((val, _, __) => {
        if (scope.hasOwnProperty(val)) {
            simulationArea.multipleObjectSelections.push(...scope[val]);
        }
    });

    if (scope.nodes) {
        simulationArea.multipleObjectSelections.push(...scope.nodes);
    }
}
