/**
 * @jest-environment jsdom
 */

import CodeMirror from 'codemirror';
import { setup } from '../../src/setup';
import load from '../../src/data/load';
import circuitData from '../circuits/xnorGate.json';
import testData from '../testData/gate.json';
import { runAll } from '../../src/testbench';

jest.mock('codemirror');
describe('Xnor Gate Testing', () => {
    CodeMirror.fromTextArea.mockReturnValueOnce({ setValue: (text) => {} });
    setup();
    test('load circuitData', () => {
        expect(() => load(circuitData)).not.toThrow();
    });
    test('Run All tests', () => {
        const result = runAll(testData.xnorGate, globalScope);
        expect(result.summary.passed).toBe(4);
    });
});
