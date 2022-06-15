/* eslint-disable import/no-cycle */
/* eslint-disable guard-for-in */
/* eslint-disable no-restricted-syntax */
import Node from './node';
import { scheduleBackup } from './data/backupCircuit';
import BooleanMinimize from './quinMcCluskey';
import Input from './modules/Input';
import ConstantVal from './modules/ConstantVal';
import Output from './modules/Output';
import AndGate from './modules/AndGate';
import OrGate from './modules/OrGate';
import NotGate from './modules/NotGate';
import { stripTags } from './utils';

var inputSample = 5;
var dataSample = [['01---', '11110', '01---', '00000'], ['01110', '1-1-1', '----0'], ['01---', '11110', '01110', '1-1-1', '0---0'], ['----1']];

var sampleInputListNames = ['A', 'B'];
var sampleOutputListNames = ['X'];

/**
 * The prompt for combinational analysis
 * @param {Scope=} - the circuit in which we want combinational analysis
 * @category combinationalAnalysis
 */
export function createCombinationalAnalysisPrompt(scope = globalScope) {
    scheduleBackup();
    $('#combinationalAnalysis').empty();
    $('#combinationalAnalysis').append("<p>Enter Input names separated by commas: <input id='inputNameList' type='text'  placeHolder='eg. In A, In B'></p>");
    $('#combinationalAnalysis').append("<p>Enter Output names separated by commas: <input id='outputNameList' type='text'  placeHolder='eg. Out X, Out Y'></p>");
    $('#combinationalAnalysis').append("<p style='text-align:center;'>OR</p>");
    $('#combinationalAnalysis').append("<p>Enter Boolean Function: <input class='truth_table_input' autofocus id='booleanExpression' placeholder='Example: (AB)' type='text'></p>");
    $('#combinationalAnalysis').append("<label class='cb-checkbox'>I need a decimal column.<input id='decimalColumnBox' type='checkbox'></label>");
    $('#combinationalAnalysis').dialog({
        resizable:false,
        width: 'auto',
        buttons: [
            {
                style: 'padding: 5px',
                text: 'Next',
                click() {
                    var inputList = stripTags($("#inputNameList").val()).split(',');
                    var outputList = stripTags($("#outputNameList").val()).split(',');
                    var booleanExpression = $('#booleanExpression').val();
                    inputList = inputList.map((x) => x.trim());
                    inputList = inputList.filter((e) => e);
                    outputList = outputList.map((x) => x.trim());
                    outputList = outputList.filter((e) => e);
                    booleanExpression = booleanExpression.replace(/ /g, '');
                    booleanExpression = booleanExpression.toUpperCase();
                    
                    var booleanInputVariables = [];
                    for (var i = 0; i < booleanExpression.length; i++) {
                        if ((booleanExpression[i] >= 'A' && booleanExpression[i] <= 'Z')) {
                            if (booleanExpression.indexOf(booleanExpression[i]) == i) {
                                booleanInputVariables.push(booleanExpression[i]);
                            }
                        }
                    }
                    booleanInputVariables.sort();
                    
                    if (inputList.length > 0 && outputList.length > 0 && booleanInputVariables.length == 0) {
                        $(this).dialog('close');
                        createBooleanPrompt(inputList, outputList, null, scope);
                    } 
                    else if (booleanInputVariables.length > 0 && inputList.length == 0 && outputList.length == 0) {
                        $(this).dialog('close');
                        var output = solveBooleanFunction(booleanInputVariables, booleanExpression);
                        if(output != null) {
                            createBooleanPrompt(booleanInputVariables, booleanExpression, output, scope);
                        }
                    }
                    else if ((inputList.length == 0 || outputList.length == 0) && booleanInputVariables == 0) {
                        alert('Enter Input / Output Variable(s) OR Boolean Function!');
                    }
                    else {
                        alert('Use Either Combinational Analysis Or Boolean Function To Generate Circuit!');
                    }
                },
            },
        ],
    });
    $("#combinationalAnalysis").checkBo();
}
/**
 * This funciton hashes the output array and makes required JSON using
 * a BooleanMinimize class defined in Quin_Mcluskey.js var s which will
 * be output table is also initialied here
 * @param {Array} inputListNames - labels of input nodes
 * @param {Array} outputListNames - labels of output nodes
 * @param {Scope=} scope - h circuit
 * @category combinationalAnalysis
 */
