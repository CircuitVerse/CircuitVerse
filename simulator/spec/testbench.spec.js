import { validateBinding, runAll } from '../src/testbench';
import { showMessage } from '../src/utils';

jest.mock('../src/data/backupCircuit', () => ({ scheduleBackup: jest.fn() }));
jest.mock('../src/sequential', () => ({ changeClockEnable: jest.fn() }));
jest.mock('../src/engine', () => ({ play: jest.fn() }));
jest.mock('../src/circuit', () => ({ __esModule: true, default: class {} }));
jest.mock('../src/utils', () => ({
    showMessage: jest.fn(),
    escapeHtml: (s) => s,
}));

const makeData = (type = 'comb') => ({
    type,
    groups: [{
        n: 1,
        inputs: [{ label: 'A', bitWidth: 1, values: ['0'] }],
        outputs: [{ label: 'Y', bitWidth: 1, values: ['0'] }],
    }],
});

const makeScope = ({ inputs = ['A'], outputs = ['Y'] } = {}) => ({
    Input: inputs.map((label) => ({ label, bitWidth: 1, state: 0 })),
    Output: outputs.map((label) => ({ label, bitWidth: 1, nodeList: [{ value: 0, bitWidth: 1 }] })),
    clockTick: jest.fn(),
});

describe('validateBinding', () => {
    beforeEach(() => jest.clearAllMocks());

    test('ok when all labels exist', () => {
        expect(validateBinding(makeData(), makeScope())).toEqual({ ok: true, missing: [] });
    });

    test('reports missing input', () => {
        const res = validateBinding(makeData(), makeScope({ inputs: [] }));
        expect(res).toEqual({ ok: false, missing: ['A'] });
    });

    test('reports missing output', () => {
        const res = validateBinding(makeData(), makeScope({ outputs: [] }));
        expect(res).toEqual({ ok: false, missing: ['Y'] });
    });

    test('trims labels with whitespace', () => {
        const data = makeData();
        data.groups[0].inputs[0].label = ' A ';
        expect(validateBinding(data, makeScope()).ok).toBe(true);
    });

    test('seq test without RST reports RST', () => {
        const res = validateBinding(makeData('seq'), makeScope());
        expect(res).toEqual({ ok: false, missing: ['RST'] });
    });

    test('seq test with RST is ok', () => {
        const res = validateBinding(makeData('seq'), makeScope({ inputs: ['A', 'RST'] }));
        expect(res.ok).toBe(true);
    });

    test('lists every missing label', () => {
        const res = validateBinding(makeData('seq'), makeScope({ inputs: [], outputs: [] }));
        expect(res.missing).toEqual(['A', 'Y', 'RST']);
    });
});

describe('runAll with missing labels', () => {
    beforeEach(() => jest.clearAllMocks());

    test('shows message and returns null instead of throwing', () => {
        const result = runAll(makeData(), makeScope({ inputs: [] }));
        expect(result).toBeNull();
        expect(showMessage).toHaveBeenCalledWith(expect.stringContaining('A'));
    });
});
