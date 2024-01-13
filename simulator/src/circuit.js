/* eslint-disable import/no-cycle */
/* eslint-disable no-bitwise */
/* eslint-disable guard-for-in */
/* eslint-disable no-restricted-syntax */
/* eslint-disable no-restricted-globals */
/* eslint-disable consistent-return */
/* eslint-disable func-names */
/* eslint-disable array-callback-return */
/* eslint-disable no-use-before-define */
/* eslint-disable no-param-reassign */
/* eslint-disable no-alert */
import CircuitElement from './circuitElement';
import plotArea from './plotArea';
import simulationArea, { changeClockTime } from './simulationArea';
import {
    stripTags,
    uniq,
    showMessage,
    showError,
    truncateString,
    escapeHtml,
} from './utils';
import { findDimensions, dots } from './canvasApi';
import { updateRestrictedElementsList } from './restrictedElementDiv';
import { scheduleBackup } from './data/backupCircuit';
import { showProperties } from './ux';
import {
    scheduleUpdate, updateSimulationSet,
    updateCanvasSet, updateSubcircuitSet,
    forceResetNodesSet, changeLightMode,
} from './engine';
import { toggleLayoutMode, layoutModeGet } from './layoutMode';
import { setProjectName, getProjectName } from './data/save';
import { changeClockEnable } from './sequential';
import { changeInputSize } from './modules';
import { verilogModeGet, verilogModeSet } from './Verilog2CV';
import { updateTestbenchUI } from './testbench';
import load from './data/load';

export const circuitProperty = {
    toggleLayoutMode, setProjectName, changeCircuitName, changeClockTime, deleteCurrentCircuit, changeClockEnable, changeInputSize, changeLightMode,
};
export var scopeList = {};
export function resetScopeList() {
    scopeList = {};
}
/**
 * Function used to change the current focusedCircuit
 * Disables layoutMode if enabled
 * Changes UI tab etc
 * Sets flags to make updates, resets most of the things
 * @param {string} id - identifier for circuit
 * @category circuit
 */
export function switchCircuit(id) {
    if (layoutModeGet()) { toggleLayoutMode(); }
    if (verilogModeGet()) { verilogModeSet(false);}

    // globalScope.fixLayout();
    scheduleBackup();
    if (id === globalScope.id) return;
    $('.circuits').removeClass('current');
    simulationArea.lastSelected = undefined;
    simulationArea.multipleObjectSelections = [];
    simulationArea.copyList = [];
    globalScope = scopeList[id];
    if (globalScope.verilogMetadata.isVerilogCircuit) {
        verilogModeSet(true);
    }
    if (globalScope.isVisible()) {
        $(`#${id}`).addClass('current');
    }
    updateSimulationSet(true);
    updateSubcircuitSet(true);
    forceResetNodesSet(true);
    dots(false);
    simulationArea.lastSelected = globalScope.root;
    if (!embed) {
        showProperties(simulationArea.lastSelected);
        updateTestbenchUI();
        plotArea.reset();
    }
    updateCanvasSet(true);
    scheduleUpdate();

    // to update the restricted elements information
    updateRestrictedElementsList();
}

/**
 * Deletes the current circuit
 * Ensures that at least one circuit is there
 * Ensures that no circuit depends on the current circuit
 * Switched to a random circuit
  * @category circuit
*/
function deleteCurrentCircuit(scopeId = globalScope.id) {
    const scope = scopeList[scopeId];
    if (Object.keys(scopeList).length <= 1) {
        showError('At least 2 circuits need to be there in order to delete a circuit.');
        return;
    }
    let dependencies = '';
    for (id in scopeList) {
        if (id != scope.id && scopeList[id].checkDependency(scope.id)) {
            if (dependencies === '') {
                dependencies = scopeList[id].name;
            } else {
                dependencies += `, ${scopeList[id].name}`;
            }
        }
    }
    if (dependencies) {
        dependencies = `\nThe following circuits are depending on '${scope.name}': ${dependencies}\nDelete subcircuits of ${scope.name} before trying to delete ${scope.name}`;
        alert(dependencies);
        return;
    }

    const confirmation = confirm(`Are you sure want to close: ${scope.name}\nThis cannot be undone.`);
    if (confirmation) {
        if (scope.verilogMetadata.isVerilogCircuit) {
            scope.initialize();
            for (var id in scope.verilogMetadata.subCircuitScopeIds)
                delete scopeList[id];
        }
        $(`#${scope.id}`).remove();
        delete scopeList[scope.id];
        switchCircuit(Object.keys(scopeList)[0]);
        showMessage('Circuit was successfully closed');
    } else { showMessage('Circuit was not closed'); }
}

