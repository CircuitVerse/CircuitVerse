/**
 * @jest-environment jsdom
 */

import CodeMirror from 'codemirror'
import { setup } from '../src/setup'

import load from '../src/data/load'
import circuitData from './circuits/gates-circuitdata.json'
import testData from './testData/gates-testdata.json'
import { runAll } from '#/simulator/src/testbench'

jest.mock('codemirror')

describe('Simulator Gates Testing', () => {
    CodeMirror.fromTextArea.mockReturnValueOnce({ setValue: (text) => {} })
    setup()

    test('load circuitData', () => {
        expect(() => load(circuitData)).not.toThrow()
    })

    test('AND gate testing', () => {
        const result = runAll(testData.AndGate)
        expect(result.summary.passed).toBe(4)
    })

    test('NAND gate testing', () => {
        const result = runAll(testData.nandGate)
        expect(result.summary.passed).toBe(4)
    })

    test('NOR gate testing', () => {
        const result = runAll(testData.norGate)
        expect(result.summary.passed).toBe(4)
    })

    test('NOT gate testing', () => {
        const result = runAll(testData.notGate)
        expect(result.summary.passed).toBe(2)
    })

    test('OR gate testing', () => {
        const result = runAll(testData.OrGate)
        expect(result.summary.passed).toBe(4)
    })

    test('XNOR gate testing', () => {
        const result = runAll(testData.xnorGate)
        expect(result.summary.passed).toBe(4)
    })

    test('XOR gate testing', () => {
        const result = runAll(testData.xorGate)
        expect(result.summary.passed).toBe(4)
    })
})
