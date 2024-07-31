<template>
    <MessageBox
        v-model="promptStore.DeleteCircuit.activate"
        :circuit-item="promptStore.DeleteCircuit.circuitItem"
        :button-list="promptStore.DeleteCircuit.buttonList"
        :is-persistent="promptStore.DeleteCircuit.isPersistent"
        :message-text="promptStore.DeleteCircuit.messageText"
        @button-click="
            (selectedOption:string, circuitItem:CircuitItem) =>
                confirmation(selectedOption, circuitItem)
        "
    />
</template>

<script lang="ts">
import { showMessage } from '#/simulator/src/utils'
import { getDependenciesList, scopeList } from '#/simulator/src/circuit'
import { switchCircuit } from '#/simulator/src/circuit'
import { usePromptStore } from '#/store/promptStore'
import { useState } from '#/store/SimulatorStore/state'
import MessageBox from '#/components/MessageBox/messageBox.vue'

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

type CircuitItem = {
    id: string | number
    name: string
}

function clearMessageBoxFields(): void {
    const promptStore = usePromptStore()

    promptStore.DeleteCircuit.activate = false
    promptStore.DeleteCircuit.circuitItem = {}
    promptStore.DeleteCircuit.isPersistent = false
    promptStore.DeleteCircuit.messageText = ''
    promptStore.DeleteCircuit.buttonList = []
}

export function closeCircuit(circuitItem: CircuitItem): void {
    const SimulatorState = <SimulatorStateType>useState()
    const promptStore = usePromptStore()

    clearMessageBoxFields()
    //  * Ensures that at least one circuit is there
    if (SimulatorState.circuit_list.length <= 1) {
        promptStore.DeleteCircuit.activate = true
        promptStore.DeleteCircuit.isPersistent = false
        promptStore.DeleteCircuit.messageText =
            'At least 2 circuits need to be there in order to delete a circuit.'
        promptStore.DeleteCircuit.buttonList = [
            {
                text: 'Close',
                emitOption: 'dispMessage',
            },
        ]
        return
    }
    clearMessageBoxFields()

    //  * Ensures that no circuit depends on the current circuit
    let dependencies = getDependenciesList(circuitItem.id)
    if (dependencies) {
        dependencies = `\nThe following circuits are depending on '${
            scopeList[circuitItem.id].name
        }': [ ${dependencies} ].\n Delete subcircuits of ${
            scopeList[circuitItem.id].name
        } before trying to delete ${scopeList[circuitItem.id].name}`
        promptStore.DeleteCircuit.activate = true
        promptStore.DeleteCircuit.isPersistent = true
        promptStore.DeleteCircuit.messageText = dependencies
        promptStore.DeleteCircuit.buttonList = [
            {
                text: 'OK',
                emitOption: 'dispMessage',
            },
        ]
        return
    }

    clearMessageBoxFields()
    promptStore.DeleteCircuit.activate = true
    promptStore.DeleteCircuit.isPersistent = true
    promptStore.DeleteCircuit.buttonList = [
        {
            text: 'Continue',
            emitOption: 'confirmDeletion',
        },
        {
            text: 'Cancel',
            emitOption: 'cancelDeletion',
        },
    ]
    promptStore.DeleteCircuit.circuitItem = circuitItem
    promptStore.DeleteCircuit.messageText = `Are you sure want to close: ${
        scopeList[circuitItem.id].name
    }\nThis cannot be undone.`
}

/**
 * Deletes the current circuit
 * Switched to another circuit if the active circuit is deleted
 * @category circuit
 */
export function deleteCurrentCircuit(
    scopeId: string | number = globalScope.id ?? useState().activeCircuit?.id
) {
    const SimulatorState = <SimulatorStateType>useState()
    const circuit_list = SimulatorState.circuit_list
    let scope = scopeList[scopeId]
    if (scope == undefined)
        scope = scopeList[globalScope.id ?? SimulatorState.activeCircuit?.id]

    if (scope.verilogMetadata.isVerilogCircuit) {
        scope.initialize()
        for (var id in scope.verilogMetadata.subCircuitScopeIds)
            delete scopeList[id]
    }
    const index = circuit_list.findIndex(
        (circuit: any) => circuit.id === scope.id
    )
    circuit_list.splice(index, 1)
    delete scopeList[scope.id]
    if (scope.id == globalScope.id ?? SimulatorState.activeCircuit?.id) {
        switchCircuit(Object.keys(scopeList)[0])
    }
    showMessage('Circuit was successfully closed')
}
</script>

<script lang="ts" setup>
const promptStore = usePromptStore()

function confirmation(selectedOption: string, circuitItem: CircuitItem): void {
    promptStore.DeleteCircuit.activate = false
    if (selectedOption == 'confirmDeletion') {
        deleteCurrentCircuit(circuitItem.id)
    } else if (selectedOption == 'cancelDeletion') {
        showMessage('Circuit was not closed')
    }
}
</script>
