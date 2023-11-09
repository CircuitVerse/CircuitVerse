/**
 * @jest-environment jsdom
 */

import CodeMirror from 'codemirror';
import { setup } from '../src/setup';
import load from '../src/data/load';
import circuitData from './circuits/subCircuit-circuitdata.json';
import { runAll } from '../src/testbench';
import testData from './testData/subCircuit-testdata.json';

jest.mock('codemirror');
describe('SubCircuit Testing', () => {
    CodeMirror.fromTextArea.mockReturnValueOnce({ setValue: (text) => {} });
    setup();

    test('load subCircuit data without throwing error', () => {
        expect(() => load(circuitData)).not.toThrow();
    });

    test('subCircuit working', () => {
        const result = runAll(testData.subCircuit);
        expect(result.summary.passed).toBe(8);
    });
});
