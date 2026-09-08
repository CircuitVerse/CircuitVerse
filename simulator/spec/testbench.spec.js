import { setup } from '../src/setup';
import { TestbenchData } from '../src/testbench';

describe('TestbenchData', () => {
    const sampleTestData = {
        type: 'comb',
        groups: [
            {
                n: 2,
                inputs: [{ label: 'A', values: ['0', '1'] }],
                outputs: [{ label: 'X', values: ['0', '1'] }],
            },
            {
                n: 3,
                inputs: [{ label: 'A', values: ['0', '1', '0'] }],
                outputs: [{ label: 'X', values: ['1', '0', '1'] }],
            },
        ],
    };

    describe('constructor and basic initialization', () => {
        test('initializes default group and case to 0', () => {
            const tb = new TestbenchData(sampleTestData);
            expect(tb.currentGroup).toBe(0);
            expect(tb.currentCase).toBe(0);
            expect(tb.testData).toBe(sampleTestData);
        });

        test('initializes explicit group and case indices', () => {
            const tb = new TestbenchData(sampleTestData, 1, 2);
            expect(tb.currentGroup).toBe(1);
            expect(tb.currentCase).toBe(2);
        });
    });

    describe('caseCount', () => {
        test('returns the correct case count for the current group', () => {
            const tb = new TestbenchData(sampleTestData, 0, 0);
            expect(tb.caseCount()).toBe(2);
        });

        test('returns the correct case count for an explicit group index', () => {
            const tb = new TestbenchData(sampleTestData, 0, 0);
            expect(tb.caseCount(1)).toBe(3);
        });

        test('returns 0 for non-existent group or empty inputs', () => {
            const tb = new TestbenchData(sampleTestData);
            expect(tb.caseCount(5)).toBe(0);
            expect(tb.caseCount(-1)).toBe(0);

            const emptyGroupData = { type: 'comb', groups: [{ n: 0, inputs: [], outputs: [] }] };
            const tbEmpty = new TestbenchData(emptyGroupData);
            expect(tbEmpty.caseCount(0)).toBe(0);
        });

        test('returns 0 when testData is empty or missing groups', () => {
            const tb = new TestbenchData({ type: 'comb', groups: [] });
            expect(tb.caseCount()).toBe(0);
        });
    });

    describe('isCaseValid', () => {
        test('returns true for existing case in group', () => {
            const tb = new TestbenchData(sampleTestData, 0, 1);
            expect(tb.isCaseValid()).toBe(true);

            const tb2 = new TestbenchData(sampleTestData, 1, 2);
            expect(tb2.isCaseValid()).toBe(true);
        });

        test('returns false when case index is out of bounds', () => {
            const tb = new TestbenchData(sampleTestData, 0, 2);
            expect(tb.isCaseValid()).toBe(false);
        });

        test('returns false when group index is out of bounds or negative', () => {
            const tb = new TestbenchData(sampleTestData, 2, 0);
            expect(tb.isCaseValid()).toBe(false);

            const tbNegative = new TestbenchData(sampleTestData, -1, 0);
            expect(tbNegative.isCaseValid()).toBe(false);
        });

        test('returns false when case index is negative', () => {
            const tb = new TestbenchData(sampleTestData, 0, -1);
            expect(tb.isCaseValid()).toBe(false);
        });

        test('returns false when testData has no groups', () => {
            const tb = new TestbenchData({ type: 'comb', groups: [] }, 0, 0);
            expect(tb.isCaseValid()).toBe(false);
        });
    });

    describe('setCase', () => {
        test('sets group and case when valid and returns true', () => {
            const tb = new TestbenchData(sampleTestData, 0, 0);
            const result = tb.setCase(1, 2);
            expect(result).toBe(true);
            expect(tb.currentGroup).toBe(1);
            expect(tb.currentCase).toBe(2);
        });

        test('does not change state and returns false when setting invalid case or group', () => {
            const tb = new TestbenchData(sampleTestData, 0, 1);
            const result = tb.setCase(0, 5);
            expect(result).toBe(false);
            expect(tb.currentGroup).toBe(0);
            expect(tb.currentCase).toBe(1);

            const invalidGroupResult = tb.setCase(3, 0);
            expect(invalidGroupResult).toBe(false);
            expect(tb.currentGroup).toBe(0);
            expect(tb.currentCase).toBe(1);
        });
    });

    describe('caseNext and casePrev navigation', () => {
        test('caseNext advances within the current group', () => {
            const tb = new TestbenchData(sampleTestData, 0, 0);
            expect(tb.caseNext()).toBe(true);
            expect(tb.currentCase).toBe(1);
            expect(tb.currentGroup).toBe(0);
        });

        test('caseNext transitions to the next group when at the end of current group', () => {
            const tb = new TestbenchData(sampleTestData, 0, 1);
            expect(tb.caseNext()).toBe(true);
            expect(tb.currentGroup).toBe(1);
            expect(tb.currentCase).toBe(0);
        });

        test('caseNext returns false when at the last case of the last group', () => {
            const tb = new TestbenchData(sampleTestData, 1, 2);
            expect(tb.caseNext()).toBe(false);
            expect(tb.currentGroup).toBe(1);
            expect(tb.currentCase).toBe(2);
        });

        test('casePrev goes to the previous case within the current group', () => {
            const tb = new TestbenchData(sampleTestData, 0, 1);
            expect(tb.casePrev()).toBe(true);
            expect(tb.currentCase).toBe(0);
            expect(tb.currentGroup).toBe(0);
        });

        test('casePrev transitions to the last case of the previous group when at index 0', () => {
            const tb = new TestbenchData(sampleTestData, 1, 0);
            expect(tb.casePrev()).toBe(true);
            expect(tb.currentGroup).toBe(0);
            expect(tb.currentCase).toBe(1);
        });

        test('casePrev returns false when at the very first case of the first group', () => {
            const tb = new TestbenchData(sampleTestData, 0, 0);
            expect(tb.casePrev()).toBe(false);
            expect(tb.currentGroup).toBe(0);
            expect(tb.currentCase).toBe(0);
        });
    });

    describe('groupNext and groupPrev with empty groups', () => {
        const multiGroupDataWithEmpty = {
            type: 'comb',
            groups: [
                {
                    n: 1,
                    inputs: [{ label: 'A', values: ['0'] }],
                    outputs: [{ label: 'X', values: ['1'] }],
                },
                {
                    n: 0,
                    inputs: [],
                    outputs: [],
                },
                {
                    n: 2,
                    inputs: [{ label: 'A', values: ['0', '1'] }],
                    outputs: [{ label: 'X', values: ['0', '1'] }],
                },
            ],
        };

        test('groupNext skips over empty groups', () => {
            const tb = new TestbenchData(multiGroupDataWithEmpty, 0, 0);
            expect(tb.groupNext()).toBe(true);
            expect(tb.currentGroup).toBe(2);
            expect(tb.currentCase).toBe(0);
        });

        test('groupNext returns false when no further valid groups exist', () => {
            const tb = new TestbenchData(multiGroupDataWithEmpty, 2, 0);
            expect(tb.groupNext()).toBe(false);
            expect(tb.currentGroup).toBe(2);
        });

        test('groupPrev skips over empty groups in reverse', () => {
            const tb = new TestbenchData(multiGroupDataWithEmpty, 2, 0);
            expect(tb.groupPrev()).toBe(true);
            expect(tb.currentGroup).toBe(0);
            expect(tb.currentCase).toBe(0);
        });

        test('groupPrev returns false when no previous valid groups exist', () => {
            const tb = new TestbenchData(multiGroupDataWithEmpty, 0, 0);
            expect(tb.groupPrev()).toBe(false);
            expect(tb.currentGroup).toBe(0);
        });
    });

    describe('goToFirstValidGroup', () => {
        test('stays at group 0 if group 0 is non-empty', () => {
            const tb = new TestbenchData(sampleTestData, 1, 1);
            expect(tb.goToFirstValidGroup()).toBe(true);
            expect(tb.currentGroup).toBe(0);
            expect(tb.currentCase).toBe(0);
        });

        test('skips leading empty groups to find first valid group', () => {
            const leadingEmptyData = {
                type: 'comb',
                groups: [
                    { n: 0, inputs: [], outputs: [] },
                    {
                        n: 1,
                        inputs: [{ label: 'A', values: ['1'] }],
                        outputs: [{ label: 'X', values: ['0'] }],
                    },
                ],
            };
            const tb = new TestbenchData(leadingEmptyData);
            expect(tb.goToFirstValidGroup()).toBe(true);
            expect(tb.currentGroup).toBe(1);
            expect(tb.currentCase).toBe(0);
        });

        test('returns false when all groups are empty', () => {
            const allEmptyData = {
                type: 'comb',
                groups: [
                    { n: 0, inputs: [], outputs: [] },
                    { n: 0, inputs: [], outputs: [] },
                ],
            };
            const tb = new TestbenchData(allEmptyData);
            expect(tb.goToFirstValidGroup()).toBe(false);
        });

        test('returns false when groups array is empty', () => {
            const emptyData = { type: 'comb', groups: [] };
            const tb = new TestbenchData(emptyData);
            expect(tb.goToFirstValidGroup()).toBe(false);
        });
    });
});
