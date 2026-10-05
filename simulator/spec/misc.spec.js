/**
 * @jest-environment jsdom
 */

import CodeMirror from 'codemirror';
import { setup } from '../src/setup';
import load from '../src/data/load';
import circuitData from './circuits/misc-circuitdata.json';
import testData from './testData/misc-testdata.json';
import { runAll } from '../src/testbench';

import Adder from '../src/modules/Adder';
import ALU from '../src/modules/ALU';

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

    test('Adder 32-bit and 8-bit carry-out behavior', () => {
        const adder = new Adder(0, 0, globalScope, 'RIGHT', 32);
        adder.inpA.value = 0xFFFFFFFF;
        adder.inpB.value = 1;
        adder.carryIn.value = 0;
        adder.resolve();
        expect(adder.sum.value).toBe(0);
        expect(adder.carryOut.value).toBe(1);

        adder.inpA.value = 0x12345678;
        adder.inpB.value = 0x11111111;
        adder.carryIn.value = 0;
        adder.resolve();
        expect(adder.sum.value).toBe(0x23456789);
        expect(adder.carryOut.value).toBe(0);

        adder.newBitWidth(8);
        adder.inpA.value = 255;
        adder.inpB.value = 1;
        adder.carryIn.value = 0;
        adder.resolve();
        expect(adder.sum.value).toBe(0);
        expect(adder.carryOut.value).toBe(1);
    });

    test('ALU 32-bit and 8-bit addition carry-out behavior', () => {
        const alu = new ALU(0, 0, globalScope, 'RIGHT', 32);
        alu.controlSignalInput.value = 2;
        alu.inp1.value = 0xFFFFFFFF;
        alu.inp2.value = 1;
        alu.resolve();
        expect(alu.output.value).toBe(0);
        expect(alu.carryOut.value).toBe(1);

        alu.inp1.value = 0x12345678;
        alu.inp2.value = 0x11111111;
        alu.resolve();
        expect(alu.output.value).toBe(0x23456789);
        expect(alu.carryOut.value).toBe(0);

        alu.newBitWidth(8);
        alu.inp1.value = 255;
        alu.inp2.value = 1;
        alu.resolve();
        expect(alu.output.value).toBe(0);
        expect(alu.carryOut.value).toBe(1);
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
