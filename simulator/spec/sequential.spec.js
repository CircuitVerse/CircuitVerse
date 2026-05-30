/**
 * @jest-environment jsdom
 */

import CodeMirror from 'codemirror';
import { setup } from '../src/setup';
import load from '../src/data/load';
import circuitData from './circuits/sequential-circuitdata.json';
import testData from './testData/sequential-testdata.json';
import { runAll } from '../src/testbench';

jest.mock('codemirror');

describe('Simulator Sequential Element Testing', () => {
    CodeMirror.fromTextArea.mockReturnValueOnce({ setValue: (text) => {} });
    setup();
    test('load circuitData', () => {
        expect(() => load(circuitData)).not.toThrow();
    });

    test('D Flip Flop working', () => {
        const result = runAll(testData.DFlipFlop);
        expect(result.summary.passed).toBe(2);
    });

    test('D latch working', () => {
        const result = runAll(testData.DLatch);
        expect(result.summary.passed).toBe(2);
    });

    test('JK Flip Flop working', () => {
        const result = runAll(testData.JkFlipFlop);
        expect(result.summary.passed).toBe(4);
    });

    test('SR Flip Flop working', () => {
        const result = runAll(testData.SRFlipFlop);
        expect(result.summary.passed).toBe(4);
    });

    test('T Flip Flop working', () => {
        const result = runAll(testData.TFlipFlop);
        expect(result.summary.passed).toBe(4);
    });
});
