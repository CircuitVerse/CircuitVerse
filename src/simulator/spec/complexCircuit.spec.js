import { setup } from '../src/setup';
import load from '../src/data/load';
import { runAll } from '../src/testbench';
import aluCircuitData from './circuits/alu-circuitdata.json';
import rippleCircuitData from './circuits/rippleCarryAdder-circuitdata.json';
import rippleTestData from './testData/ripple-carry-adder.json';
import aluTestData from './testData/alu-testdata.json';
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

describe('data dir working', () => {
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

    test('load ripple carry adder circuit-data', () => {
        expect(() => load(rippleCircuitData)).not.toThrow();
    });

    test('ripple carry adder circuit testing', () => {
        const result = runAll(rippleTestData.testData);
        expect(result.summary.passed).toBe(10);
    });

    test('load ALU circuit-data', () => {
        expect(() => load(aluCircuitData)).not.toThrow();
    });

    test('ALU circuit testing', () => {
        const result = runAll(aluTestData.testData);
        expect(result.summary.passed).toBe(5);
    });
});
