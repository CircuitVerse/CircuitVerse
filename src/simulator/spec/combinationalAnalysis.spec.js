import { setup } from '../src/setup';
import { runAll } from '../src/testbench';
import testData from './testData/gates-testdata.json';
import { GenerateCircuit, performCombinationalAnalysis } from '../src/combinationalAnalysis';
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

describe('Combinational Analysis Testing', () => {
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

    test('performCombinationalAnalysis function working', () => {
        expect(() => performCombinationalAnalysis('', '', 'AB')).not.toThrow();
    });

    test('Generating Circuit', () => {
        expect(() => GenerateCircuit([13], ['A', 'B'], [0, 0, 0, 1], 'AB')).not.toThrow();
    });

    test('testing Combinational circuit', () => {
        testData.AndGate.groups[0].inputs[0].label = 'A';
        testData.AndGate.groups[0].inputs[1].label = 'B';
        testData.AndGate.groups[0].outputs[0].label = 'AB';

        const result = runAll(testData.AndGate);
        expect(result.summary.passed).toBe(3);
    });
});
