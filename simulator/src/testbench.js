/**
 * this file can contain any specific function for testbench modules
 */

import { scheduleBackup } from './data/backupCircuit';
import { changeClockEnable } from './sequential';
import { play } from './engine';
import Scope from './circuit';
import { showError } from './utils';

/**
 * @typedef {number} RunContext
 */
const CONTEXT = {
    CONTEXT_SIMULATOR: 0,
    CONTEXT_ASSIGNMENTS: 1,
};

/**
 * @typedef {number} Mode
 */
const MODE = {
    MODE_RUNALL: 0,
    MODE_MANUAL: 1,
};

// Do we have any other function to do this?
// Utility function. Converts decimal number to binary string
function dec2bin(dec) {
    return (dec >>> 0).toString(2);
}

/**
 * UI Function
 * Create prompt for the testbench UI
 */
export function createTestBenchPrompt() {
    scheduleBackup();
    const s = `
    <p>Enter the Test JSON: <input id='testJSON' type='text'  placeHolder='{"type": "comb", ...}'></p>
    `;
    $('#testBench').dialog({
        resizable: false,
        width: 'auto',
        buttons: [
            {
                text: 'Run All',
                click() {
                    const testJSON = $('#testJSON').val();
                    const testData = validateAndParseJSON(testJSON);
                    if (testData.ok) runTestBench(testData.data, globalScope, MODE.MODE_RUNALL, CONTEXT.CONTEXT_SIMULATOR);
                    // else display data.errorMessage
                },
            },

            {
                text: 'Run Manually',
                click() {
                    const testJSON = $('#testJSON').val();
                    const testData = validateAndParseJSON(testJSON);
                    $(this).dialog('close');
                    if (testData.ok) runTestBench(testData.data, globalScope, MODE.MODE_MANUAL, CONTEXT.CONTEXT_SIMULATOR);
                    // else display data.errorMessage
                },
            },
        ],
    });

    $('#testBench').empty();
    $('#testBench').append(s);
}

/**
 * Interface function to run testbench. Called by testbench prompt on simulator or assignments
 * @param {Object} data - Object containing Test Data
 * @param {Mode=} mode - To run all tests automatically or let user manually control tests
 * @param {RunContext=} runContext - Whether simulator or Assignment called this function
 * @param {Scope=} scope - the circuit
 */
export function runTestBench(data, scope = globalScope, mode = MODE.MODE_RUNALL, runContext = CONTEXT.CONTEXT_SIMULATOR) {
    if (mode === MODE.MODE_MANUAL && runContext === CONTEXT.CONTEXT_ASSIGNMENTS) {
        // Assignment does not support MANUAL mode
        return;
    }
    const isValidData = validate(data, scope);
    if (!isValidData.ok) {
        showError(`TestBench: ${isValidData.message}`);
        return;
    }

    let results;
    if (mode === MODE.MODE_RUNALL) results = runAll(data, scope);
    else if (mode === MODE.MODE_MANUAL) {
        runManual(data, scope);
        return;
    } else {
        showError('TestBench: Bad Test Mode');
        return;
    }

    console.log(results);
}

/**
 * Run all the tests automatically. Called by runTestBench()
 * @param {Object} data - Object containing Test Data
 * @param {Scope=} scope - the circuit
 */
function runAll(data, scope) {
    // Stop the clocks
    // TestBench will now take over clock toggling
    changeClockEnable(false);

    const { inputs, outputs, reset } = bindIO(data, scope);
    for (const group of data.groups) {
        for (const output of group.outputs) output.results = [];
        for (let case_i = 0; case_i < group.n; case_i++) {
            // Set and propagate the inputs
            setInputValues(inputs, group, case_i, scope);
            // If sequential, trigger clock now
            if (data.type === 'seq') tickClock(scope);
            // Get output values
            const caseResult = getOutputValues(data, outputs);
            // Put the results in the data
            for (const outName of caseResult.keys()) {
                // TODO: find() is not the best idea because of O(n)
                const output = group.outputs.find((dataOutput) => dataOutput.label === outName);
                output.results.push(caseResult.get(outName));
            }
        }

        // If sequential, trigger reset at the end of group (set)
        if (data.type === 'seq') triggerReset(reset);
    }

    // Tests done, restart the clocks
    changeClockEnable(true);

    // Return results
    const results = data.groups.map((group) => ({ group: group.label, outputs: group.outputs }));
    return results;
}

