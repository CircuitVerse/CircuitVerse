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
import CircuitElement from './circuitElement'
import plotArea from './plotArea'
import { simulationArea } from './simulationArea'
import {
    stripTags,
    uniq,
} from './utils'
import { findDimensions, dots } from './canvasApi'
import { updateRestrictedElementsList } from './restrictedElementDiv'
import { scheduleBackup } from './data/backupCircuit'
import { showProperties } from './ux'
import {
    scheduleUpdate,
    updateSimulationSet,
    updateCanvasSet,
    updateSubcircuitSet,
    forceResetNodesSet,
    changeLightMode,
} from './engine'
import { toggleLayoutMode, layoutModeGet } from './layoutMode'
import { setProjectName } from './data/save'
import { changeClockEnable } from './sequential'
import { changeInputSize } from './modules'
import { verilogModeGet, verilogModeSet } from './Verilog2CV'
import { SimulatorStore } from '#/store/SimulatorStore/SimulatorStore'
import { toRefs } from 'vue'
import { provideCircuitName } from '#/components/helpers/promptComponent/PromptComponent.vue'
import { deleteCurrentCircuit } from '#/components/helpers/deleteCircuit/DeleteCircuit.vue'
import { useSimulatorMobileStore } from '#/store/simulatorMobileStore'
import { inputList, moduleList } from './metadata'

export const circuitProperty = {
    toggleLayoutMode,
    setProjectName,
    changeCircuitName,
    deleteCurrentCircuit,
    changeClockEnable,
    changeInputSize,
    changeLightMode,
}

export let scopeList: { [key: string]: Scope } = {}
export function resetScopeList() {
    const simulatorStore = SimulatorStore()
    const { circuit_list } = toRefs(simulatorStore)
    scopeList = {}
    circuit_list.value = []
}
/**
 * Function used to change the current focusedCircuit
 * Disables layoutMode if enabled
 * Changes UI tab etc
 * Sets flags to make updates, resets most of the things
 */
export function switchCircuit(id: string) {
    // TODO: fix tomorrow
    const simulatorStore = SimulatorStore()
    const { circuit_list } = toRefs(simulatorStore)
    const { activeCircuit } = toRefs(simulatorStore)
    const simulatorMobileStore = toRefs(useSimulatorMobileStore())

    if (layoutModeGet()) {
        toggleLayoutMode()
    }
    if (!scopeList[id].verilogMetadata.isVerilogCircuit) {
        verilogModeSet(false)
        simulatorMobileStore.isVerilog.value = false
    }

    // globalScope.fixLayout();
    scheduleBackup()
    if (id === globalScope.id) return
    // $(`.circuits`).removeClass('current')
    circuit_list.value.forEach((circuit) =>
        circuit.focussed ? (circuit.focussed = false) : null
    )
    simulationArea.lastSelected = undefined
    simulationArea.multipleObjectSelections = []
    simulationArea.copyList = []
    globalScope = scopeList[id]
    if (globalScope.verilogMetadata.isVerilogCircuit) {
        verilogModeSet(true)
        simulatorMobileStore.isVerilog.value = true
    }
    if (globalScope.isVisible()) {
        // $(`#${id}`).addClass('current')
        const index = circuit_list.value.findIndex(
            (circuit) => circuit.id == id
        ) // TODO: add strict equality after typescript
        circuit_list.value[index].focussed = true
        if (activeCircuit.value) {
            activeCircuit.value.id = globalScope.id
            activeCircuit.value.name = globalScope.name
        }
    }
    updateSimulationSet(true)
    updateSubcircuitSet(true)
    forceResetNodesSet(true)
    dots(false)
    simulationArea.lastSelected = globalScope.root
    if (!embed) {
        showProperties(simulationArea.lastSelected)
        plotArea.reset()
    }
    updateCanvasSet(true)
    scheduleUpdate()

    // to update the restricted elements information
    updateRestrictedElementsList()
}

