/**
 * @jest-environment jsdom
 */

import CodeMirror from 'codemirror';
import { setup } from '../src/setup';
import { runAll } from '../src/testbench';
import testData from './testData/gates-testdata.json';
import { createCombinationalAnalysisPrompt, GenerateCircuit, performCombinationalAnalysis } from '../src/combinationalAnalysis';

jest.mock('codemirror');
describe('Combinational Analysis Testing', () => {
    CodeMirror.fromTextArea.mockReturnValueOnce({ setValue: (text) => {} });
    setup();

    test('performCombinationalAnalysis function working', () => {
        expect(() => performCombinationalAnalysis('', '', 'AB')).not.toThrow();
    });

    test('Generating Circuit', () => {
        expect(() => GenerateCircuit([13], ['A', 'B'], [0, 0, 0, 1], 'AB')).not.toThrow();
    });

    test('testing Combinational circuit', () => {
        testData.AndGate.groups[0].inputs[0].label = 'A';
        testData.AndGate.groups[0].inputs[1].label = 'B';
        testData.AndGate.groups[0].outputs[0].label = 'AB';

        const result = runAll(testData.AndGate);
        expect(result.summary.passed).toBe(4);
    });
});