/**
 * Run the tests manually. Spawns UI and binds listeneres to the UI
 * Called by runTestBench()
 * @param {Object} data - Object containing the test data
 * @param {Scope} scope - The circuit to run the tests on
 */
function runManual(data, scope) {
    let currentGroup = 0;
    let currentCase = 0;
    let result;

    // Initialize the UI
    initManualUI(data);

    // Show the UI
    $('.testbench-manual-panel').css('visibility', 'visible');

    // Add listeners to buttons
    // Previous Case Button
    $('.tb-dialog-button#prev-case-btn').on('click', () => {
        if (currentCase === 0) {
            if (currentGroup === 0) return;
            currentGroup--;
            currentCase = data.groups[currentGroup].n - 1;
        } else currentCase--;
        manualUISetCurrentCase(data, currentGroup, currentCase);
    });

    // Next Case Button
    $('.tb-dialog-button#next-case-btn').on('click', () => {
        if (currentCase === data.groups[currentGroup].n - 1) {
            if (currentGroup === data.groups.length - 1) return;
            currentGroup++;
            currentCase = 0;
        } else currentCase++;
        manualUISetCurrentCase(data, currentGroup, currentCase);
    });

    // Run Case Button
    $('.tb-dialog-button#run-case-btn').on('click', () => {
        if (data.type === 'comb') {
            result = runSingleCombinational(data, currentGroup, currentCase, scope);
        } else if (data.type === 'seq') {
            result = runSingleSequential(data, currentGroup, currentCase, scope);
        }

        console.log(result);
        manualUISetResult(data, result);
    });

    // Close Button
    $('.tb-dialog-button#close-btn').on('click', () => {
        $('.tb-dialog-button').off('click');
        $('.testbench-manual-panel').css('visibility', 'hidden');
    });
}

/**
 * Runs single combinational test
 * Used in MANUAL mode
 * @param {Object} data - Object containing Test Data
 * @param {number} groupIndex - Index of the group to be tested
 * @param {number} caseIndex - Index of the case inside the group
 * @param {Scope} scope - The circuit
 */
function runSingleCombinational(data, groupIndex, caseIndex, scope) {
    const { inputs, outputs } = bindIO(data, scope);
    const group = data.groups[groupIndex];

    // Stop the clocks
    changeClockEnable(false);

    // Set input values according to the test
    setInputValues(inputs, group, caseIndex, scope);
    // Check output values
    const result = getOutputValues(data, outputs);
    // Restart the clocks
    changeClockEnable(true);
    return result;
}

/**
 * Runs single sequential test and all tests above it in the group
 * Used in MANUAL mode
 * @param {Object} data - Object containing Test Data
 * @param {number} groupIndex - Index of the group to be tested
 * @param {number} caseIndex - Index of the case inside the group
 * @param {Scope} scope - The circuit
 */
function runSingleSequential(data, groupIndex, caseIndex, scope) {
    const { inputs, outputs, reset } = bindIO(data, scope);
    const group = data.groups[groupIndex];

    // Stop the clocks
    changeClockEnable(false);

    // Trigger reset
    triggerReset(reset, scope);

    // Run the test and tests above in the same group
    for (let case_i = 0; case_i <= caseIndex; case_i++) {
        setInputValues(inputs, group, case_i, scope);
        tickClock(scope);
    }

    const result = getOutputValues(data, outputs);

    // Restart the clocks
    changeClockEnable(true);

    return result;
}

/**
 * Set and propogate the input values according to the testcase.
 * Called by runSingle() and runAll()
 * @param {Object} inputs - Object with keys as input names and values as inputs
 * @param {Object} group - Test group
 * @param {number} caseIndex - Index of the case in the group
 * @param {Scope} scope - the circuit
 */
function setInputValues(inputs, group, caseIndex, scope) {
    for (const input of group.inputs) {
        inputs[input.label].state = parseInt(input.values[caseIndex], 2);
    }

    // Propagate inputs
    play(scope);
}

/**
 * Gets Output values as a Map with keys as output name and value as output state
 * @param {Object} outputs - Object with keys as output names and values as outputs
 */