function createBooleanPrompt(inputListNames, outputListNames, output, scope = globalScope) {
    var inputListNames = inputListNames || (prompt('Enter inputs separated by commas').split(','));
    var outputListNames = outputListNames || (prompt('Enter outputs separated by commas').split(','));
    var outputListNamesInteger = [];
    if(output == null) {
        for (var i = 0; i < outputListNames.length; i++) { outputListNamesInteger[i] = 7 * i + 13; }// assigning an integer to the value, 7*i + 13 is random
    } else {
        outputListNamesInteger = [13];
    }
    var s = '<table  class="content-table">';
    s += '<tbody style="display:block; max-height:70vh; overflow-y:scroll" >';
    s += '<tr>';
    if ($('#decimalColumnBox').is(':checked')) { s += '<th>' + 'dec' + '</th>'; }
    for (var i = 0; i < inputListNames.length; i++) { s += `<th>${inputListNames[i]}</th>`; }
    if (output == null) { for (var i = 0; i < outputListNames.length; i++) { s += `<th>${outputListNames[i]}</th>`; } }
    else { s += `<th>${outputListNames}</th>`; }
    s += '</tr>';

    var matrix = [];
    for (var i = 0; i < inputListNames.length; i++) {
        matrix[i] = new Array((1 << inputListNames.length));
    }

    for (var i = 0; i < inputListNames.length; i++) {
        for (var j = 0; j < (1 << inputListNames.length); j++) {
            matrix[i][j] = (+((j & (1 << (inputListNames.length - i - 1))) != 0));
        }
    }

    for (var j = 0; j < (1 << inputListNames.length); j++) {
        s += '<tr>';
        if ($('#decimalColumnBox').is(':checked')) { s += `<td>${j}</td>`; }
        for (var i = 0; i < inputListNames.length; i++) {
            s += `<td>${matrix[i][j]}</td>`;
        }
        for (var i = 0; i < outputListNamesInteger.length; i++) {
            if (output == null) {
                s += `<td class ="output ${outputListNamesInteger[i]}" id="${j}">` + 'x' + '</td>';
            // using hash values as they'll be used in the generateBooleanTableData function
            }
        }
        if (output != null) {
            s += `<td class="${outputListNamesInteger[0]}" id="${j}">` + `${output[j]}` + '</td>';
        }
        s += '</tr>';
    }
    s += '</tbody>';
    s += '</table>';
    $('#combinationalAnalysis').empty();
    $('#combinationalAnalysis').append(s);
    $('#combinationalAnalysis').dialog({
        resizable: false,
        width: 'auto',
        buttons: [
            {
                style: 'padding: 6px',
                text: 'Generate Circuit',
                click() {
                    $(this).dialog('close');
                    var data = generateBooleanTableData(outputListNamesInteger);
                    // passing the hash values to avoid spaces being passed which is causing a problem
                    var minimizedCircuit = [];
                    let inputCount = inputListNames.length;
                    for (const output in data) {
                        let oneCount = data[output][1].length; // Number of ones
                        let zeroCount = data[output][0].length; // Number of zeroes
                        if(oneCount == 0) {
                            // Hardcode to 0 as output
                            minimizedCircuit.push(['-'.repeat(inputCount) + '0']);
                        }
                        else if(zeroCount == 0) {
                            // Hardcode to 1 as output
                            minimizedCircuit.push(['-'.repeat(inputCount) + '1']);
                        }
                        else {
                            // Perform KMap like minimzation
                            const temp = new BooleanMinimize(
                                inputListNames.length,
                                data[output][1].map(Number),
                                data[output].x.map(Number),
                            );
                            minimizedCircuit.push(temp.result);
                        }
                    }
                    if (output == null) {
                        drawCombinationalAnalysis(minimizedCircuit, inputListNames, outputListNames, scope);
                    }
                    else {
                        drawCombinationalAnalysis(minimizedCircuit, inputListNames, [`${outputListNames}`], scope);
                    }
                },
            },
            {
                style: 'padding: 6px',
                text: 'Print Truth Table',
                click() {
                    var sTable = document.getElementById('combinationalAnalysis').innerHTML;
                    var style = '<style> table {font: 20px Calibri;} table, th, td {border: solid 1px #DDD;border-collapse: collapse;} padding: 2px 3px;text-align: center;} </style>';
                    var win = window.open('', '', 'height=700,width=700');
                    var htmlBody = `
                      <html><head>\
                      <title>Boolean Logic Table</title>\
                      ${style}\
                      </head>\
                      <body>\
                      <center>${sTable}</center>\
                      </body></html>
                    `;
                    win.document.write(htmlBody);
                    win.document.close();
                    win.print();
                },
            },
        ],
    });

    $('.output').on('click',function () {
        var v = $(this).html();
        if (v == 0)v = $(this).html(1);
        else if (v == 1)v = $(this).html('x');
        else if (v == 'x')v = $(this).html(0);
    });
}

