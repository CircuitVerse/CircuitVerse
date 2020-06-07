/* eslint-disable import/no-cycle */
/* eslint-disable guard-for-in */
/* eslint-disable no-restricted-syntax */
import Node from './node';
import { scheduleBackup } from './data/backupCircuit';
import BooleanMinimize from './quinMcCluskey';
import Input from './modules/Input';
import Output from './modules/Output';
import AndGate from './modules/AndGate';
import OrGate from './modules/OrGate';
import NotGate from './modules/NotGate';

const inputSample = 5;
const dataSample = [['01---', '11110', '01---', '00000'], ['01110', '1-1-1', '----0'], ['01---', '11110', '01110', '1-1-1', '0---0'], ['----1']];

const sampleInputListNames = ['A', 'B'];
const sampleOutputListNames = ['X'];

/**
 * The prompt for combinational analysis
 * @param {Scope=} - the circuit in which we want combinational analysis
 * @category combinationalAnalysis
 */
export function createCombinationalAnalysisPrompt(scope = globalScope) {
    // console.log("Ya");
    scheduleBackup();
    $('#combinationalAnalysis').empty();
    $('#combinationalAnalysis').append("<p>Enter Input names separated by commas: <input id='inputNameList' type='text'  placeHolder='eg. In A, In B'></p>");
    $('#combinationalAnalysis').append("<p>Enter Output names separated by commas: <input id='outputNameList' type='text'  placeHolder='eg. Out X, Out Y'></p>");
    $('#combinationalAnalysis').append("<p>Do you need a decimal column? <input id='decimalColumnBox' type='checkbox'></p>");
    $('#combinationalAnalysis').dialog({
        width: 'auto',
        buttons: [
            {
                text: 'Next',
                click() {
                    let inputList = $('#inputNameList').val().split(',');
                    let outputList = $('#outputNameList').val().split(',');
                    inputList = inputList.map((x) => x.trim());
                    inputList = inputList.filter((e) => e);
                    outputList = outputList.map((x) => x.trim());
                    outputList = outputList.filter((e) => e);
                    if (inputList.length > 0 && outputList.length > 0) {
                        $(this).dialog('close');
                        createBooleanPrompt(inputList, outputList, scope);
                    } else {
                        alert('Enter Input / Output Variable(s) !');
                    }
                },
            },
        ],
    });
}
/**
 * This funciton hashes the output array and makes required JSON using
 * a BooleanMinimize class defined in Quin_Mcluskey.js let s which will
 * be output table is also initialied here
 * @param {Array} inputListNames - labels of input nodes
 * @param {Array} outputListNames - labels of output nodes
 * @param {Scope=} scope - h circuit
 * @category combinationalAnalysis
 */