function getOutputValues(data, outputs) {
    const values = new Map();
    for (const dataOutput of data.groups[0].outputs) {
        // Using node value because output state only changes on rendering
        const resultValue = outputs[dataOutput.label].nodeList[0].value;
        values.set(dataOutput.label, dec2bin(resultValue));
    }

    return values;
}

/**
 * Validates JSON syntax and returns parsed object
 * Called by createTestBenchPrompt()
 * @param {Object} dataJSON - JSON of test data
 */
function validateAndParseJSON(dataJSON) {
    try {
        const data = JSON.parse(dataJSON);
        return { ok: true, data };
    } catch (error) {
        return { ok: false, errorMessage: 'Corrupt/Invalid Test Data' };
    }
}

/**
 * Validate if all inputs and output elements are present with correct bitwidths
 * Called by runTestBench()
 * @param {Object} data - Object containing Test Data
 * @param {Scope} scope - the circuit
 */
function validate(data, scope) {
    if (!checkDistinctIdentifiersData(data)) return { ok: false, message: 'Duplicate identifiers in test data' };
    if (!checkDistinctIdentifiersScope(scope)) return { ok: false, message: 'Duplicate identifiers in circuit' };

    // Validate inputs and outputs
    const inputsValid = validateInputs(data, scope);
    const outputsValid = validateOutputs(data, scope);

    if (!inputsValid.ok) return inputsValid;
    if (!outputsValid.ok) return outputsValid;

    // Validate presence of reset if test is sequential
    if (data.type === 'seq') {
        const resetPresent = scope.Input.some((simulatorReset) => (
            simulatorReset.label === 'RST'
                && simulatorReset.bitWidth === 1
                && simulatorReset.objectType === 'Input'
        ));

        if (!(resetPresent)) return { ok: false, message: 'Reset(RST) not present in circuit' };
    }

    return { ok: true };
}

/**
 * Checks if all the labels in the test data are unique. Called by validate()
 * @param {Object} data - Object containing Test Data
 */
function checkDistinctIdentifiersData(data) {
    const inputIdentifiersData = data.groups[0].inputs.map((input) => input.label);
    const outputIdentifiersData = data.groups[0].outputs.map((output) => output.label);
    const identifiersData = inputIdentifiersData.concat(outputIdentifiersData);

    return (new Set(identifiersData)).size === identifiersData.length;
}

/**
 * Checks if all the input/output labels in the scope are unique. Called by validate()
 * TODO: Replace with identifiers
 * @param {Scope} scope - the circuit
 */
function checkDistinctIdentifiersScope(scope) {
    const inputIdentifiersScope = scope.Input.map((input) => input.label);
    const outputIdentifiersScope = scope.Output.map((output) => output.label);
    const identifiersScope = inputIdentifiersScope.concat(outputIdentifiersScope);

    return (new Set(identifiersScope)).size === identifiersScope.length;
}

/**
 * Validates presence and bitwidths of test inputs in the circuit.
 * Called by validate()
 * @param {Object} data - Object containing Test Data
 * @param {Scope} scope - the circuit
 */
function validateInputs(data, scope) {
    for (const dataInput of data.groups[0].inputs) {
        const matchInput = scope.Input.find((simulatorInput) => simulatorInput.label === dataInput.label);

        if (matchInput === undefined) {
            return {
                ok: false,
                message: `Input - ${dataInput.label} is not present in the circuit`,
            };
        }

        if (matchInput.bitWidth !== dataInput.bitWidth) {
            return {
                ok: false,
                message: `Input - ${dataInput.label} bitwidths don't match in circuit and test`,
            };
        }
    }

    return { ok: true };
}

/**
 * Validates presence and bitwidths of test outputs in the circuit.
 * Called by validate()
 * @param {Object} data - Object containing Test Data
 * @param {Scope} scope - the circuit
 */
function validateOutputs(data, scope) {
    for (const dataOutput of data.groups[0].outputs) {
        const matchOutput = scope.Output.find((simulatorOutput) => simulatorOutput.label === dataOutput.label);

        if (matchOutput === undefined) {
            return {
                ok: false,
                message: `Output - ${dataOutput.label} is not present in the circuit`,
            };
        }

        if (matchOutput.bitWidth !== dataOutput.bitWidth) {
            return {
                ok: false,
                message: `Output - ${dataOutput.label} bitwidths don't match in circuit and test`,
            };
        }
    }

    return { ok: true };
}

