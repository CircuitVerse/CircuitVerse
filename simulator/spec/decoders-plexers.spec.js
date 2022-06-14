/**
 * @jest-environment jsdom
 */

import CodeMirror from 'codemirror';
import { setup } from '../src/setup';
import load from '../src/data/load';
import circuitData from './circuits/Decoders-plexers-circuitdata.json';
import testData from './testData/decoders-plexers.json';
import { runAll } from '../src/testbench';

jest.mock('codemirror');

describe('Simulator Decoders and Plexers Testing', () => {
    CodeMirror.fromTextArea.mockReturnValueOnce({ setValue: (text) => {} });
    setup();

    test('load decoders-plexers circuitData', () => {
        expect(() => load(circuitData)).not.toThrow();
    });

    test('Multiplexer working', () => {
        const result = runAll(testData.Multiplexers);
        expect(result.summary.passed).toBe(8);
    });

    test('Demultiplexer working', () => {
        const result = runAll(testData.Demultiplexer);
        expect(result.summary.passed).toBe(4);
    });

    test('BitSelector working', () => {
        const result = runAll(testData['bit-selector']);
        expect(result.summary.passed).toBe(4);
    });

    test('MSB working', () => {
        const result = runAll(testData.msb);
        expect(result.summary.passed).toBe(5);
    });

    test('LSB working', () => {
        const result = runAll(testData.lsb);
        expect(result.summary.passed).toBe(10);
    });

    test('Priority Encoder working', () => {
        const result = runAll(testData['priority-encoder']);
        expect(result.summary.passed).toBe(4);
    });

    test('Decoder working', () => {
        const result = runAll(testData.Decoder);
        expect(result.summary.passed).toBe(2);
    });
});