export function getDependenciesList(scopeId: string | number) {
    let scope = scopeList[scopeId]
    if (scope == undefined) scope = scopeList[globalScope.id]

    let dependencies = ''
    for (let id in scopeList) {
        let formattedId;
        if (typeof scopeId === 'number')
            formattedId = scopeId;
        else
            formattedId = parseInt(scopeId);
        if (id != scope.id && scopeList[id].checkDependency(formattedId)) {
            if (dependencies === '') {
                dependencies = scopeList[id].name
            } else {
                dependencies += `, ${scopeList[id].name}`
            }
        }
    }
    return dependencies
}

// /**
//  * Deletes the current circuit
//  * Ensures that at least one circuit is there
//  * Ensures that no circuit depends on the current circuit
//  * Switched to a random circuit
//  * @category circuit
//  */
// export function deleteCurrentCircuit(scopeId = globalScope.id) {
//     const simulatorStore = SimulatorStore()
//     const { circuit_list } = toRefs(simulatorStore)
//     let scope = scopeList[scopeId]
//     if (scope == undefined) scope = scopeList[globalScope.id]

//     if (scope.verilogMetadata.isVerilogCircuit) {
//         scope.initialize()
//         for (var id in scope.verilogMetadata.subCircuitScopeIds)
//             delete scopeList[id]
//     }
//     // $(`#${scope.id}`).remove()
//     const index = circuit_list.value.findIndex(
//         (circuit) => circuit.id === scope.id
//     )
//     circuit_list.value.splice(index, 1)
//     delete scopeList[scope.id]
//     if (scope.id == globalScope.id) {
//         switchCircuit(Object.keys(scopeList)[0])
//     }
//     showMessage('Circuit was successfully closed')
// }
/**
 * Wrapper function around newCircuit to be called from + button on UI
 */
export async function createNewCircuitScope(
    name: string | Error | undefined = undefined,
    id: string | undefined = undefined,
    isVerilog = false,
    isVerilogMain = false
) {
    name = name ?? (await provideCircuitName())
    if (name instanceof Error) return // if user cancels the prompt
    if (name.trim() == '') {
        name = 'Untitled-Circuit'
    }
    simulationArea.lastSelected = undefined
    newCircuit(name, id, isVerilog, isVerilogMain)
    if (!embed) {
        showProperties(simulationArea.lastSelected)
        plotArea.reset()
    }
    return true
}

export function circuitNameClicked() {
    simulationArea.lastSelected = globalScope.root
}

/**
 * Function to create new circuit
 * Function creates button in tab, creates scope and switches to this circuit
 */
export function newCircuit(name: string | undefined, id: string | undefined, isVerilog = false, isVerilogMain = false) {
    const simulatorStore = SimulatorStore()
    const { circuit_list } = toRefs(simulatorStore)
    const { activeCircuit } = toRefs(simulatorStore)
    const { circuit_name_clickable } = toRefs(simulatorStore)
    const simulatorMobileStore = toRefs(useSimulatorMobileStore())
    if (layoutModeGet()) {
        toggleLayoutMode()
    }
    if (verilogModeGet()) {
        verilogModeSet(false)
        simulatorMobileStore.isVerilog.value = false
    }
    name = name || 'Untitled-Circuit'
    name = stripTags(name)
    if (!name) return
    const scope = new Scope(name)
    if (id) scope.id = id
    scopeList[scope.id] = scope
    let currCircuit = {
        id: scope.id,
        name: scope.name, // fix for tab name issue - vue - to be reviewed @devartstar
    }

    circuit_list.value.push(currCircuit)
    if (isVerilog) {
        scope.verilogMetadata.isVerilogCircuit = true
        // TODO: remove later if not required after fixing verilog code loading from saved file
        circuit_list.value.forEach((circuit) => (circuit.isVerilog = false))
        circuit_list.value[circuit_list.value.length - 1].isVerilog = true
        scope.verilogMetadata.isMainCircuit = isVerilogMain
    }
    globalScope = scope
    // $('.circuits').removeClass('current')
    circuit_list.value.forEach((circuit) => (circuit.focussed = false))
    circuit_list.value[circuit_list.value.length - 1].focussed = true
    if (activeCircuit.value) {
        activeCircuit.value.id = scope.id
        activeCircuit.value.name = scope.name
    }

    if (!isVerilog || isVerilogMain) {
        circuit_name_clickable.value = false;
        // Remove listeners
        // $('.circuitName').off('click')
        // switch circuit function moved inside vue component
        if (!embed) {
            // $('.circuitName').on('click', () => {
            //     simulationArea.lastSelected = globalScope.root
            //     setTimeout(() => {
            //         // here link with the properties panel
            //         document.getElementById('circname').select()
            //     }, 100)
            // })
            circuit_name_clickable.value = true;
        }
        if (!embed) {
            showProperties(scope.root)
        }
        dots(false)
    }
    return scope
}