/**
 * Returns object of scope inputs and outputs keyed by their labels
 * @param {Object} data - Object containing Test Data
 * @param {Scope=} scope - the circuit
 */
function bindIO(data, scope) {
    const inputs = {};
    const outputs = {};
    let reset;
    for (const dataInput of data.groups[0].inputs) {
        inputs[dataInput.label] = scope.Input.find((simulatorInput) => simulatorInput.label === dataInput.label);
    }

    for (const dataOutput of data.groups[0].outputs) {
        outputs[dataOutput.label] = scope.Output.find((simulatorOutput) => simulatorOutput.label === dataOutput.label);
    }

    if (data.type === 'seq') {
        reset = scope.Input.find((simulatorOutput) => simulatorOutput.label === 'RST');
    }

    return { inputs, outputs, reset };
}

/**
 * Ticks clock recursively one full cycle (Only used in testbench context)
 * @param {Scope} scope - the circuit whose clock to be ticked
 */
function tickClock(scope) {
    scope.clockTick();
    play(scope);
    scope.clockTick();
    play(scope);
}

/**
 * Triggers reset (Only used in testbench context)
 * @param {Input} reset - reset pin to be triggered
 * @param {Scope} scope - the circuit
 */
function triggerReset(reset, scope) {
    reset.state = 1;
    play(scope);
    reset.state = 0;
    play(scope);
}

/**
 * UI Function
 * Initialize Manual mode UI
 * Called by runManual()
 * @param {Object} data - Object containing the test data
 */
function initManualUI(data) {
    const inputCount = data.groups[0].inputs.length;
    const outputCount = data.groups[0].outputs.length;
    $('.testbench-manual-panel .tb-data#data-group').children().eq(1).text(1);
    $('.testbench-manual-panel .tb-data#data-case').children().eq(1).text(1);
    $('#tb-manual-table-inputs-head').attr('colspan', inputCount);
    $('#tb-manual-table-outputs-head').attr('colspan', outputCount);

    $('#tb-manual-table-labels').html('<th>Label</th>');
    $('#tb-manual-table-bitwidths').html('<td>Bitwidth</td>');
    for (const io of data.groups[0].inputs.concat(data.groups[0].outputs)) {
        const label = `<th>${io.label}</th>`;
        const bw = `<td>${io.bitWidth}</td>`;
        $('#tb-manual-table-labels').append(label);
        $('#tb-manual-table-bitwidths').append(bw);
    }

    manualUISetCurrentCase(data, 0, 0);
}

/**
 * UI Function
 * Set current test case data on the UI
 * @param {Object} data - Object containing the test data
 * @param {number} groupIndex - Index of the group of current case
 * @param {number} caseIndex - Index of the case within the group
 */
function manualUISetCurrentCase(data, groupIndex, caseIndex) {
    const currCaseElement = $('#tb-manual-table-current-case');
    currCaseElement.empty();
    currCaseElement.append('<td>Current Case</td>');
    $('#tb-manual-table-test-result').empty();
    $('#tb-manual-table-test-result').append('<td>Result</td>');
    for (const input of data.groups[groupIndex].inputs) {
        currCaseElement.append(`<td>${input.values[caseIndex]}</td>`);
    }

    for (const output of data.groups[groupIndex].outputs) {
        currCaseElement.append(`<td>${output.values[caseIndex]}</td>`);
    }

    $('.testbench-manual-panel .tb-data#data-group').children().eq(1).text(groupIndex + 1);
    $('.testbench-manual-panel .tb-data#data-case').children().eq(1).text(caseIndex + 1);
}

/**
 * UI Function
 * Set the current test case result on the UI
 * @param {Object} data - Object containing the test data
 * @param {Map} result - Map containing the output values (returned by getOutputValues())
 */
function manualUISetResult(data, result) {
    const resultElement = $('#tb-manual-table-test-result');
    let inputCount = data.groups[0].inputs.length;
    resultElement.empty();
    resultElement.append('<td>Result</td>');
    while (inputCount--) {
        resultElement.append('<td> - </td>');
    }

    for (const resultValue of result.values()) {
        resultElement.append(`<td>${resultValue}</td>`);
    }
}
