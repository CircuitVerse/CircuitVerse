/* eslint-disable import/no-cycle */
/* eslint-disable guard-for-in */
/* eslint-disable no-restricted-syntax */
import { scheduleBackup } from './data/backupCircuit'
import { SimulatorStore } from '#/store/SimulatorStore/SimulatorStore'

// var inputSample = 5
// var dataSample = [
//     ['01---', '11110', '01---', '00000'],
//     ['01110', '1-1-1', '----0'],
//     ['01---', '11110', '01110', '1-1-1', '0---0'],
//     ['----1'],
// ]

// var sampleInputListNames = ['A', 'B']
// var sampleOutputListNames = ['X']

/**
 * The prompt for combinational analysis
 * @param {Scope=} - the circuit in which we want combinational analysis
 * @category combinationalAnalysis
 */
export function createCombinationalAnalysisPrompt(scope = globalScope) {
    scheduleBackup()
    SimulatorStore().dialogBox.combinationalanalysis_dialog = true
}