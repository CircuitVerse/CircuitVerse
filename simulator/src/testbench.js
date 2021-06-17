/**
 * this file can contain any specific function for testbench modules
 */

import { scheduleBackup } from './data/backupCircuit';
import simulationArea from './simulationArea';
import startListeners from './listeners';
import { renderCanvas, update, scheduleUpdate, play } from './engine';
import plotArea from './plotArea'
import { generateSaveData } from './data/save';
import { loadScope } from './data/load';
import Scope from './circuit';

/**
 * @typedef {number} RunContext
 */
const CONTEXT = {
    CONTEXT_SIMULATOR: 0,
    CONTEXT_ASSIGNMENTS: 1
}

/**
 * @typedef {number} Mode
 */
const MODE = {
    MODE_RUNALL: 0,
    MODE_MANUAL: 1
}


export function createTestBenchPrompt() {
    scheduleBackup();
    let s = `
    <p>Enter the Test JSON: <input id='testJSON' type='text'  placeHolder='{"type": "comb", ...}'></p>
    `
    $('#testBench').dialog({
        resizable:false,
        width: 'auto',
        buttons: [
            {
                text: 'Run All',
                click() {
                    const testJSON = $("#testJSON").val();
                    runTestBench(JSON.parse(testJSON), globalScope, MODE.MODE_RUNALL, CONTEXT.CONTEXT_SIMULATOR)
                },
            },

            {
                text: 'Run Manually',
                click() {
                    const testJSON = $("#testJSON").val();
                    runTestBench(JSON.parse(testJSON), globalScope, MODE.MODE_MANUAL, CONTEXT.CONTEXT_SIMULATOR)
                },
            }
        ],
    });

    $("#testBench").empty();
    $("#testBench").append(s);
}

/**
 * Interface function to run testbench. Called by testbench prompt on simulator or assignments
 * @param {Object} data - Object containing Test Data
 * @param {Mode=} mode - To run all tests automatically or let user manually control tests
 * @param {RunContext=} runContext - Whether simulator or Assignment called this function
 * @param {Scope=} scope - the circuit
 */
export function runTestBench(data, scope=globalScope, mode=MODE.MODE_RUNALL, runContext=CONTEXT.CONTEXT_SIMULATOR) {
    if(mode === MODE.MODE_MANUAL && runContext === CONTEXT.CONTEXT_ASSIGNMENTS){
        // Assignment does not support MANUAL mode
        return
    }
    const isValidData = validate(data, scope)
    if(isValidData.status != "ok") return console.log(isValidData);
    const results = runAll(data, scope);
    console.log(results);
}

/**
 * Run all the tests automatically. Called by runTestBench()
 * @param {Object} data - Object containing Test Data
 * @param {Scope=} scope - the circuit
 */
function runAll(data, scope) {
    // Stop the clocks it's amazing
    // TestBench will now take over clock toggling
    simulationArea.clockEnabled = false;

    let copyScope = scope;
    let { inputs, outputs, clock, reset } = bindIO(data, copyScope);
    for(const group of data.groups){
        for(const output of group.outputs) output.results = [];
        for(let case_i = 0; case_i < group.n; case_i++){
            for(const input of group.inputs){
                inputs[input.label].state = parseInt(input.values[case_i], 2);
            }
            // Simulate without rendering
            play(copyScope)
            // Put results in the data
            for(const dataOutput of group.outputs){
                // Using node value because output state only changes on rendering
                dataOutput.results.push(outputs[dataOutput.label].nodeList[0].value);
            }

        }
    }

    // Tests done, restart the clock
    simulationArea.clockEnabled = true;

    // Return results
    return data;
}

/**
 * Validate if all inputs and output elements are present with correct bitwidths
 * Called by runTestBench()
 * @param {Object} data - Object containing Test Data
 * @param {Scope=} scope - the circuit
 */
function validate(data, scope=globalScope) {
    if(!checkDistinctIdentifiers(data)) return { status: "fail", message: "Duplicate identifiers" };
    for(let dataIO of data.groups[0].inputs.concat(data.groups[0].outputs)){
        const matchIO = scope.Input.concat(scope.Output).some(function(simulatorIO) {
            // TODO: label to identifier
            return simulatorIO.label === dataIO.label && simulatorIO.bitWidth === dataIO.bitWidth;
        });

        if(!matchIO) return { status: "fail", message: "Some inputs/outputs not present in circuit or wrong bitwidths" };
    }

    // Validate presence of clock and reset if test is sequential
    if(data.type === "seq"){
        const clockPresent = scope.Clock.some(function(simulatorClock) { return simulatorClock.label === "CLK" });
        const resetPresent = scope.Input.some(function(simulatorReset) { return simulatorReset.label === "RST" });

        if(!(clockPresent && resetPresent)) return {status: "fail", message: "Reset/Clock not present in circuit"};
    }

    return { status: "ok" };
}

/**
 * Checks if all the labels in the test are unique. Called by validate()
 * @param {Object} data - Object containing Test Data
 */
function checkDistinctIdentifiers(data) {
    const input_identifers = data.groups[0].inputs.map(function(input) { return input.label });
    const output_identifiers = data.groups[0].outputs.map(function(output) { return output.label });
    const identifiers = input_identifers.concat(output_identifiers);

    return (new Set(identifiers)).size === identifiers.length;
}

/**
 * Returns object of scope inputs and outputs keyed by their labels
 * @param {Scope=} scope - the circuit
 */
function bindIO(data, scope) {
    let inputs = {};
    let outputs = {};
    let clock, reset;
    for(const dataInput of data.groups[0].inputs){
        inputs[dataInput.label] = scope.Input.find(function(simulatorInput) {
            return simulatorInput.label === dataInput.label
        });
    }

    for(const dataOutput of data.groups[0].outputs){
        outputs[dataOutput.label] = scope.Output.find(function(simulatorOutput) {
            return simulatorOutput.label === dataOutput.label
        });
    }

    if(data.type === "seq"){
        clock = scope.Clock.find(function(simulatorOutput) {
            return simulatorOutput.label === "CLK"
        });

        reset = scope.Input.find(function(simulatorOutput) {
            return simulatorOutput.label === "RST"
        });
    }

    return { inputs: inputs, outputs: outputs, clock: clock, reset: reset };
}

/**
 * Creates deep clone of scope given to the function
 * @param {Scope} scope - the scope to be cloned
 */
function cloneScope(scope) {
    const copy = JSON.parse(generateSaveData("copyScope"));
    const copyScopeData = copy.scopes.find(function(dataScope) { return dataScope.id == scope.id })
    let copyScope =  new Scope("copyScope");
    loadScope(copyScope, copyScopeData);
    return copyScope;
}