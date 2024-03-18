<template>
    <div
        id="tabsBar"
        class="noSelect pointerCursor"
        :class="[embedClass(), { maxHeightStyle: showMaxHeight }]"
    >
        <draggable
            :key="updateCount"
            :item-key="updateCount.toString()"
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
                    :class="tabsbarClasses(element)"
                    draggable="true"
                    @click="switchCircuit(element.id)"
                >
                    <span class="circuitName noSelect">
                        {{ truncateString(element.name, 18) }}
                    </span>
                    <span
                        v-if="!isEmbed()"
                        :id="element.id"
                        class="tabsCloseButton"
                        @click.stop="closeCircuit(element)"
                    >
                        <v-icon class="tabsbar-close">mdi-close</v-icon>
                    </span>
                </div>
            </template>
        </draggable>
        <button v-if="!isEmbed()" @click="createNewCircuitScope()">
            &#43;
        </button>
        <button class="tabsbar-toggle" @click="toggleHeight">
            <i :class="showMaxHeight ? 'fa fa-chevron-down' : 'fa fa-chevron-up'"></i>
        </button>
    </div>
    <!-- <MessageBox
        v-model="SimulatorState.dialogBox.create_circuit"
        :circuit-item="circuitToBeDeleted"
        :button-list="buttonArr"
        :input-list="inputArr"
        input-class="tabsbarInput"
        :is-persistent="persistentShow"
        :message-text="messageVal"
        @button-click="
            (selectedOption, circuitItem) =>
                dialogBoxConformation(selectedOption, circuitItem)
        "
    /> -->
</template>

<script lang="ts" setup>
import draggable from 'vuedraggable'
import { showMessage, truncateString } from '#/simulator/src/utils'
import { ref, Ref } from 'vue'
import {
    createNewCircuitScope,
    // deleteCurrentCircuit,
    // getDependenciesList,
    // scopeList,
    switchCircuit,
} from '#/simulator/src/circuit'
// import MessageBox from '#/components/MessageBox/messageBox.vue'
import { useState } from '#/store/SimulatorStore/state'
import { closeCircuit } from '../helpers/deleteCircuit/DeleteCircuit.vue'

const SimulatorState = <SimulatorStateType>useState()
const drag: Ref<boolean> = ref(false)
const updateCount: Ref<number> = ref(0)

const showMaxHeight = ref(true)

function toggleHeight() {
    showMaxHeight.value = !showMaxHeight.value
}

// const persistentShow: Ref<boolean> = ref(false)
// const messageVal: Ref<string> = ref('')
// const buttonArr: Ref<Array<buttonArrType>> = ref([{ text: '', emitOption: '' }])
// const inputArr: Ref<Array<InputArrType>> = ref([
//     {
//         text: '',
//         val: '',
//         placeholder: '',
//         id: '',
//         class: '',
//         style: '',
//         type: '',
//     },
// ])
// const circuitToBeDeleted: Ref<Object> = ref({})

// type CircuitItem = {
//     id: string | number
//     name: string
//     focussed: boolean
// }

type SimulatorStateType = {
    circuit_list: Array<Object>
    dialogBox: {
        create_circuit: boolean
    }
}

// type InputArrType = {
//     text: string
//     val: string
//     placeholder: string
//     id: string
//     class: string
//     style: string
//     type: string
// }

// type buttonArrType = {
//     text: string
//     emitOption: string
// }

// function clearMessageBoxFields(): void {
//     SimulatorState.dialogBox.create_circuit = false
//     persistentShow.value = false
//     messageVal.value = ''
//     buttonArr.value = []
//     inputArr.value = []
// }

// function closeCircuit(circuitItem: CircuitItem): void {
//     clearMessageBoxFields()
//     // check circuit count
//     if (SimulatorState.circuit_list.length <= 1) {
//         SimulatorState.dialogBox.create_circuit = true
//         persistentShow.value = false
//         messageVal.value =
//             'At least 2 circuits need to be there in order to delete a circuit.'
//         buttonArr.value = [
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
//         }': [ ${dependencies} ].\nDelete subcircuits of ${
//             scopeList[circuitItem.id].name
//         } before trying to delete ${scopeList[circuitItem.id].name}`
//         SimulatorState.dialogBox.create_circuit = true
//         persistentShow.value = true
//         messageVal.value = dependencies
//         buttonArr.value = [
//             {
//                 text: 'OK',
//                 emitOption: 'dispMessage',
//             },
//         ]
//         return
//     }