/**
 * Used to change name of a circuit
 */
export function changeCircuitName(name: string, id = globalScope.id) {
    const simulatorStore = SimulatorStore()
    const { circuit_list } = toRefs(simulatorStore)
    name = name || 'Untitled'
    name = stripTags(name)
    scopeList[id].name = name
    const index = circuit_list.value.findIndex((circuit) => circuit.id === id)
    circuit_list.value[index].name = name
}

/**
 * Class representing a Scope
 * @class
 * @param {string} name - name of the circuit
 * @param {number=} id - a random id for the circuit
 * @category circuit
 */
export default class Scope {
    restrictedCircuitElementsUsed: any[];
    id: number | string;
    CircuitElement: any[];
    name: string;
    root: CircuitElement;
    backups: string[];
    history: string[];
    timeStamp: number;
    verilogMetadata: { isVerilogCircuit: boolean; isMainCircuit: boolean; code: string; subCircuitScopeIds: string[]; };
    ox: number;
    oy: number;
    scale: number;
    stack: any[];
    layout: { width: number; height: number; title_x: number; title_y: number; titleEnabled: boolean; };
    tunnelList?: {};
    pending?: any[];
    nodes?: any[];
    allNodes?: any[];
    wires?: any[];
    Input?: any[];
    Output?: any[];
    Splitter?: any[];
    SubCircuit?: any[];
    Clock?: any[];
    constructor(name = 'localScope', id = undefined) {
        this.restrictedCircuitElementsUsed = []
        this.id = id || Math.floor(Math.random() * 100000000000 + 1)
        this.CircuitElement = []
        this.name = name

        // root object for referring to main canvas - intermediate node uses this
        this.root = new CircuitElement(0, 0, this, 'RIGHT', 1)
        this.backups = []
        // maintaining a state (history) for redo function
        this.history = []
        this.timeStamp = new Date().getTime()
        this.verilogMetadata = {
            isVerilogCircuit: false,
            isMainCircuit: false,
            code: '// Write Some Verilog Code Here!',
            subCircuitScopeIds: [],
        }

        this.ox = 0
        this.oy = 0
        this.scale = DPR
        this.stack = []

        this.initialize()

        // Setting default layout
        this.layout = {
            // default position
            width: 100,
            height: 40,
            title_x: 50,
            title_y: 13,
            titleEnabled: true,
        }
    }

    isVisible() {
        if (!this.verilogMetadata.isVerilogCircuit) return true
        return this.verilogMetadata.isMainCircuit
    }

    initialize() {
        this.tunnelList = {}
        this.pending = []
        this.nodes = [] // intermediate nodes only
        this.allNodes = []
        this.wires = []

        // Creating arrays for other module elements
        for (let i = 0; i < moduleList.length; i++) {
            this[moduleList[i]] = []
        }
    }