function generateBooleanTableData(outputListNames) {
    var data = {};
    for (var i = 0; i < outputListNames.length; i++) {
        data[outputListNames[i]] = {
            x: [],
            1: [],
            0: [],
        };
        var rows = $(`.${outputListNames[i]}`);
        for (let j = 0; j < rows.length; j++) {
            data[outputListNames[i]][rows[j].innerHTML].push(rows[j].id);
        }
    }
    return data;
}

function drawCombinationalAnalysis(combinationalData, inputList, outputListNames, scope = globalScope) {
    var inputCount = inputList.length;
    var maxTerms = 0;
    for (var i = 0; i < combinationalData.length; i++) { maxTerms = Math.max(maxTerms, combinationalData[i].length); }

    var startPosX = 200;
    var startPosY = 200;

    var currentPosY = 300;
    var andPosX = startPosX + inputCount * 40 + 40 + 40;
    var orPosX = andPosX + Math.floor(maxTerms / 2) * 10 + 80;
    var outputPosX = orPosX + 60;
    var inputObjects = [];

    var logixNodes = [];

    // Appending constant input to the end of inputObjects
    for (var i = 0; i <= inputCount; i++) {
        if(i < inputCount) {
            // Regular Input
            inputObjects.push(new Input(startPosX + i * 40, startPosY, scope, 'DOWN', 1));
            inputObjects[i].setLabel(inputList[i]);
        }
        else {
            // Constant Input
            inputObjects.push(new ConstantVal(startPosX + i * 40, startPosY, scope, 'DOWN', 1, '1'));
            inputObjects[i].setLabel('_C_');
        }
        
        inputObjects[i].newLabelDirection('UP');
        var v1 = new Node(startPosX + i * 40, startPosY + 20, 2, scope.root);
        inputObjects[i].output1.connect(v1);
        var v2 = new Node(startPosX + i * 40 + 20, startPosY + 20, 2, scope.root);
        v1.connect(v2);
        var notG = new NotGate(startPosX + i * 40 + 20, startPosY + 40, scope, 'DOWN', 1);
        notG.inp1.connect(v2);
        logixNodes.push(v1);
        logixNodes.push(notG.output1);
    }

    function countTerm(s) {
        var c = 0;
        for (var i = 0; i < s.length; i++) { if (s[i] !== '-')c++; }
        return c;
    }

    for (var i = 0; i < combinationalData.length; i++) {
        var andGateNodes = [];
        for (var j = 0; j < combinationalData[i].length; j++) {
            var c = countTerm(combinationalData[i][j]);
            if (c > 1) {
                var andGate = new AndGate(andPosX, currentPosY, scope, 'RIGHT', c, 1);
                andGateNodes.push(andGate.output1);
                var misses = 0;
                for (var k = 0; k < combinationalData[i][j].length; k++) {
                    if (combinationalData[i][j][k] == '-') { misses++; continue; }
                    var index = 2 * k + (combinationalData[i][j][k] == 0);
                    var v = new Node(logixNodes[index].absX(), andGate.inp[k - misses].absY(), 2, scope.root);
                    logixNodes[index].connect(v);
                    logixNodes[index] = v;
                    v.connect(andGate.inp[k - misses]);
                }
            } else {
                for (var k = 0; k < combinationalData[i][j].length; k++) {
                    if (combinationalData[i][j][k] == '-') continue;
                    var index = 2 * k + (combinationalData[i][j][k] == 0);
                    var andGateSubstituteNode = new Node(andPosX, currentPosY, 2, scope.root);
                    var v = new Node(logixNodes[index].absX(), andGateSubstituteNode.absY(), 2, scope.root);
                    logixNodes[index].connect(v);
                    logixNodes[index] = v;
                    v.connect(andGateSubstituteNode);
                    andGateNodes.push(andGateSubstituteNode);
                }
            }
            currentPosY += c * 10 + 30;
        }

        var andGateCount = andGateNodes.length;
        var midWay = Math.floor(andGateCount / 2);
        var orGatePosY = (andGateNodes[midWay].absY() + andGateNodes[Math.floor((andGateCount - 1) / 2)].absY()) / 2;
        if (orGatePosY % 10 == 5) { orGatePosY += 5; } // To make or gate fall in grid
        if (andGateCount > 1) {
            var o = new OrGate(orPosX, orGatePosY, scope, 'RIGHT', andGateCount, 1);
            if (andGateCount % 2 == 1)andGateNodes[midWay].connect(o.inp[midWay]);
            for (var j = 0; j < midWay; j++) {
                var v = new Node(andPosX + 30 + (midWay - j) * 10, andGateNodes[j].absY(), 2, scope.root);
                v.connect(andGateNodes[j]);
                var v2 = new Node(andPosX + 30 + (midWay - j) * 10, o.inp[j].absY(), 2, scope.root);
                v2.connect(v);
                o.inp[j].connect(v2);

                var v = new Node(andPosX + 30 + (midWay - j) * 10, andGateNodes[andGateCount - j - 1].absY(), 2, scope.root);
                v.connect(andGateNodes[andGateCount - j - 1]);
                var v2 = new Node(andPosX + 30 + (midWay - j) * 10, o.inp[andGateCount - j - 1].absY(), 2, scope.root);
                v2.connect(v);
                o.inp[andGateCount - j - 1].connect(v2);
            }
            var out = new Output(outputPosX, o.y, scope, 'LEFT', 1);
            out.inp1.connect(o.output1);
        } else {
            var out = new Output(outputPosX, andGateNodes[0].absY(), scope, 'LEFT', 1);
            out.inp1.connect(andGateNodes[0]);
        }
        out.setLabel(outputListNames[i]);
        out.newLabelDirection('RIGHT');
    }
    for (var i = 0; i < logixNodes.length; i++) {
        if (logixNodes[i].absY() != currentPosY) {
            var v = new Node(logixNodes[i].absX(), currentPosY, 2, scope.root);
            logixNodes[i].connect(v);
        }
    }
    globalScope.centerFocus();
}