/**
 * Wrapper function around newCircuit to be called from + button on UI
 */
export function createNewCircuitScope() {
    simulationArea.lastSelected = undefined;
    const scope = newCircuit();
    if (!embed) {
        showProperties(simulationArea.lastSelected);
        updateTestbenchUI();
        plotArea.reset();
    }
}

/**
 * Function to create new circuit
 * Function creates button in tab, creates scope and switches to this circuit
 * @param {string} name - name of the new circuit
 * @param {string} id - identifier for circuit
 * @category circuit
 */
export function newCircuit(name, id, isVerilog = false, isVerilogMain = false) {
    if (layoutModeGet()) { toggleLayoutMode(); }
    if (verilogModeGet()) { verilogModeSet(false); }
    name = name || prompt('Enter circuit name:', 'Untitled-Circuit');
    name = escapeHtml(stripTags(name));
    if (!name) return;
    const scope = new Scope(name);
    if (id) scope.id = id;
    scopeList[scope.id] = scope;
    if (isVerilog) {
        scope.verilogMetadata.isVerilogCircuit = true;
        scope.verilogMetadata.isMainCircuit = isVerilogMain;
    }
    globalScope = scope;
    $('.circuits').removeClass('current');
    if (!isVerilog || isVerilogMain) {
        if (embed) {
            var html = `<div style='' class='circuits toolbarButton current' draggable='true' id='${scope.id}'><span class='circuitName noSelect'>${truncateString(name, 18)}</span></div>`;
            $('#tabsBar').append(html);
            $("#tabsBar").addClass('embed-tabs');
        } else {
            var html = `<div style='' class='circuits toolbarButton current' draggable='true' id='${scope.id}'><span class='circuitName noSelect'>${truncateString(name, 18)}</span><span class ='tabsCloseButton' id='${scope.id}'  >x</span></div>`;
            $('#tabsBar').children().last().before(html);
        }

        // Remove listeners
        $('.circuits').off('click');
        $('.circuitName').off('click');
        $('.tabsCloseButton').off('click');

        // Add listeners
        $('.circuits').on('click',function () {
            switchCircuit(this.id);
        });

        $('.circuitName').on('click',(e) => {
            simulationArea.lastSelected = globalScope.root;
            setTimeout(() => {
                document.getElementById('circname').select();
            }, 100);
        });

        $('.tabsCloseButton').on('click',function (e) {
            e.stopPropagation();
            deleteCurrentCircuit(this.id);
        });
        if (!embed) {
            showProperties(scope.root);
        }
        dots(false);
    }

    return scope;
}

/**
 * Used to change name of a circuit
 * @param {string} name - new name
 * @param {string} id - id of the circuit
 * @category circuit
 */
export function changeCircuitName(name, id = globalScope.id) {
    name = name || 'Untitled';
    name = escapeHtml(stripTags(name));
    $(`#${id} .circuitName`).html(`${truncateString(name, 18)}`);
    scopeList[id].name = name;
}

/**
 * Class representing a Scope
 * @class
 * @param {string} name - name of the circuit
 * @param {number=} id - a random id for the circuit
 * @category circuit
 */
export default class Scope {
    constructor(name = 'localScope', id = undefined) {
        this.restrictedCircuitElementsUsed = [];
        this.id = id || Math.floor((Math.random() * 100000000000) + 1);
        this.CircuitElement = [];
        this.name = name;

        // root object for referring to main canvas - intermediate node uses this
        this.root = new CircuitElement(0, 0, this, 'RIGHT', 1);
        this.backups = [];
        // maintaining a state (history) for redo function
        this.history = [];
        this.timeStamp = new Date().getTime();
        this.verilogMetadata = {
            isVerilogCircuit: false,
            isMainCircuit: false,
            code: '// Write Some Verilog Code Here!',
            subCircuitScopeIds: [],
        };

        this.ox = 0;
        this.oy = 0;
        this.scale = DPR;
        this.stack = [];

        this.initialize();

        // Setting default layout
        this.layout = { // default position
            width: 100,
            height: 40,
            title_x: 50,
            title_y: 13,
            titleEnabled: true,
        };
    }

    isVisible() {
        if (!this.verilogMetadata.isVerilogCircuit) return true;
        return this.verilogMetadata.isMainCircuit;
    }

    initialize() {
        this.tunnelList = {};
        this.pending = [];
        this.nodes = []; // intermediate nodes only
        this.allNodes = [];
        this.wires = [];

        // Creating arrays for other module elements
        for (let i = 0; i < moduleList.length; i++) {
            this[moduleList[i]] = [];
        }
    }

