/**
 * @jest-environment jsdom
 */

import CodeMirror from 'codemirror';
import { setup } from '../src/setup';
import { YosysJSON2CV } from '../src/Verilog2CV';
import yosysTypeMap from '../src/VerilogClasses';
import Input from '../src/modules/Input';
import Tunnel from '../src/modules/Tunnel';
import Node, { propagateBitWidth } from '../src/node';
import { scopeList, newCircuit, deleteCurrentCircuit } from '../src/circuit';

jest.mock('codemirror');

describe('Verilog Import and Synthesis Fixes', () => {
    CodeMirror.fromTextArea.mockReturnValueOnce({ setValue: () => {} });
    setup();

    test('verilogInput keeps clk and clock as Input element and retains port label', () => {
        const clkGate = new yosysTypeMap.Input({ net: 'clk', bits: 1 });
        expect(clkGate.element).toBeInstanceOf(Input);
        expect(clkGate.element.label).toBe('clk');

        const clockGate = new yosysTypeMap.Input({ net: 'clock', bits: 1 });
        expect(clockGate.element).toBeInstanceOf(Input);
        expect(clockGate.element.label).toBe('clock');
    });

    test('verilogUnaryGate / getBitWidth handles array of net IDs correctly', () => {
        // DigitalJS netlist array of net IDs [5, 6, 26, 27, 28, 29, 30, 31] represents an 8-bit bus
        const input8Bit = new yosysTypeMap.Input({ net: 'data_in', bits: [5, 6, 26, 27, 28, 29, 30, 31] });
        expect(input8Bit.bitWidth).toBe(8);
        expect(input8Bit.element.bitWidth).toBe(8);

        // Single net ID [582] represents a 1-bit signal
        const input1Bit = new yosysTypeMap.Input({ net: 'flag', bits: [582] });
        expect(input1Bit.bitWidth).toBe(1);
        expect(input1Bit.element.bitWidth).toBe(1);

        // Integer width 32 represents a 32-bit bus
        const input32Bit = new yosysTypeMap.Input({ net: 'word', bits: 32 });
        expect(input32Bit.bitWidth).toBe(32);
    });

    test('comparator gates connect inputs in correct order to ALU', () => {
        const dummyDevice = {
            bits: { in1: 8, in2: 8, out: 1 },
        };

        // LtGate (A < B): in1 -> inp1 (A), in2 -> inp2 (B)
        const lt = new yosysTypeMap.Lt(dummyDevice);
        expect(lt.alu.inp1.connections).toContain(lt.in1Splitter.inp1);
        expect(lt.alu.inp2.connections).toContain(lt.in2Splitter.inp1);

        // GtGate (A > B <=> B < A): in1 -> inp2 (B), in2 -> inp1 (A)
        const gt = new yosysTypeMap.Gt(dummyDevice);
        expect(lt.alu.inp1.connections).not.toContain(gt.in1Splitter.inp1);
        expect(gt.alu.inp2.connections).toContain(gt.in1Splitter.inp1);
        expect(gt.alu.inp1.connections).toContain(gt.in2Splitter.inp1);

        // GeGate (A >= B <=> !(A < B)): in1 -> inp1 (A), in2 -> inp2 (B), notGate on output
        const ge = new yosysTypeMap.Ge(dummyDevice);
        expect(ge.alu.inp1.connections).toContain(ge.in1Splitter.inp1);
        expect(ge.alu.inp2.connections).toContain(ge.in2Splitter.inp1);
        expect(ge.notGate).toBeDefined();

        // LeGate (A <= B <=> !(B < A)): in1 -> inp2 (B), in2 -> inp1 (A), notGate on output
        const le = new yosysTypeMap.Le(dummyDevice);
        expect(le.alu.inp2.connections).toContain(le.in1Splitter.inp1);
        expect(le.alu.inp1.connections).toContain(le.in2Splitter.inp1);
        expect(le.notGate).toBeDefined();
    });

    test('verilogAdditionGate handles outBitWidth <= bitWidth gracefully', () => {
        // outBitWidth == bitWidth
        const addSame = new yosysTypeMap.Addition({ bits: { in1: 8, in2: 8, out: 8 } });
        expect(addSame.output).toBe(addSame.adder.sum);

        // outBitWidth == bitWidth + 1
        const addWider = new yosysTypeMap.Addition({ bits: { in1: 8, in2: 8, out: 9 } });
        expect(addWider.outputSplitter).toBeDefined();

        // outBitWidth < bitWidth
        const addNarrower = new yosysTypeMap.Addition({ bits: { in1: 8, in2: 8, out: 4 } });
        expect(addNarrower.outputSplitter).toBeDefined();

        // outBitWidth > bitWidth + 1 (e.g. 4-bit addition with 8-bit output)
        const addMuchWider = new yosysTypeMap.Addition({ bits: { in1: 4, in2: 4, out: 8 } });
        expect(addMuchWider.outputSplitter).toBeDefined();
        expect(addMuchWider.zeroConstant).toBeDefined();
        expect(addMuchWider.zeroConstant.state).toBe('000');
        expect(addMuchWider.outputSplitter.bitWidthSplit).toEqual([4, 1, 3]);
        expect(addMuchWider.outputSplitter.outputs[2].connections)
            .toContain(addMuchWider.zeroConstant.output1);
        expect(addMuchWider.output.bitWidth).toBe(8);
    });

    test('YosysJSON2CV tracks subcircuit scopes in rootScope.verilogMetadata.subCircuitScopeIds', () => {
        const rootScope = globalScope;
        rootScope.verilogMetadata.subCircuitScopeIds = [];

        const mockYosysJSON = {
            name: 'top_module',
            subcircuits: {
                sub_mod: {
                    name: 'sub_mod',
                    devices: {
                        inp: { type: 'Input', net: 'in_sig', bits: 1 },
                        outp: { type: 'Output', net: 'out_sig', bits: 1 },
                    },
                    connectors: [
                        {
                            from: { id: 'inp', port: 'out' },
                            to: { id: 'outp', port: 'in' },
                        },
                    ],
                },
            },
            devices: {
                sub1: { type: 'Subcircuit', celltype: 'sub_mod' },
            },
            connectors: [],
        };

        YosysJSON2CV(mockYosysJSON, rootScope, 'top_module', {}, true, rootScope);
        expect(rootScope.verilogMetadata.subCircuitScopeIds.length).toBe(1);
        const subId = rootScope.verilogMetadata.subCircuitScopeIds[0];
        expect(scopeList[subId]).toBeDefined();

        // Clean up created scopes
        rootScope.verilogMetadata.subCircuitScopeIds.forEach((id) => {
            delete scopeList[id];
        });
        rootScope.verilogMetadata.subCircuitScopeIds = [];
    });

    test('Tunnel identifier maxlength allows long identifiers', () => {
        expect(parseInt(Tunnel.prototype.mutableProperties.identifier.maxlength, 10)).toBeGreaterThanOrEqual(50);
    });

    test('Tunnel setIdentifier synchronizes bitWidth and propagates across intermediate wire nodes', () => {
        const t1 = new Tunnel(0, 0, globalScope, 'LEFT', 8, 'BUS_SIG');
        const t2 = new Tunnel(100, 0, globalScope, 'RIGHT', 1, 'OTHER_SIG');
        const inter = new Node(120, 0, 2, globalScope.root, 1);
        t2.inp1.connect(inter);

        expect(t2.bitWidth).toBe(1);
        expect(inter.bitWidth).toBe(1);

        t2.setIdentifier('BUS_SIG');
        expect(t2.bitWidth).toBe(8);
        expect(t2.inp1.bitWidth).toBe(8);
        expect(inter.bitWidth).toBe(8);

        t1.delete();
        t2.delete();
    });

    test('propagateBitWidth propagates bitWidth across intermediate wire nodes', () => {
        const n1 = new Node(0, 0, 0, globalScope.root, 1);
        const inter1 = new Node(10, 0, 2, globalScope.root, 1);
        const inter2 = new Node(20, 0, 2, globalScope.root, 1);
        const n2 = new Node(30, 0, 1, globalScope.root, 1);

        n1.connect(inter1);
        inter1.connect(inter2);
        inter2.connect(n2);

        expect(inter1.bitWidth).toBe(1);
        expect(inter2.bitWidth).toBe(1);

        propagateBitWidth(n1, 8);
        expect(n1.bitWidth).toBe(8);
        expect(inter1.bitWidth).toBe(8);
        expect(inter2.bitWidth).toBe(8);
    });

    test('deleteCurrentCircuit prevents deleting the last visible circuit when it has subcircuits', () => {
        const mainScope = newCircuit('MainVerilogCircuit', undefined, true, true);
        const subScope = newCircuit('SubModule', undefined, true, false);
        mainScope.verilogMetadata.subCircuitScopeIds = [subScope.id];

        const originalScopeList = { ...scopeList };
        Object.keys(scopeList).forEach((id) => {
            if (String(id) !== String(mainScope.id) && String(id) !== String(subScope.id)) {
                delete scopeList[id];
            }
        });

        deleteCurrentCircuit(mainScope.id);

        expect(scopeList[mainScope.id]).toBeDefined();
        expect(scopeList[subScope.id]).toBeDefined();

        Object.assign(scopeList, originalScopeList);
        delete scopeList[mainScope.id];
        delete scopeList[subScope.id];
    });

    test('deleteCurrentCircuit deletes main Verilog circuit and its generated subcircuits when another circuit exists', () => {
        const extraScope = newCircuit('ExtraCircuit');
        const mainScope = newCircuit('MainVerilogCircuit', undefined, true, true);
        const subScope = newCircuit('SubModule', undefined, true, false);
        mainScope.verilogMetadata.subCircuitScopeIds = [subScope.id];

        window.confirm = () => true;

        deleteCurrentCircuit(mainScope.id);

        expect(scopeList[mainScope.id]).toBeUndefined();
        expect(scopeList[subScope.id]).toBeUndefined();
        expect(scopeList[extraScope.id]).toBeDefined();

        delete scopeList[extraScope.id];
    });
});
