/**
 * @jest-environment jsdom
 */

import CodeMirror from 'codemirror';
import { setup } from '../src/setup';
import load from '../src/data/load';
import { runAll } from '../src/testbench';
import aluCircuitData from './circuits/alu-circuitdata.json';
import rippleCircuitData from './circuits/rippleCarryAdder-circuitdata.json';
import rippleTestData from './testData/ripple-carry-adder.json';
import aluTestData from './testData/alu-testdata.json';

jest.mock('codemirror');
describe('data dir working', () => {
    CodeMirror.fromTextArea.mockReturnValueOnce({ setValue: (text) => {} });
    setup();

    test('load ripple carry adder circuit-data', () => {
        expect(() => load(rippleCircuitData)).not.toThrow();
    });

    test('ripple carry adder circuit testing', () => {
        const result = runAll(rippleTestData.testData);
        expect(result.summary.passed).toBe(10);
    });

    test('load ALU circuit-data', () => {
        expect(() => load(aluCircuitData)).not.toThrow();
    });

    test('ALU circuit testing', () => {
        const result = runAll(aluTestData.testData);
        expect(result.summary.passed).toBe(5);
    });
});