    /**
     * Resets all nodes recursively
     */
    reset() {
        for (let i = 0; i < this.allNodes.length; i++) { this.allNodes[i].reset(); }
        for (let i = 0; i < this.Splitter.length; i++) {
            this.Splitter[i].reset();
        }
        for (let i = 0; i < this.SubCircuit.length; i++) {
            this.SubCircuit[i].reset();
        }
    }

    /**
     * Adds all inputs to simulationQueue
    */
    addInputs() {
        for (let i = 0; i < inputList.length; i++) {
            for (var j = 0; j < this[inputList[i]].length; j++) {
                simulationArea.simulationQueue.add(this[inputList[i]][j], 0);
            }
        }

        for (let i = 0; i < this.SubCircuit.length; i++) { this.SubCircuit[i].addInputs(); }
    }

    /**
     * Ticks clocks recursively -- needs to be deprecated and synchronize all clocks with a global clock
     */
    clockTick() {
        for (let i = 0; i < this.Clock.length; i++) { this.Clock[i].toggleState(); } // tick clock!
        for (let i = 0; i < this.SubCircuit.length; i++) { this.SubCircuit[i].localScope.clockTick(); } // tick clock!
    }

    /**
     * Checks if this circuit contains directly or indirectly scope with id
     * Recursive nature
     */
    checkDependency(id) {
        if (id === this.id) return true;
        for (let i = 0; i < this.SubCircuit.length; i++) { if (this.SubCircuit[i].id === id) return true; }

        for (let i = 0; i < this.SubCircuit.length; i++) { if (scopeList[this.SubCircuit[i].id].checkDependency(id)) return true; }

        return false;
    }

    /**
     * Get dependency list - list of all circuits, this circuit depends on
     */
    getDependencies() {
        var list = [];
        for (let i = 0; i < this.SubCircuit.length; i++) {
            list.push(this.SubCircuit[i].id);
            list.extend(scopeList[this.SubCircuit[i].id].getDependencies());
        }
        return uniq(list);
    }

    /**
     * helper function to reduce layout size
    */
    fixLayout() {
        var maxY = 20;
        for (let i = 0; i < this.Input.length; i++) { maxY = Math.max(this.Input[i].layoutProperties.y, maxY); }
        for (let i = 0; i < this.Output.length; i++) { maxY = Math.max(this.Output[i].layoutProperties.y, maxY); }
        if (maxY !== this.layout.height) { this.layout.height = maxY + 10; }
    }


    /**
     * Function which centers the circuit to the correct zoom level
     */
    centerFocus(zoomIn = true) {
        if (layoutModeGet()) return;
        findDimensions(this);

        var ytoolbarOffset = embed ? 0 : 60 * DPR; // Some part ofcanvas is hidden behind the toolbar

        var minX = simulationArea.minWidth || 0;
        var minY = simulationArea.minHeight || 0;
        var maxX = simulationArea.maxWidth || 0;
        var maxY = simulationArea.maxHeight || 0;

        var reqWidth = maxX - minX + 75 * DPR;
        var reqHeight = maxY - minY + 75 * DPR;

        this.scale = Math.min(width / reqWidth, (height - ytoolbarOffset) / reqHeight);

        if (!zoomIn) { this.scale = Math.min(this.scale, DPR); }
        this.scale = Math.max(this.scale, DPR / 10);

        this.ox = (-minX) * this.scale + (width - (maxX - minX) * this.scale) / 2;
        this.oy = (-minY) * this.scale + (height - ytoolbarOffset - (maxY - minY) * this.scale) / 2;
    }

    /**
     * Function to load a circuit using circuit data
     */
    loadCircuit(data) {
        if (data) {
            load(data);
        } else {
            alert('Invalid data');
        }
    }

    /**
     * Function to retrieve the previous stable state of the circuit
     */
    previous() {
        const autosaveData = localStorage.getItem('autosave');
        if (autosaveData) {
            const data = JSON.parse(autosaveData);
            load(data);
            localStorage.removeItem('autosave');
        }
    }

