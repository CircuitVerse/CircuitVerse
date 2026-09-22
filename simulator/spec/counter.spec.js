/**
 * @jest-environment jsdom
 */

import CodeMirror from 'codemirror';
import { setup } from '../src/setup';
import load from '../src/data/load';
import circuitData from './circuits/counter-circuitdata.json';
import testData from './testData/counter-testdata.json';
import { runAll } from '../src/testbench';
import Counter from '../src/modules/Counter';

jest.mock('codemirror');

describe('Simulator Counter Testing', () => {
    CodeMirror.fromTextArea.mockReturnValueOnce({ setValue: () => {} });
    setup();

    test('load circuitData', () => {
        expect(() => load(circuitData)).not.toThrow();
    });

    test('Counter count-up working', () => {
        const result = runAll(testData.countUp);
        expect(result.summary.passed).toBe(4);
    });

    test('Counter wrap-around working', () => {
        const result = runAll(testData.countAndWrap);
        expect(result.summary.passed).toBe(4);
    });

    test('Counter unit methods: customDraw, isResolvable, newBitWidth, moduleVerilog', () => {
        const counter = new Counter(100, 100, globalScope, 4);
        expect(counter.isResolvable()).toBe(true);

        counter.newBitWidth(8);
        expect(counter.bitWidth).toBe(8);
        expect(counter.maxValue.bitWidth).toBe(8);
        expect(counter.output.bitWidth).toBe(8);

        // customDraw and subcircuitDraw
        expect(() => counter.customDraw()).not.toThrow();
        expect(() => counter.subcircuitDraw()).not.toThrow();

        // Verilog generation
        expect(Counter.moduleVerilog()).toContain('module Counter');
    });

    test('Counter reset and zero flag logic in resolve()', () => {
        const counter = new Counter(100, 100, globalScope, 4);
        counter.maxValue.value = 3;
        counter.clock.value = 1;
        counter.reset.value = 0;
        counter.resolve();
        expect(counter.value).toBe(1);

        // Reset pin
        counter.reset.value = 1;
        counter.resolve();
        expect(counter.value).toBe(0);

        // Zero flag with clock = 1 and value = 0
        expect(counter.zero.value).toBe(1);
    });
});