//     clearMessageBoxFields()
//     SimulatorState.dialogBox.create_circuit = true
//     persistentShow.value = true
//     buttonArr.value = [
//         {
//             text: 'Continue',
//             emitOption: 'confirmDeletion',
//         },
//         {
//             text: 'Cancel',
//             emitOption: 'cancelDeletion',
//         },
//     ]
//     circuitToBeDeleted.value = circuitItem
//     messageVal.value = `Are you sure want to close: ${
//         scopeList[circuitItem.id].name
//     }\nThis cannot be undone.`
// }

// function deleteCircuit(circuitItem: CircuitItem): void {
//     deleteCurrentCircuit(circuitItem.id)
//     updateCount.value++
// }

// function dialogBoxConformation(
//     selectedOption: string,
//     circuitItem: CircuitItem
// ): void {
//     SimulatorState.dialogBox.create_circuit = false
//     if (selectedOption == 'confirmDeletion') {
//         deleteCircuit(circuitItem)
//     }
//     if (selectedOption == 'cancelDeletion') {
//         showMessage('Circuit was not closed')
//     }
//     if (selectedOption == 'confirmCreation') {
//         createNewCircuitScope(inputArr.value[0].val)
//     }
// }

// function createNewCircuit() {
//     updateCount.value++
//     createNewCircuitScope()
// }

// function createNewCircuit(): void {
//     clearMessageBoxFields()
//     SimulatorState.dialogBox.create_circuit = true
//     persistentShow.value = true
//     buttonArr.value = [
//         {
//             text: 'Create',
//             emitOption: 'confirmCreation',
//         },
//         {
//             text: 'Cancel',
//             emitOption: 'cancelCreation',
//         },
//     ]

//     inputArr.value = [
//         {
//             text: 'Enter Circuit Name',
//             val: '',
//             placeholder: 'Untitled-Circuit',
//             id: 'circuitName',
//             class: 'inputField',
//             style: '',
//             type: 'text',
//         },
//     ]
// }

function dragOptions(): Object {
    return {
        animation: 200,
        group: 'description',
        disabled: false,
        ghostClass: 'ghost',
    }
}

function tabsbarClasses(e: any): string {
    let class_list = ''
    if ((window as any).embed) {
        class_list = 'embed-tabs'
    }
    if (e.focussed) {
        class_list += ' current'
    }
    return class_list
}

function embedClass(): string {
    if ((window as any).embed) {
        return 'embed-tabbar'
    }
    return ''
}

function isEmbed(): boolean {
    return (window as any).embed
}
</script>

<style scoped>
#tabsBar{
    padding-right: 50px;
    position: relative;
    overflow: hidden;
    padding-bottom: 2.5px;
    z-index: 100;
}

#tabsBar.embed-tabbar {
    background-color: transparent;
}

#tabsBar.embed-tabbar .circuits {
    border: 1px solid var(--br-circuit);
    color: var(--text-circuit);
    background-color: var(--bg-tabs) !important;
}

#tabsBar.embed-tabbar .circuits:hover {
    background-color: var(--bg-circuit) !important;
}

#tabsBar.embed-tabbar .current {
    color: var(--text-circuit);
    background-color: var(--bg-circuit) !important;
    /* border: 1px solid var(--br-circuit-cur); */
}

#tabsBar button {
    font-size: 1rem; 
    height: 20px;
    width: 20px;
}

#tabsBar.embed-tabbar button {
    color: var(--text-panel);
    background-color: var(--primary);
    border: 1px solid var(--br-circuit-cur);
}

#tabsBar.embed-tabbar button:hover {
    color: var(--text-panel);
    border: 1px solid var(--br-circuit-cur);
}

.list-group {
    display: inline;
}

.maxHeightStyle {
    height: 30px;
    max-height: 30px;
}

.toolbarButton{
    height: 22px;
}

.tabsbar-toggle{
    position: absolute;
    right: 2.5px;
    top: 2.5px;

    display: flex;
    justify-content: center;
    align-items: center;

}

.tabsbar-toggle i {
    margin-bottom: -5px;
}


.tabsbar-close{
    font-size: 1rem; 
}

</style>

<!-- TODO: add types for scopelist and fix key issue with draggable -->
