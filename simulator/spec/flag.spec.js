/**
 * @jest-environment jsdom
 */

import CodeMirror from 'codemirror';
import { setup } from '../src/setup';
import Flag from '../src/modules/Flag';
import simulationArea from '../src/simulationArea';
import plotArea from '../src/plotArea';

jest.mock('codemirror');

describe('Simulator Flag Testing', () => {
    CodeMirror.fromTextArea.mockReturnValueOnce({ setValue: () => {} });
    setup();

    test('Flag instantiates correctly', () => {
        const flag = new Flag(100, 100, globalScope, 'RIGHT', 1, 'F_TEST');
        expect(flag.identifier).toBe('F_TEST');
        expect(flag.inp1).toBeDefined();
        expect(flag.plotValues).toEqual([]);
    });

    test('Flag resolve() records plot value when input changes', () => {
        const flag = new Flag(100, 100, globalScope, 'RIGHT', 1, 'F1');
        flag.inp1.value = 1;
        flag.resolve();
        expect(flag.plotValues.length).toBe(1);
        expect(flag.plotValues[0][1]).toBe(1);
    });

    test('Flag resolve() does not duplicate consecutive same values', () => {
        const flag = new Flag(120, 120, globalScope, 'RIGHT', 1, 'F2');
        flag.inp1.value = 0;
        flag.resolve();
        const initialPlotTime = flag.plotValues[0][0];

        // Advance simulation time until plot time changes before second resolve()
        simulationArea.simulationQueue.time++;
        const newPlotTime = plotArea.getPlotTime(simulationArea.simulationQueue.time);
        expect(newPlotTime).not.toBe(initialPlotTime);

        flag.resolve();
        expect(flag.plotValues.length).toBe(1);
        expect(flag.plotValues[0][0]).toBe(initialPlotTime);

        // Verify that changing value at a new plot time appends
        simulationArea.simulationQueue.time++;
        flag.inp1.value = 1;
        flag.resolve();
        expect(flag.plotValues.length).toBe(2);
        expect(flag.plotValues[1][1]).toBe(1);
    });

    test('Flag setIdentifier updates identifier and adjusts xSize', () => {
        const flag = new Flag(140, 140, globalScope, 'RIGHT', 1, 'F3');
        flag.setIdentifier('A');
        expect(flag.identifier).toBe('A');
        expect(flag.xSize).toBe(20);

        flag.setIdentifier('ABC');
        expect(flag.identifier).toBe('ABC');
        expect(flag.xSize).toBe(10);

        flag.setIdentifier('ABCDE');
        expect(flag.identifier).toBe('ABCDE');
        expect(flag.xSize).toBe(0);

        // Empty string should not change identifier
        flag.setIdentifier('');
        expect(flag.identifier).toBe('ABCDE');
    });

    test('Flag newDirection updates direction and pin offset', () => {
        const flag = new Flag(160, 160, globalScope, 'RIGHT', 1, 'F4');
        flag.newDirection('UP');
        expect(flag.direction).toBe('UP');
        expect(flag.inp1.leftx).toBe(20);

        flag.newDirection('LEFT');
        expect(flag.direction).toBe('LEFT');
        expect(flag.inp1.leftx).toBe(50 - flag.xSize);
    });

    test('Flag customSave returns valid configuration object', () => {
        const flag = new Flag(180, 180, globalScope, 'RIGHT', 2, 'F5');
        const saveData = flag.customSave();
        expect(saveData.constructorParamaters).toEqual(['RIGHT', 2]);
        expect(saveData.values.identifier).toBe('F5');
        expect(saveData.nodes.inp1).toBeDefined();
    });

    test('Flag customDraw runs without error', () => {
        const flag = new Flag(200, 200, globalScope, 'RIGHT', 1, 'F6');
        flag.inp1.value = 1;
        expect(() => flag.customDraw()).not.toThrow();

        flag.inp1.value = undefined;
        expect(() => flag.customDraw()).not.toThrow();
    });
});
