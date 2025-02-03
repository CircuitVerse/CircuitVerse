/**
 * @jest-environment jsdom
 */

import CodeMirror from 'codemirror';
import { setup } from '../src/setup';
import load from '../src/data/load';
import circuitData from './circuits/misc-circuitdata.json';
import testData from './testData/misc-testdata.json';
import { runAll } from '../src/testbench';

jest.mock('codemirror');

describe('Simulator Misc-Elements Testing', () => {
    CodeMirror.fromTextArea.mockReturnValueOnce({ setValue: (text) => {} });
    setup();

    test('load circuitData', () => {
        expect(() => load(circuitData)).not.toThrow();
    });

    test('ALU working', () => {
        const result = runAll(testData.ALU);
        expect(result.summary.passed).toBe(28);
    });

    test('Adder working', () => {
        const result = runAll(testData.Adder);
        expect(result.summary.passed).toBe(8);
    });

    test('Buffer working', () => {
        const result = runAll(testData.buffer);
        expect(result.summary.passed).toBe(2);
    });

    test('TriState Buffer working', () => {
        const result = runAll(testData.Tristate);
        expect(result.summary.passed).toBe(4);
    });

    test('Tunnel working', () => {
        const result = runAll(testData.Tunnel);
        expect(result.summary.passed).toBe(2);
    });

    test("2's Compliment working", () => {
        const result = runAll(testData.comp);
        expect(result.summary.passed).toBe(8);
    });

    test('Controlled Inverter working', () => {
        const result = runAll(testData.ControlledInverter);
        expect(result.summary.passed).toBe(3);
    });

    test('Equal Splitter working', () => {
        const result = runAll(testData.SplitterEqual);
        expect(result.summary.passed).toBe(8);
    });

    test('UnEqual Splitter working', () => {
        const result = runAll(testData.SplitterUnEqual);
        expect(result.summary.passed).toBe(8);
    });

    test('Force Gate working', () => {
        const result = runAll(testData.ForceGate);
        expect(result.summary.passed).toBe(2);
    });
});
