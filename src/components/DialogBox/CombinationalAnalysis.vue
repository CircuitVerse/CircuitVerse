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
import { ref } from '@vue/reactivity'
import { onMounted, onUpdated } from '@vue/runtime-core'

/* imports from combinationalAnalysis.js */
import Node from '#/simulator/src/node'
import BooleanMinimize from '#/simulator/src/quinMcCluskey'
import Input from '#/simulator/src/modules/Input'
import ConstantVal from '#/simulator/src/modules/ConstantVal'
import Output from '#/simulator/src/modules/Output'
import AndGate from '#/simulator/src/modules/AndGate'
import OrGate from '#/simulator/src/modules/OrGate'
import NotGate from '#/simulator/src/modules/NotGate'
import simulationArea from '#/simulator/src/simulationArea'
import { findDimensions } from '#/simulator/src/canvasApi'
import { confirmSingleOption } from '../helpers/confirmComponent/ConfirmComponent.vue'

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
        generateCircuit()
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
        if (output != null) {
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

function generateBooleanTableData(outputListNames) {
    var data = {}
    for (var i = 0; i < outputListNames.length; i++) {
        data[outputListNames[i]] = {
            x: [],
            1: [],
            0: [],
        }
        var rows = $(`.${outputListNames[i]}`)
        for (let j = 0; j < rows.length; j++) {
            data[outputListNames[i]][rows[j].innerHTML].push(rows[j].id)
        }
    }
    return data
}

function drawCombinationalAnalysis(
    combinationalData,
    inputList,
    outputList,
    scope = globalScope
) {
    findDimensions(scope)
    var inputCount = inputList.length
    var maxTerms = 0
    for (var i = 0; i < combinationalData.length; i++) {
        maxTerms = Math.max(maxTerms, combinationalData[i].length)
    }

    var startPosX = 200
    var startPosY = 200

    var currentPosY = 300

    if (simulationArea.maxWidth && simulationArea.maxHeight) {
        if (simulationArea.maxHeight + currentPosY > simulationArea.maxWidth) {
            startPosX += simulationArea.maxWidth
        } else {
            startPosY += simulationArea.maxHeight
            currentPosY += simulationArea.maxHeight
        }
    }
    var andPosX = startPosX + inputCount * 40 + 40 + 40
    var orPosX = andPosX + Math.floor(maxTerms / 2) * 10 + 80
    var outputPosX = orPosX + 60
    var inputObjects = []

    var logixNodes = []

    // Appending constant input to the end of inputObjects
    for (var i = 0; i <= inputCount; i++) {
        if (i < inputCount) {
            // Regular Input
            inputObjects.push(
                new Input(startPosX + i * 40, startPosY, scope, 'DOWN', 1)
            )
            inputObjects[i].setLabel(inputList[i])
        } else {
            // Constant Input
            inputObjects.push(
                new ConstantVal(
                    startPosX + i * 40,
                    startPosY,
                    scope,
                    'DOWN',
                    1,
                    '1'
                )
            )
            inputObjects[i].setLabel('_C_')
        }

        inputObjects[i].newLabelDirection('UP')
        var v1 = new Node(startPosX + i * 40, startPosY + 20, 2, scope.root)
        inputObjects[i].output1.connect(v1)
        var v2 = new Node(
            startPosX + i * 40 + 20,
            startPosY + 20,
            2,
            scope.root
        )
        v1.connect(v2)
        var notG = new NotGate(
            startPosX + i * 40 + 20,
            startPosY + 40,
            scope,
            'DOWN',
            1
        )
        notG.inp1.connect(v2)
        logixNodes.push(v1)
        logixNodes.push(notG.output1)
    }

    function countTerm(s) {
        var c = 0
        for (var i = 0; i < s.length; i++) {
            if (s[i] !== '-') c++
        }
        return c
    }

    for (var i = 0; i < combinationalData.length; i++) {
        var andGateNodes = []
        for (var j = 0; j < combinationalData[i].length; j++) {
            var c = countTerm(combinationalData[i][j])
            if (c > 1) {
                var andGate = new AndGate(
                    andPosX,
                    currentPosY,
                    scope,
                    'RIGHT',
                    c,
                    1
                )
                andGateNodes.push(andGate.output1)
                var misses = 0
                for (var k = 0; k < combinationalData[i][j].length; k++) {
                    if (combinationalData[i][j][k] == '-') {
                        misses++
                        continue
                    }
                    var index = 2 * k + (combinationalData[i][j][k] == 0)
                    var v = new Node(
                        logixNodes[index].absX(),
                        andGate.inp[k - misses].absY(),
                        2,
                        scope.root
                    )
                    logixNodes[index].connect(v)
                    logixNodes[index] = v
                    v.connect(andGate.inp[k - misses])
                }
            } else {
                for (var k = 0; k < combinationalData[i][j].length; k++) {
                    if (combinationalData[i][j][k] == '-') continue
                    var index = 2 * k + (combinationalData[i][j][k] == 0)
                    var andGateSubstituteNode = new Node(
                        andPosX,
                        currentPosY,
                        2,
                        scope.root
                    )
                    var v = new Node(
                        logixNodes[index].absX(),
                        andGateSubstituteNode.absY(),
                        2,
                        scope.root
                    )
                    logixNodes[index].connect(v)
                    logixNodes[index] = v
                    v.connect(andGateSubstituteNode)
                    andGateNodes.push(andGateSubstituteNode)
                }
            }
            currentPosY += c * 10 + 30
        }

        var andGateCount = andGateNodes.length
        var midWay = Math.floor(andGateCount / 2)
        var orGatePosY =
            (andGateNodes[midWay].absY() +
                andGateNodes[Math.floor((andGateCount - 1) / 2)].absY()) /
            2
        if (orGatePosY % 10 == 5) {
            orGatePosY += 5
        } // To make or gate fall in grid
        if (andGateCount > 1) {
            var o = new OrGate(
                orPosX,
                orGatePosY,
                scope,
                'RIGHT',
                andGateCount,
                1
            )
            if (andGateCount % 2 == 1)
                andGateNodes[midWay].connect(o.inp[midWay])
            for (var j = 0; j < midWay; j++) {
                var v = new Node(
                    andPosX + 30 + (midWay - j) * 10,
                    andGateNodes[j].absY(),
                    2,
                    scope.root
                )
                v.connect(andGateNodes[j])
                var v2 = new Node(
                    andPosX + 30 + (midWay - j) * 10,
                    o.inp[j].absY(),
                    2,
                    scope.root
                )
                v2.connect(v)
                o.inp[j].connect(v2)

                var v = new Node(
                    andPosX + 30 + (midWay - j) * 10,
                    andGateNodes[andGateCount - j - 1].absY(),
                    2,
                    scope.root
                )
                v.connect(andGateNodes[andGateCount - j - 1])
                var v2 = new Node(
                    andPosX + 30 + (midWay - j) * 10,
                    o.inp[andGateCount - j - 1].absY(),
                    2,
                    scope.root
                )
                v2.connect(v)
                o.inp[andGateCount - j - 1].connect(v2)
            }
            var out = new Output(outputPosX, o.y, scope, 'LEFT', 1)
            out.inp1.connect(o.output1)
        } else {
            var out = new Output(
                outputPosX,
                andGateNodes[0].absY(),
                scope,
                'LEFT',
                1
            )
            out.inp1.connect(andGateNodes[0])
        }
        out.setLabel(outputList[i])
        out.newLabelDirection('RIGHT')
    }
    for (var i = 0; i < logixNodes.length; i++) {
        if (logixNodes[i].absY() != currentPosY) {
            var v = new Node(logixNodes[i].absX(), currentPosY, 2, scope.root)
            logixNodes[i].connect(v)
        }
    }
    globalScope.centerFocus()
}

/**
 * This function solves passed boolean expression and returns
 * output array which contains solution of the truth table
 * of given boolean expression
 * @param {Array}  inputListNames - labels for input nodes
 * @param {String} booleanExpression - boolean expression which is to be solved
 */
function solveBooleanFunction(inputListNames, booleanExpression) {
    let i
    let j
    output.value = []

    if (
        booleanExpression.match(
            /[^ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01+'() ]/g
        ) != null
    ) {
        // alert('One of the characters is not allowed.')
        confirmSingleOption('One of the characters is not allowed.')
        return
    }

    if (inputListNames.length > 8) {
        // alert('You can only have 8 variables at a time.')
        confirmSingleOption('You can only have 8 variables at a time.')
        return
    }
    var matrix = []
    for (i = 0; i < inputListNames.length; i++) {
        matrix[i] = new Array(inputListNames.length)
    }

    for (i = 0; i < inputListNames.length; i++) {
        for (j = 0; j < 1 << inputListNames.length; j++) {
            matrix[i][j] = +((j & (1 << (inputListNames.length - i - 1))) != 0)
        }
    }
    // generate equivalent expression by replacing input vars with possible combinations of o and 1
    for (i = 0; i < 2 ** inputListNames.length; i++) {
        const data = []
        for (j = 0; j < inputListNames.length; j++) {
            data[j] =
                Math.floor(i / Math.pow(2, inputListNames.length - j - 1)) % 2
        }
        let equation = booleanExpression
        for (j = 0; j < inputListNames.length; j++) {
            equation = equation.replace(
                new RegExp(inputListNames[j], 'g'),
                data[j]
            )
        }

        output.value[i] = solve(equation)
    }
    // generates solution for the truth table of booleanexpression
    function solve(equation) {
        while (equation.indexOf('(') != -1) {
            const start = equation.lastIndexOf('(')
            const end = equation.indexOf(')', start)
            if (start != -1) {
                equation =
                    equation.substring(0, start) +
                    solve(equation.substring(start + 1, end)) +
                    equation.substring(end + 1)
            }
        }
        equation = equation.replace(/''/g, '')
        equation = equation.replace(/0'/g, '1')
        equation = equation.replace(/1'/g, '0')
        for (let i = 0; i < equation.length - 1; i++) {
            if (
                (equation[i] == '0' || equation[i] == '1') &&
                (equation[i + 1] == '0' || equation[i + 1] == '1')
            ) {
                equation =
                    equation.substring(0, i + 1) +
                    '*' +
                    equation.substring(i + 1, equation.length)
            }
        }
        try {
            const safeEval = eval
            const answer = safeEval(equation)
            if (answer == 0) {
                return 0
            }
            if (answer > 0) {
                return 1
            }
            return ''
        } catch (e) {
            return ''
        }
    }
}

function generateCircuit() {
    var data = generateBooleanTableData(outputListNamesInteger.value)
    var minimizedCircuit = []
    let inputCount = inputListNames.value.length
    for (const output in data) {
        let oneCount = data[output][1].length // Number of ones
        let zeroCount = data[output][0].length // Number of zeroes
        if (oneCount == 0) {
            // Hardcode to 0 as output
            minimizedCircuit.push(['-'.repeat(inputCount) + '0'])
        } else if (zeroCount == 0) {
            // Hardcode to 1 as output
            minimizedCircuit.push(['-'.repeat(inputCount) + '1'])
        } else {
            // Perform KMap like minimzation
            const temp = new BooleanMinimize(
                inputListNames.value.length,
                data[output][1].map(Number),
                data[output].x.map(Number)
            )
            minimizedCircuit.push(temp.result)
        }
    }
    if (output.value == null) {
        drawCombinationalAnalysis(
            minimizedCircuit,
            inputListNames.value,
            outputListNames.value,
            globalScope
        )
    } else {
        drawCombinationalAnalysis(
            minimizedCircuit,
            inputListNames.value,
            [`${outputListNames.value}`],
            globalScope
        )
    }
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
