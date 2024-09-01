import { setup } from '../src/setup';
import load from '../src/data/load';
import circuitData from './circuits/misc-circuitdata.json';
import testData from './testData/misc-testdata.json';
import { runAll } from '../src/testbench';
import { createPinia, setActivePinia } from 'pinia';
import { mount } from '@vue/test-utils';
import { createRouter, createWebHistory } from 'vue-router';
import i18n from '#/locales/i18n';
import { routes } from '#/router';
import vuetify from '#/plugins/vuetify';
import simulator from '#/pages/simulator.vue';

vi.mock('codemirror', async (importOriginal) => {
    const actual = await importOriginal();
    return {
        ...actual,
        fromTextArea: vi.fn(() => ({ setValue: () => { } })),
    };
});

vi.mock('codemirror-editor-vue3', () => ({
    defineSimpleMode: vi.fn(),
}));

describe('Simulator Misc-Elements Testing', () => {
    let pinia;
    let router;

    beforeAll(async () => {
        pinia = createPinia();
        setActivePinia(pinia);

        router = createRouter({
            history: createWebHistory(),
            routes,
        });

        const elem = document.createElement('div')

        if (document.body) {
            document.body.appendChild(elem)
        }

        global.document.createRange = vi.fn(() => ({
            setEnd: vi.fn(),
            setStart: vi.fn(),
            getBoundingClientRect: vi.fn(() => ({
                x: 0,
                y: 0,
                width: 0,
                height: 0,
                top: 0,
                right: 0,
                bottom: 0,
                left: 0,
            })),
            getClientRects: vi.fn(() => ({
                item: vi.fn(() => null),
                length: 0,
                [Symbol.iterator]: vi.fn(() => []),
            })),
        }));

        global.globalScope = global.globalScope || {};

        mount(simulator, {
            global: {
                plugins: [pinia, router, i18n, vuetify],
            },
            attachTo: elem,
        });

        setup();
    });

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