    /**
     * Resets all nodes recursively
     */
    reset() {
        if (this.allNodes) {
            for (let i = 0; i < this.allNodes.length; i++) {
                this.allNodes[i].reset()
            }
        }
        if (this.Splitter) {
            for (let i = 0; i < this.Splitter.length; i++) {
                this.Splitter[i].reset()
            }
        }
        if (this.SubCircuit) {
            for (let i = 0; i < this.SubCircuit.length; i++) {
                this.SubCircuit[i].reset()
            }
        }
    }

    /**
     * Adds all inputs to simulationQueue
     */
    addInputs() {
        for (let i = 0; i < inputList.length; i++) {
            for (var j = 0; j < this[inputList[i]].length; j++) {
                simulationArea.simulationQueue?.add(this[inputList[i]][j], 0)
            }
        }

        if (this.SubCircuit) {
            for (let i = 0; i < this.SubCircuit.length; i++) {
                this.SubCircuit[i].addInputs()
            }
        }
    }

    /**
     * Ticks clocks recursively -- needs to be deprecated and synchronize all clocks with a global clock
     */
    clockTick() {
        if (this.Clock) {
            for (let i = 0; i < this.Clock.length; i++) {
                this.Clock[i].toggleState()
            } // tick clock!
        }
        if (this.SubCircuit) {
            for (let i = 0; i < this.SubCircuit.length; i++) {
                this.SubCircuit[i].localScope.clockTick()
            } // tick clock!
        }
    }

    /**
     * Checks if this circuit contains directly or indirectly scope with id
     * Recursive nature
     */
    checkDependency(id: number) {
        if (id === this.id) return true
        if (this.SubCircuit) {
            for (let i = 0; i < this.SubCircuit.length; i++) {
                if (this.SubCircuit[i].id === id) return true
            }
        }
        if (this.SubCircuit) {
            for (let i = 0; i < this.SubCircuit.length; i++) {
                if (scopeList[this.SubCircuit[i].id].checkDependency(id))
                    return true
            }
        }

        return false
    }

    /**
     * Get dependency list - list of all circuits, this circuit depends on
     */
    getDependencies() {
        var list = []
        if (this.SubCircuit) {
            for (let i = 0; i < this.SubCircuit.length; i++) {
                list.push(this.SubCircuit[i].id)
                list.push(...scopeList[this.SubCircuit[i].id].getDependencies())
            }
        }
        return uniq(list)
    }

    /**
     * helper function to reduce layout size
     */
    fixLayout() {
        var maxY = 20
        if (this.Input) {
            for (let i = 0; i < this.Input.length; i++) {
                maxY = Math.max(this.Input[i].layoutProperties.y, maxY)
            }
        }
        if (this.Output) {
            for (let i = 0; i < this.Output.length; i++) {
                maxY = Math.max(this.Output[i].layoutProperties.y, maxY)
            }
        }
        if (maxY !== this.layout.height) {
            this.layout.height = maxY + 10
        }
    }

    /**
     * Function which centers the circuit to the correct zoom level
     */
    centerFocus(zoomIn = true) {
        if (layoutModeGet()) return
        findDimensions(this)

        var ytoolbarOffset = embed ? 0 : 60 * DPR // Some part ofcanvas is hidden behind the toolbar

        var minX = simulationArea.minWidth || 0
        var minY = simulationArea.minHeight || 0
        var maxX = simulationArea.maxWidth || 0
        var maxY = simulationArea.maxHeight || 0

        var reqWidth = maxX - minX + 75 * DPR
        var reqHeight = maxY - minY + 75 * DPR

        this.scale = Math.min(
            width / reqWidth,
            (height - ytoolbarOffset) / reqHeight
        )

        if (!zoomIn) {
            this.scale = Math.min(this.scale, DPR)
        }
        this.scale = Math.max(this.scale, DPR / 10)

        this.ox = -minX * this.scale + (width - (maxX - minX) * this.scale) / 2
        this.oy =
            -minY * this.scale +
            (height - ytoolbarOffset - (maxY - minY) * this.scale) / 2
    }
}
