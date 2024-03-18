<template>
    <p>
        <span>Project:</span>
        <!-- class="objectPropertyAttribute" -->
        <input
            id="projname"
            type="text"
            autocomplete="off"
            name="setProjectName"
            v-model="projectStore.project.name"
            :oninput="projectStore.setProjectNameDefined"
        />
    </p>

    <p>
        <span>Circuit:</span>
        <input
            id="circname"
            :key="SimulatorState.activeCircuit.id"
            class="objectPropertyAttribute"
            type="text"
            autocomplete="off"
            name="changeCircuitName"
            :value="SimulatorState.activeCircuit.name"
        />
    </p>

    <InputGroups
        property-name="Clock Time (ms):"
        :property-value="(simulationArea as any).timePeriod"
        property-value-type="number"
        value-min="50"
        step-size="10"
        property-input-name="changeClockTime"
        property-input-id="clockTime"
    />

    <p>
        <span>Clock Enabled:</span>
        <label class="switch">
            <input
                type="checkbox"
                class="objectPropertyAttributeChecked"
                name="changeClockEnable" />
            <span class="slider"></span
        ></label>
    </p>

    <p>
        <span>Lite Mode:</span>
        <label class="switch">
            <input
                type="checkbox"
                class="objectPropertyAttributeChecked"
                name="changeLightMode"
            />
            <span class="slider"></span>
        </label>
    </p>

    <p>
        <button
            type="button"
            class="panelButton btn btn-xs custom-btn--primary"
            @click="toggleLayoutMode"
        >
            Edit Layout
        </button>
        <button
            type="button"
            class="panelButton btn btn-xs custom-btn--tertiary"
            @click.stop="closeCircuit(SimulatorState.activeCircuit)"
        >
            Delete Circuit
        </button>
    </p>
    <!-- <MessageBox
        v-model="SimulatorState.dialogBox.delete_circuit"
        :circuit-item="circuitToDelete"
        :button-list="buttonArray"
        :is-persistent="ifPersistentShow"
        :message-text="messageValue"
        @button-click="
            (selectedOption, circuitItem) =>
                dialogBoxConformation(selectedOption, circuitItem)
        "
    /> -->
    <!-- <DeleteCircuit /> -->
</template>

<script lang="ts" setup>
import { toggleLayoutMode } from '#/simulator/src/layoutMode'
// import {
//     deleteCurrentCircuit,
//     getDependenciesList,
//     scopeList,
// } from '#/simulator/src/circuit'
// import { showMessage } from '#/simulator/src/utils'
import simulationArea from '#/simulator/src/simulationArea'
import InputGroups from '#/components/Panels/Shared/InputGroups.vue'
// import MessageBox from '#/components/MessageBox/messageBox.vue'
// import { ref, Ref, onMounted, watch } from 'vue'
import { useState } from '#/store/SimulatorStore/state'
import { useProjectStore } from '#/store/projectStore'
// import DeleteCircuit from '#/components/helpers/deleteCircuit/DeleteCircuit.vue'
import { closeCircuit } from '#/components/helpers/deleteCircuit/DeleteCircuit.vue'

const projectStore = useProjectStore()
const SimulatorState = <SimulatorStateType>useState()
// const circuitId: Ref<string | number> = ref(0)
// const circuitName: Ref<string> = ref('Untitled-Cirucit')
// const ifPersistentShow: Ref<boolean> = ref(false)
// const messageValue: Ref<string> = ref('')
// const buttonArray: Ref<Array<buttonArrType>> = ref([
//     { text: '', emitOption: '' },
// ])
// const circuitToDelete: Ref<Object> = ref({})

type SimulatorStateType = {
    activeCircuit: {
        id: string | number
        name: string
    }
    circuit_list: Array<Object>
    dialogBox: {
        delete_circuit: boolean
    }
}

// type CircuitItem = {
//     id: string | number
//     name: string
// }

// type buttonArrType = {
//     text: string
//     emitOption: string
// }

// onMounted(() => {
//     // checking if circuit or tab is switched
//     // setInterval(() => {
//     //     if (circuitId.value != globalScope.id) {
//     //         circuitName.value = globalScope.name
//     //         circuitId.value = globalScope.id
//     //     }
//     // }, 250)
//     watch(
//         () => SimulatorState.activeCircuit,
//         () => {
//             circuitName.value = SimulatorState.activeCircuit.name
//             circuitId.value = SimulatorState.activeCircuit.id
//         },
//         { deep: true }
//     )
// })

// function clearMessageBoxFields(): void {
//     SimulatorState.dialogBox.delete_circuit = false
//     ifPersistentShow.value = false
//     messageValue.value = ''
//     buttonArray.value = []
// }

// function closeCircuit(circuitItem: CircuitItem): void {
//     clearMessageBoxFields()
//     // check circuit count
//     if (SimulatorState.circuit_list.length <= 1) {
//         SimulatorState.dialogBox.delete_circuit = true
//         ifPersistentShow.value = false
//         messageValue.value =
//             'At least 2 circuits need to be there in order to delete a circuit.'
//         buttonArray.value = [
//             {
//                 text: 'Close',
//                 emitOption: 'dispMessage',
//             },
//         ]
//         return
//     }
//     clearMessageBoxFields()

//     let dependencies = getDependenciesList(circuitItem.id)
//     if (dependencies) {
//         dependencies = `\nThe following circuits are depending on '${
//             scopeList[circuitItem.id].name
//         }': [ ${dependencies} ].\n Delete subcircuits of ${
//             scopeList[circuitItem.id].name
//         } before trying to delete ${scopeList[circuitItem.id].name}`
//         SimulatorState.dialogBox.delete_circuit = true
//         ifPersistentShow.value = true
//         messageValue.value = dependencies
//         buttonArray.value = [
//             {
//                 text: 'OK',
//                 emitOption: 'dispMessage',
//             },
//         ]
//         return
//     }

//     clearMessageBoxFields()
//     SimulatorState.dialogBox.delete_circuit = true
//     ifPersistentShow.value = true
//     buttonArray.value = [
//         {
//             text: 'Continue',
//             emitOption: 'confirmDeletion',
//         },
//         {
//             text: 'Cancel',
//             emitOption: 'cancelDeletion',
//         },
//     ]
//     circuitToDelete.value = circuitItem
//     messageValue.value = `Are you sure want to close: ${
//         scopeList[circuitItem.id].name
//     }\nThis cannot be undone.`
// }

// function dialogBoxConformation(
//     selectedOption: string,
//     circuitItem: CircuitItem
// ): void {
//     SimulatorState.dialogBox.delete_circuit = false
//     if (selectedOption == 'confirmDeletion') {
//         deleteCurrentCircuit(circuitItem.id)
//     } else if (selectedOption == 'cancelDeletion') {
//         showMessage('Circuit was not closed')
//     }
// }
</script>

<style scoped>
.panelButton {
    width: 100%;
    margin-bottom: 5px;
}
</style>

<!-- TODO: add type to scopeList and fix clock timer and clock enable and lite mode (crashing with continuous resetup() calls) -->