    /**
     * Function to detect the nodes that are creating cyclic paths in the circuit
     */
    detectCycle() {
        const obj = {};
        const result = [];

        for (let i = 0; i < globalScope.allNodes.length; i++) {
            const nodeId = globalScope.allNodes[i].id;
            for (let j = 0; j < globalScope.allNodes[i].connections.length; j++) {
                const connection = globalScope.allNodes[i].connections[j].id;
                if (obj[nodeId]) {
                    obj[nodeId].push(connection);
                } else {
                    obj[nodeId] = [connection];
                }
            }
        }

        const newNestedArray = [];
        const singleConnectionNodes = [];

        for (const node in obj) {
            const connections = obj[node];
            if (connections.length === 1) {
                singleConnectionNodes.push(node);
            }
            if (!isVisited(newNestedArray.flat(), node)) {
                const connectedNodes = [node];
                exploreNodes(obj, node, newNestedArray.flat(), connectedNodes);
                newNestedArray.push(connectedNodes);
            }
        }

        for (let i = 0; i < singleConnectionNodes.length - 1; i++) {
            for (let j = i + 1; j < singleConnectionNodes.length; j++) {
                if (areElementsInSameNode(newNestedArray, singleConnectionNodes[i], singleConnectionNodes[j])) {
                    const val1 = this.findNodeIndexById(singleConnectionNodes[i]);
                    const val2 = this.findNodeIndexById(singleConnectionNodes[j]);
                    if (globalScope.allNodes[val1].parent === globalScope.allNodes[val2].parent) {
                        result.push(dfs(obj, singleConnectionNodes[i], singleConnectionNodes[j]));
                    }
                }
            }
        }

        // Function to check whether a node is already visited
        function isVisited(visited, node) {
            return visited.includes(node);
        }

        // Function to explore interconnected nodes
        function exploreNodes(graph, startNode, visited, connectedNodes) {
            visited.push(startNode);
            if (graph[startNode]) {
                for (let i = 0; i < graph[startNode].length; i++) {
                    const connectedNode = graph[startNode][i];
                    if (!isVisited(visited, connectedNode)) {
                        connectedNodes.push(connectedNode);
                        exploreNodes(graph, connectedNode, visited, connectedNodes);
                    }
                }
            }
        }

        function areElementsInSameNode(nestedArray, element1, element2) {
            for (const node of nestedArray) {
                if (node.includes(element1) && node.includes(element2)) {
                    return true;
                }
            }
            return false;
        }

        // Function to locate the nodes present between two specified nodes
        function dfs(graph, start, end, path = []) {
            if (start === end) {
                path.push(end);
                return path;
            }
            path.push(start);
            for (const neighbor of graph[start]) {
                if (!path.includes(neighbor)) {
                    const newPath = dfs(graph, neighbor, end, path);
                    if (newPath) {
                        return newPath;
                    }
                }
            }
            path.pop();
            return [];
        }

        if (result.length) {
            this.highlightNodes(result);
            return result;
        }

        return 'No cycle found';
    }

    /**
     * Function to highlight the nodes in the currently selected circuit
     * @param {Array<Array>} array - id's of the nodes, that we want to highlight
     */
    highlightNodes(array) {
        const Nodes = [];
        array.forEach((innerArray) => {
            const resultArray = innerArray.map(value => this.findNodeIndexById(value));
            Nodes.push(resultArray);
        });

        Nodes.forEach((subArray) => {
            subArray.forEach((node) => {
                globalScope.allNodes[node].highlighted = true;
            });
        });
    }

    /**
     * Function to find the index of a node in globalScope.allNodes
     * @param {string} nodeId - id of a node
     */
    findNodeIndexById(nodeId) {
        for (let i = 0; i < globalScope.allNodes.length; i++) {
            if (globalScope.allNodes[i].id === nodeId) {
                return i;
            }
        }
        return 'Not found';
    }

    /**
     * Function to find the currently selected component on the canvas
     */
    getCurrentlySelectedComponent() {
        return simulationArea.lastSelected;
    }

    /**
     * Function to find the currently selected components (when multiple components are selected) on the canvas
     */
    getAllSelectedComponents() {
        return simulationArea.multipleObjectSelections;
    }

    /**
     * Function to modify the currently selected component's object in the globalScope
     * takes the property which needs to modify
     * and the modified value as parameters
     */
    modifyCurrentlySelectedComponent(property, value) {
        const selectedComponent = globalScope.getCurrentlySelectedComponent();

        if (selectedComponent.objectType === 'Node') {
            const nodeId = selectedComponent.id;
            const nodeIndex = this.findNodeIndexById(nodeId);
            globalScope.allNodes[nodeIndex][property] = value;
            return;
        }
        for (const key in globalScope) {
            const component = globalScope[key];
            if (Array.isArray(component) && component.length) {
                component.forEach((obj, index) => {
                    if (obj === selectedComponent) {
                        component[index][property] = value;
                    }
                });
            }
        }
    }
}
