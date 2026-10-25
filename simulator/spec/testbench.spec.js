/**
 * @jest-environment jsdom
 */

import { TestbenchData } from '../src/testbench';

const sampleTestData = {
    type: 'comb',
    groups: [
        {
            n: 2,
            inputs: [{ label: 'A', values: ['0', '1'] }],
            outputs: [{ label: 'X', values: ['0', '1'] }],
        },
    ],
};

describe('TestbenchData navigation', () => {
    test('isCaseValid does not throw and validates the current case', () => {
        const tb = new TestbenchData(sampleTestData, 0, 0);
        expect(() => tb.isCaseValid()).not.toThrow();
        expect(tb.isCaseValid()).toBe(true);
    });

    test('isCaseValid rejects out of range group and case', () => {
        expect(new TestbenchData(sampleTestData, 1, 0).isCaseValid()).toBe(false);
        expect(new TestbenchData(sampleTestData, 0, 5).isCaseValid()).toBe(false);
    });

    test('setCase updates position for a valid case and rejects an invalid one', () => {
        const tb = new TestbenchData(sampleTestData, 0, 0);
        expect(tb.setCase(0, 1)).toBe(true);
        expect(tb.currentCase).toBe(1);
        expect(tb.setCase(0, 9)).toBe(false);
        expect(tb.currentCase).toBe(1);
    });

    test('goToFirstValidGroup inspects the first group regardless of current group', () => {
        const tb = new TestbenchData(sampleTestData, 3, 0);
        expect(() => tb.goToFirstValidGroup()).not.toThrow();
        expect(tb.goToFirstValidGroup()).toBe(true);
    });
});
