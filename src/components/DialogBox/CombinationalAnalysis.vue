<template>
    <messageBox
        v-model="SimulatorState.dialogBox.combinationalanalysis_dialog"
        class="messageBox"
        :button-list="buttonArr"
        :input-list="inputArr"
        input-class="combinationalAnalysisInput"
        :is-persistent="true"
        :table-header="tableHeader"
        :table-body="tableBody"
        message-text="Boolean Logic Table"
        @button-click="
            (selectedOption, circuitItem, circuitNameVal) =>
                dialogBoxConformation(selectedOption)
        "
    />
    <v-alert v-if="showAlert" :type="alertType" class="alertStyle">{{
        alertMessage
    }}</v-alert>
</template>

<script lang="ts" setup>
import { stripTags } from '#/simulator/src/utils'
import { useState } from '#/store/SimulatorStore/state'
import messageBox from '@/MessageBox/messageBox.vue'
import { ref } from 'vue'
import { onMounted } from 'vue'

/* imports from combinationalAnalysis.js */
import { GenerateCircuit, solveBooleanFunction } from '#/simulator/src/combinationalAnalysis'

const SimulatorState = useState()
onMounted(() => {
    SimulatorState.dialogBox.combinationalanalysis_dialog = false
})
const inputArr = ref([{}])
const buttonArr = ref([{}])
const showAlert = ref(false)
const alertType = ref('error')
const alertMessage = ref('')
const outputListNamesInteger = ref([])
const inputListNames = ref([])
const outputListNames = ref([])
const tableHeader = ref([])
const tableBody = ref([])
const output = ref([])

inputArr.value = [
    {
        text: 'Enter Input names separated by commas: ',
        val: '',
        placeholder: 'eg. In A, In B',
        id: 'inputNameList',
        style: '',
        class: 'cAinput',
        type: 'text',
    },
    {
        text: 'Enter Output names separated by commas: ',
        val: '',
        placeholder: 'eg. Out X, Out Y',
        id: 'outputNameList',
        style: '',
        class: 'cAinput',
        type: 'text',
    },
    {
        text: 'OR',
        placeholder: '',
        id: '',
        style: 'text-align:center;',
        class: 'cAinput',
        type: 'nil',
    },
    {
        text: 'Enter Boolean Function:',
        val: '',
        placeholder: 'Example: (AB)',
        id: 'booleanExpression',
        style: '',
        class: 'cAinput',
        type: 'text',
    },
    {
        text: 'I need a decimal column.',
        val: '',
        placeholder: '',
        id: 'decimalColumnBox',
        style: '',
        class: 'cAinput',
        type: 'checkbox',
    },
]

const buttonArray = [
    {
        text: 'Next',
        emitOption: 'showLogicTable',
    },
    {
        text: 'Close',
        emitOption: 'closeMessageBox',
    },
]
buttonArr.value = buttonArray

function clearData() {
    inputArr.value[0].val = ''
    inputArr.value[1].val = ''
    inputArr.value[3].val = ''
    inputArr.value[4].val = ''
    buttonArr.value = buttonArray
    outputListNamesInteger.value = []
    inputListNames.value = []
    outputListNames.value = []
    tableHeader.value = []
    tableBody.value = []
    output.value = []
}

function dialogBoxConformation(selectedOption, circuitItem) {
    // SimulatorState.dialogBox.combinationalanalysis_dialog = false
    // use the above value to show tables and later clear it all
    if (selectedOption == 'showLogicTable') {
        createLogicTable()
    }
    if (selectedOption == 'closeMessageBox') {
        for (var ind = 0; ind < inputArr.value.length; ind++) {
            if (inputArr.value[ind].type == 'text') {
                inputArr.value[ind].val = ''
            }
            if (inputArr.value[ind].type == 'checkbox') {
                inputArr.value[ind].val = false
            }
        }
        clearData()
        SimulatorState.dialogBox.combinationalanalysis_dialog = false
    }
    if (selectedOption == 'generateCircuit') {
        SimulatorState.dialogBox.combinationalanalysis_dialog = false
        GenerateCircuit()
        clearData()
        SimulatorState.dialogBox.combinationalanalysis_dialog = false
    }
    if (selectedOption == 'printTruthTable') {
        printBooleanTable()
        clearData()
        SimulatorState.dialogBox.combinationalanalysis_dialog = false
    }
}