function createBooleanPrompt(inputListNames, outputListNames, scope = globalScope) {
    inputListNames = inputListNames || (prompt('Enter inputs separated by commas').split(','));
    outputListNames = outputListNames || (prompt('Enter outputs separated by commas').split(','));
    const outputListNamesInteger = [];
    for (let i = 0; i < outputListNames.length; i++) { outputListNamesInteger[i] = 7 * i + 13; }// assigning an integer to the value, 7*i + 13 is random

    let s = '<table>';
    s += '<tbody style="display:block; max-height:70vh; overflow-y:scroll" >';
    s += '<tr>';
    if ($('#decimalColumnBox').is(':checked')) { s += '<th>' + 'dec' + '</th>'; }
    for (let i = 0; i < inputListNames.length; i++) { s += `<th>${inputListNames[i]}</th>`; }
    for (let i = 0; i < outputListNames.length; i++) { s += `<th>${outputListNames[i]}</th>`; }
    s += '</tr>';

    const matrix = [];
    for (let i = 0; i < inputListNames.length; i++) {
        matrix[i] = new Array((1 << inputListNames.length));
    }

    for (let i = 0; i < inputListNames.length; i++) {
        for (let j = 0; j < (1 << inputListNames.length); j++) {
            matrix[i][j] = (+((j & (1 << (inputListNames.length - i - 1))) != 0));
        }
    }

    for (let j = 0; j < (1 << inputListNames.length); j++) {
        s += '<tr>';
        if ($('#decimalColumnBox').is(':checked')) { s += `<td>${j}</td>`; }
        for (let i = 0; i < inputListNames.length; i++) {
            s += `<td>${matrix[i][j]}</td>`;
        }
        for (let i = 0; i < outputListNamesInteger.length; i++) {
            s += `<td class ="output ${outputListNamesInteger[i]}" id="${j}">` + 'x' + '</td>';
            // using hash values as they'll be used in the generateBooleanTableData function
        }
        s += '</tr>';
    }
    s += '</tbody>';
    s += '</table>';
    // console.log(s)
    $('#combinationalAnalysis').empty();
    $('#combinationalAnalysis').append(s);
    $('#combinationalAnalysis').dialog({
        width: 'auto',
        buttons: [
            {
                text: 'Generate Circuit',
                click() {
                    $(this).dialog('close');
                    const data = generateBooleanTableData(outputListNamesInteger);
                    // passing the hash values to avoid spaces being passed which is causing a problem
                    const minmizedCircuit = [];
                    for (const output in data) {
                        const temp = new BooleanMinimize(
                            inputListNames.length,
                            data[output][1].map(Number),
                            data[output].x.map(Number),
                        );
                        minmizedCircuit.push(temp.result);
                    }
                    // //console.log(dataSample);
                    drawCombinationalAnalysis(minmizedCircuit, inputListNames, outputListNames, scope);
                },
            },
            {
                text: 'Print Truth Table',
                click() {
                    const sTable = document.getElementById('combinationalAnalysis').innerHTML;
                    const style = '<style> table {font: 20px Calibri;} table, th, td {border: solid 1px #DDD;border-collapse: collapse;} padding: 2px 3px;text-align: center;} </style>';
                    const win = window.open('', '', 'height=700,width=700');
                    win.document.write('<html><head>');
                    win.document.write('<title>Boolean Logic Table</title>');
                    win.document.write(style);
                    win.document.write('</head>');
                    win.document.write('<body>');
                    win.document.write(`<center>${sTable}</center>`);
                    win.document.write('</body></html>');
                    win.document.close();
                    win.print();
                },
            },
        ],
    });

    $('.output').click(function () {
        let v = $(this).html();
        if (v == 0)v = $(this).html(1);
        else if (v == 1)v = $(this).html('x');
        else if (v == 'x')v = $(this).html(0);
    });
}

function generateBooleanTableData(outputListNames) {
    const data = {};
    for (let i = 0; i < outputListNames.length; i++) {
        data[outputListNames[i]] = {
            x: [],
            1: [],
            0: [],
        };
        const rows = $(`.${outputListNames[i]}`);
        for (let j = 0; j < rows.length; j++) {
            // console.log($rows[j].innerHTML)
            data[outputListNames[i]][rows[j].innerHTML].push(rows[j].id);
        }
    }
    // console.log(data);
    return data;
}

