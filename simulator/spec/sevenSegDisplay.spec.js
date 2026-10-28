/**
 * @jest-environment jsdom
 */

import CodeMirror from 'codemirror';
import { setup } from '../src/setup';
import load from '../src/data/load';
import circuitData from './circuits/sevenSegDisplay-circuitdata.json';
import testData from './testData/sevenSegDisplay-testdata.json';
import { play } from '../src/engine';
import SevenSegDisplay from '../src/modules/SevenSegDisplay';

jest.mock('codemirror');

function applyAndVerifyPattern(pattern) {
    Object.entries(pattern.segments).forEach(([label, val]) => {
        const inp = globalScope.Input.find((i) => i.label === label);
        inp.state = val;
    });
    play(globalScope);

    const disp = globalScope.SevenSegDisplay[0];
    expect(disp.a.value).toBe(pattern.segments.in_a);
    expect(disp.b.value).toBe(pattern.segments.in_b);
    expect(disp.c.value).toBe(pattern.segments.in_c);
    expect(disp.d.value).toBe(pattern.segments.in_d);
    expect(disp.e.value).toBe(pattern.segments.in_e);
    expect(disp.f.value).toBe(pattern.segments.in_f);
    expect(disp.g.value).toBe(pattern.segments.in_g);
    expect(disp.dot.value).toBe(pattern.segments.in_dot);
}

describe('Simulator SevenSegDisplay Testing', () => {
    CodeMirror.fromTextArea.mockReturnValueOnce({ setValue: () => {} });
    setup();

    beforeAll(() => {
        load(circuitData);
    });

    test('load circuitData', () => {
        expect(globalScope.SevenSegDisplay).toHaveLength(1);
    });

    test('SevenSegDisplay digit 0 pattern', () => {
        applyAndVerifyPattern(testData.digit0);
    });

    test('SevenSegDisplay digit 1 pattern', () => {
        applyAndVerifyPattern(testData.digit1);
    });

    test('SevenSegDisplay digit 8 pattern', () => {
        applyAndVerifyPattern(testData.digit8);
    });

    test('SevenSegDisplay all segments off pattern', () => {
        applyAndVerifyPattern(testData.allOff);
    });

    test('SevenSegDisplay changeColor and styling', () => {
        const disp = globalScope.SevenSegDisplay[0];
        disp.changeColor('Green');
        expect(disp.color).toBe('Green');

        disp.changeColor('Blue');
        expect(disp.color).toBe('Blue');
    });

    test('SevenSegDisplay customDraw and subcircuitDraw', () => {
        const disp = globalScope.SevenSegDisplay[0];
        expect(() => disp.customDraw()).not.toThrow();
        expect(() => disp.subcircuitDraw()).not.toThrow();
    });

    test('SevenSegDisplay generateVerilog and customSave', () => {
        const disp = globalScope.SevenSegDisplay[0];
        const verilog = disp.generateVerilog();
        expect(verilog).toContain('SevenSegDisplay');

        const saved = disp.customSave();
        expect(saved.constructorParamaters).toEqual([disp.color]);
        expect(saved.nodes.a).toBeDefined();
        expect(saved.nodes.g).toBeDefined();
    });
});