/**
 * This function solves passed boolean expression and returns
 * output array which contains solution of the truth table
 * of given boolean expression
 * @param {Array}  inputListNames - labels for input nodes
 * @param {String} booleanExpression - boolean expression which is to be solved 
 */
function solveBooleanFunction(inputListNames, booleanExpression) {
    let i;
    let j;
    let output = [];

    if (booleanExpression.match(/[^ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01+'() ]/g) != null) {
        alert('One of the characters is not allowed.');
        return;
    }

    if (inputListNames.length > 8) {
        alert('You can only have 8 variables at a time.');
        return;
    }

    var s = '<table  class="content-table">';
    s += '<tbody style="display:block; max-height:70vh; overflow-y:scroll" >';
    s += '<tr>';
    if ($('#decimalColumnBox').is(':checked')) { s += '<th>' + 'dec' + '</th>'; }
    for (i = 0; i < inputListNames.length; i++) { s += `<th>${inputListNames[i]}</th>`; }
    s += `<th>${booleanExpression}</th>`;
    s += '</tr>';
    var matrix = [];
    for (i = 0; i < inputListNames.length; i++) {
        matrix[i] = new Array((inputListNames.length));
    }

    for (i = 0; i < inputListNames.length; i++) {
        for (j = 0; j < (1 << inputListNames.length); j++) {
            matrix[i][j] = (+((j & (1 << (inputListNames.length - i - 1))) != 0));
        }
    }
    // generate equivalent expression by replacing input vars with possible combinations of o and 1
    for (i = 0; i < (2 ** inputListNames.length); i++) {
        const data = [];
        for (j = 0; j < inputListNames.length; j++) {
            data[j] = Math.floor(i / Math.pow(2, inputListNames.length - j - 1)) % 2;
        }
        let equation = booleanExpression;
        for (j = 0; j < inputListNames.length; j++) {
            equation = equation.replace(new RegExp(inputListNames[j], 'g'), data[j]);
        }

        output[i] = solve(equation);
    }

    for (j = 0; j < (1 << inputListNames.length); j++) {
        s += '<tr>';
        if ($('#decimalColumnBox').is(':checked')) { s += `<td>${j}</td>`; }
        for (i = 0; i < inputListNames.length; i++) {
            s += `<td>${matrix[i][j]}</td>`;
        }

        s += `<td class="13" id="${j}">` + `${output[j]}` + '</td>';
        s += '</tr>';
    }

    s += '</tbody>';
    s += '</table>';
    // generates solution for the truth table of booleanexpression
    function solve(equation) {
        while (equation.indexOf("(") != -1) {
            const start = equation.lastIndexOf("(");
            const end = equation.indexOf(")", start);
            if (start != -1) {
                equation = equation.substring(0, start)
                + solve(equation.substring(start + 1, end))
                + equation.substring(end + 1);
            }       
        }
        equation = equation.replace(/''/g, '');
        equation = equation.replace(/0'/g, '1');
        equation = equation.replace(/1'/g, '0');
        for (let i = 0; i < equation.length - 1; i++) {
            if ((equation[i] == '0' || equation[i] == '1') && (equation[i + 1] == '0' || equation[i + 1] == '1')) {
                equation = equation.substring(0, i + 1) + '*' + equation.substring(i + 1, equation.length);
            }
        }        
        try {
            const safeEval = eval;
            const answer = safeEval(equation);
            if (answer == 0) {
                return 0;
            }
            if (answer > 0) {
                return 1;
            }    
            return '';
        } catch (e) {
            return '';
        }
    }

    return output;
}