function drawCombinationalAnalysis(combinationalData, inputList, outputListNames, scope = globalScope) {
    // console.log(combinationalData);
    const inputCount = inputList.length;
    let maxTerms = 0;
    for (let i = 0; i < combinationalData.length; i++) { maxTerms = Math.max(maxTerms, combinationalData[i].length); }

    const startPosX = 200;
    const startPosY = 200;

    let currentPosY = 300;
    const andPosX = startPosX + inputCount * 40 + 40;
    const orPosX = andPosX + Math.floor(maxTerms / 2) * 10 + 80;
    const outputPosX = orPosX + 60;
    const inputObjects = [];

    const logixNodes = [];

    for (let i = 0; i < inputCount; i++) {
        inputObjects.push(new Input(startPosX + i * 40, startPosY, scope, 'DOWN', 1));
        inputObjects[i].setLabel(inputList[i]);
        inputObjects[i].newLabelDirection('UP');
        const v1 = new Node(startPosX + i * 40, startPosY + 20, 2, scope.root);
        inputObjects[i].output1.connect(v1);
        const v2 = new Node(startPosX + i * 40 + 20, startPosY + 20, 2, scope.root);
        v1.connect(v2);
        const notG = new NotGate(startPosX + i * 40 + 20, startPosY + 40, scope, 'DOWN', 1);
        notG.inp1.connect(v2);
        logixNodes.push(v1);
        logixNodes.push(notG.output1);
    }

    function countTerm(s) {
        let c = 0;
        for (let i = 0; i < s.length; i++) { if (s[i] !== '-')c++; }
        return c;
    }

    for (let i = 0; i < combinationalData.length; i++) {
        // //console.log(combinationalData[i]);
        const andGateNodes = [];
        for (let j = 0; j < combinationalData[i].length; j++) {
            const c = countTerm(combinationalData[i][j]);
            if (c > 1) {
                const andGate = new AndGate(andPosX, currentPosY, scope, 'RIGHT', c, 1);
                andGateNodes.push(andGate.output1);
                let misses = 0;
                for (let k = 0; k < combinationalData[i][j].length; k++) {
                    if (combinationalData[i][j][k] == '-') { misses++; continue; }
                    const index = 2 * k + (combinationalData[i][j][k] == 0);
                    // console.log(index);
                    // console.log(andGate);
                    const v = new Node(logixNodes[index].absX(), andGate.inp[k - misses].absY(), 2, scope.root);
                    logixNodes[index].connect(v);
                    logixNodes[index] = v;
                    v.connect(andGate.inp[k - misses]);
                }
            } else {
                for (let k = 0; k < combinationalData[i][j].length; k++) {
                    if (combinationalData[i][j][k] == '-') continue;
                    const index = 2 * k + (combinationalData[i][j][k] == 0);
                    const andGateSubstituteNode = new Node(andPosX, currentPosY, 2, scope.root);
                    const v = new Node(logixNodes[index].absX(), andGateSubstituteNode.absY(), 2, scope.root);
                    logixNodes[index].connect(v);
                    logixNodes[index] = v;
                    v.connect(andGateSubstituteNode);
                    andGateNodes.push(andGateSubstituteNode);
                }
            }
            currentPosY += c * 10 + 30;
        }

        const andGateCount = andGateNodes.length;
        const midWay = Math.floor(andGateCount / 2);
        let orGatePosY = (andGateNodes[midWay].absY() + andGateNodes[Math.floor((andGateCount - 1) / 2)].absY()) / 2;
        if (orGatePosY % 10 == 5) { orGatePosY += 5; } // To make or gate fall in grid
        if (andGateCount > 1) {
            const o = new OrGate(orPosX, orGatePosY, scope, 'RIGHT', andGateCount, 1);
            if (andGateCount % 2 == 1)andGateNodes[midWay].connect(o.inp[midWay]);
            for (let j = 0; j < midWay; j++) {
                let v = new Node(andPosX + 30 + (midWay - j) * 10, andGateNodes[j].absY(), 2, scope.root);
                v.connect(andGateNodes[j]);
                let v2 = new Node(andPosX + 30 + (midWay - j) * 10, o.inp[j].absY(), 2, scope.root);
                v2.connect(v);
                o.inp[j].connect(v2);

                v = new Node(andPosX + 30 + (midWay - j) * 10, andGateNodes[andGateCount - j - 1].absY(), 2, scope.root);
                v.connect(andGateNodes[andGateCount - j - 1]);
                v2 = new Node(andPosX + 30 + (midWay - j) * 10, o.inp[andGateCount - j - 1].absY(), 2, scope.root);
                v2.connect(v);
                o.inp[andGateCount - j - 1].connect(v2);
            }
            const out = new Output(outputPosX, o.y, scope, 'LEFT', 1);
            out.inp1.connect(o.output1);
        } else {
            const out = new Output(outputPosX, andGateNodes[0].absY(), scope, 'LEFT', 1);
            out.inp1.connect(andGateNodes[0]);
        }
        out.setLabel(outputListNames[i]);
        out.newLabelDirection('RIGHT');
    }
    for (let i = 0; i < logixNodes.length; i++) {
        if (logixNodes[i].absY() != currentPosY) {
            const v = new Node(logixNodes[i].absX(), currentPosY, 2, scope.root);
            logixNodes[i].connect(v);
        }
    }
}