function createLogicTable() {
    let inputList = stripTags(inputArr.value[0].val).split(',')
    let outputList = stripTags(inputArr.value[1].val).split(',')
    let booleanExpression = inputArr.value[3].val

    inputList = inputList.map((x) => x.trim())
    inputList = inputList.filter((e) => e)
    outputList = outputList.map((x) => x.trim())
    outputList = outputList.filter((e) => e)
    booleanExpression = booleanExpression.replace(/ /g, '')
    booleanExpression = booleanExpression.toUpperCase()

    var booleanInputVariables = []
    for (var i = 0; i < booleanExpression.length; i++) {
        if (booleanExpression[i] >= 'A' && booleanExpression[i] <= 'Z') {
            if (booleanExpression.indexOf(booleanExpression[i]) == i) {
                booleanInputVariables.push(booleanExpression[i])
            }
        }
    }
    booleanInputVariables.sort()

    if (
        inputList.length > 0 &&
        outputList.length > 0 &&
        booleanInputVariables.length == 0
    ) {
        // $(this).dialog('close')
        SimulatorState.dialogBox.combinationalanalysis_dialog = false

        createBooleanPrompt(inputList, outputList, null)
    } else if (
        booleanInputVariables.length > 0 &&
        inputList.length == 0 &&
        outputList.length == 0
    ) {
        // $(this).dialog('close')
        SimulatorState.dialogBox.combinationalanalysis_dialog = false
        output.value = []
        solveBooleanFunction(booleanInputVariables, booleanExpression)
        if (output.value != null) {
            createBooleanPrompt(booleanInputVariables, booleanExpression)
        }
    } else if (
        (inputList.length == 0 || outputList.length == 0) &&
        booleanInputVariables == 0
    ) {
        showAlert.value = true
        alertType.value = 'info'
        alertMessage.value =
            'Enter Input / Output Variable(s) OR Boolean Function!'
        setTimeout(() => {
            showAlert.value = false
        }, 2000)
    } else {
        showAlert.value = true
        alertType.value = 'warning'
        alertMessage.value =
            'Use Either Combinational Analysis Or Boolean Function To Generate Circuit!'
        setTimeout(() => {
            showAlert.value = false
        }, 2000)
    }
}

function createBooleanPrompt(inputList, outputList, scope = globalScope) {
    inputListNames.value =
        inputList || prompt('Enter inputs separated by commas').split(',')
    outputListNames.value =
        outputList || prompt('Enter outputs separated by commas').split(',')
    if (output.value == null) {
        for (var i = 0; i < outputListNames.value.length; i++) {
            outputListNamesInteger.value[i] = 7 * i + 13
        } // assigning an integer to the value, 7*i + 13 is random
    } else {
        outputListNamesInteger.value = [13]
    }
    tableBody.value = []
    tableHeader.value = []
    let fw = 0
    if (inputArr.value[4].val == true) {
        fw = 1
        tableHeader.value.push('dec')
    }
    for (var i = 0; i < inputListNames.value.length; i++) {
        tableHeader.value.push(inputListNames.value[i])
    }
    if (output.value == null) {
        for (var i = 0; i < outputListNames.value.length; i++) {
            tableHeader.value.push(outputListNames.value[i])
        }
    } else {
        tableHeader.value.push(outputListNames.value)
    }

    for (var i = 0; i < 1 << inputListNames.value.length; i++) {
        tableBody.value[i] = new Array(tableHeader.value.length)
    }
    for (var i = 0; i < inputListNames.value.length; i++) {
        for (var j = 0; j < 1 << inputListNames.value.length; j++) {
            tableBody.value[j][i + fw] = +(
                (j & (1 << (inputListNames.value.length - i - 1))) !=
                0
            )
        }
    }
    if (inputArr.value[4].val == true) {
        for (var j = 0; j < 1 << inputListNames.value.length; j++) {
            tableBody.value[j][0] = j
        }
    }
    for (var j = 0; j < 1 << inputListNames.value.length; j++) {
        for (var i = 0; i < outputListNamesInteger.value.length; i++) {
            if (output.value == null) {
                tableBody.value[j][inputListNames.value.length + fw + i] = 'x'
            }
        }
        if (output.value != null) {
            tableBody.value[j][inputListNames.value.length + fw] =
                output.value[j]
        }
    }
    // display Message Box
    SimulatorState.dialogBox.combinationalanalysis_dialog = true
    buttonArr.value = [
        {
            text: 'Generate Circuit',
            emitOption: 'generateCircuit',
        },
        {
            text: 'Print Truth Table',
            emitOption: 'printTruthTable',
        },
    ]
}

function printBooleanTable() {
    var sTable = $('.messageBox .v-card-text')[0].innerHTML

    var style =
        `<style>
        table {font: 40px Calibri;}
        table, th, td {border: solid 1px #DDD;border-collapse: 0;}
        tbody {padding: 2px 3px;text-align: center;}
        </style>`.replace(/\n/g, "")
    var win = window.open('', '', 'height=700,width=700')
    var htmlBody = `
                       <html><head>\
                       <title>Boolean Logic Table</title>\
                       ${style}\
                       </head>\
                       <body>\
                       <center>${sTable}</center>\
                       </body></html>
                     `
    win.document.write(htmlBody)
    win.document.close()
    win.print()
}
</script>

<style scoped>
.alertStyle {
    position: absolute;
    /* top: 50%; */
    top: 100px;
    left: 50%;
    transform: translate(-50%, -50%);
    z-index: 10000;
}
</style>

<!--
    some errors due to output.value
    output.value == null not working
-->
