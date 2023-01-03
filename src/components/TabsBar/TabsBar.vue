<template>
    <div id="tabsBar" class="noSelect pointerCursor">
        <draggable
            :key="updateCount"
            v-model="SimulatorState.circuit_list"
            class="list-group"
            tag="transition-group"
            :component-data="{
                tag: 'div',
                type: 'transition-group',
                name: !drag ? 'flip-list' : null,
            }"
            v-bind="dragOptions"
            @start="drag = true"
            @end="drag = false"
        >
            <template #item="{ element }">
                <div
                    :id="element.id"
                    :key="element.id"
                    style=""
                    class="circuits toolbarButton"
                    :class="tabsbarClasses(element.id)"
                    draggable="true"
                    @click="switchCircuit(element.id)"
                >
                    <span class="circuitName noSelect">
                        {{ truncateString(scopeList[element.id].name, 18) }}
                    </span>
                    <span
                        id="scope.id"
                        class="tabsCloseButton"
                        @click="closeCircuit($event, element)"
                    >
                        <v-icon class="tabsbar-close">mdi-close</v-icon>
                    </span>
                </div>
            </template>
        </draggable>
        <button @click="createNewCircuit()">&#43;</button>
    </div>
    <MessageBox
        v-model="SimulatorState.dialogBox.create_circuit"
        :circuit-item="circuitToBeDeleted"
        :button-list="buttonArr"
        :input-list="inputArr"
        :is-persistent="persistentShow"
        :message-text="messageVal"
        @button-click="
            (selectedOption, circuitItem, circuitNameVal) =>
                dialogBoxConformation(
                    selectedOption,
                    circuitItem,
                    circuitNameVal
                )
        "
    />
</template>

<script lang="ts" setup>
import draggable from 'vuedraggable'
import { showMessage, truncateString } from '#/simulator/src/utils'
import { ref } from '@vue/reactivity'
import { computed, onMounted, onUpdated } from '@vue/runtime-core'
import {
    createNewCircuitScope,
    getDependenciesList,
    scopeList,
    switchCircuit,
} from '#/simulator/src/circuit'
import MessageBox from '#/components/MessageBox/messageBox.vue'
import { useState } from '#/store/SimulatorStore/state'

const SimulatorState = useState()
const drag = ref(false)
const updateCount = ref(0)
const persistentShow = ref(false)
const messageVal = ref('')
const buttonArr = ref([{}])
const inputArr = ref([''])
const circuitToBeDeleted = ref({})

function clearMessageBoxFields() {
    SimulatorState.dialogBox.create_circuit = false
    persistentShow.value = false
    messageVal.value = ''
    buttonArr.value = []
    inputArr.value = []
}

function closeCircuit(e, circuitItem) {
    e.stopPropagation()

    clearMessageBoxFields()
    // check circuit count
    if (SimulatorState.circuit_list.length <= 1) {
        SimulatorState.dialogBox.create_circuit = true
        persistentShow.value = false
        messageVal.value =
            'At least 2 circuits need to be there in order to delete a circuit.'
        buttonArr.value = [
            {
                text: 'Close',
                emitOption: 'dispMessage',
            },
        ]
        return
    }
    clearMessageBoxFields()

    let dependencies = getDependenciesList(circuitItem.id)
    if (dependencies) {
        dependencies = `\nThe following circuits are depending on '${
            scopeList[circuitItem.id].name
        }': ${dependencies}\nDelete subcircuits of ${
            scopeList[circuitItem.id].name
        } before trying to delete ${scopeList[circuitItem.id].name}`
        SimulatorState.dialogBox.create_circuit = true
        persistentShow.value = true
        messageVal.value = dependencies
        buttonArr.value = [
            {
                text: 'OK',
                emitOption: 'dispMessage',
            },
        ]
        return
    }

    clearMessageBoxFields()
    SimulatorState.dialogBox.create_circuit = true
    persistentShow.value = true
    buttonArr.value = [
        {
            text: 'Continue',
            emitOption: 'confirmDeletion',
        },
        {
            text: 'Cancel',
            emitOption: 'cancelDeletion',
        },
    ]
    circuitToBeDeleted.value = circuitItem
    messageVal.value = `Are you sure want to close: ${
        scopeList[circuitItem.id].name
    }\nThis cannot be undone.`
    // console.log(circuitItem)
}

function deleteCircuit(circuitItem) {
    var index = SimulatorState.circuit_list.indexOf(circuitItem)
    if (index !== -1) {
        SimulatorState.circuit_list.splice(index, 1)
    }

    let scope = scopeList[circuitItem.id]
    if (scope == undefined) scope = scopeList[globalScope.id]

    if (scope.verilogMetadata.isVerilogCircuit) {
        scope.initialize()
        for (var id in scope.verilogMetadata.subCircuitScopeIds)
            delete scopeList[id]
    }
    $(`#${scope.id}`).remove()
    delete scopeList[scope.id]
    switchCircuit(Object.keys(scopeList)[0])

    showMessage('Circuit was successfully closed')
    updateCount.value++
}

function dialogBoxConformation(selectedOption, circuitItem, circuitNameVal) {
    SimulatorState.dialogBox.create_circuit = false
    if (selectedOption == 'confirmDeletion') {
        deleteCircuit(circuitItem)
    }
    if (selectedOption == 'cancelDeletion') {
        showMessage('Circuit was not closed')
    }
    if (selectedOption == 'confirmCreation') {
        createNewCircuitScope(circuitNameVal)
    }
}

function createNewCircuit() {
    clearMessageBoxFields()
    SimulatorState.dialogBox.create_circuit = true
    persistentShow.value = true
    buttonArr.value = [
        {
            text: 'Create',
            emitOption: 'confirmCreation',
        },
        {
            text: 'Cancel',
            emitOption: 'cancelCreation',
        },
    ]
    inputArr.value = ['Enter Circuit Name']
}

function dragOptions() {
    return {
        animation: 200,
        group: 'description',
        disabled: false,
        ghostClass: 'ghost',
    }
}

function tabsbarClasses(id) {
    let class_list = ''
    if (embed) {
        class_list = 'embed-tabs'
    }
    if (globalScope.id == id) {
        class_list += ' current'
    }
    return class_list
}
</script>

<style scoped>
.list-group {
    display: inline;
}

.tabsbar-close {
    font-size: 13px;
}
</style>
