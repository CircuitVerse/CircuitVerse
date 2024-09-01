import { setup } from '../src/setup';
import load from '../src/data/load';
import circuitData from './circuits/Decoders-plexers-circuitdata.json';
import testData from './testData/decoders-plexers.json';
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

describe('Simulator Decoders and Plexers Testing', () => {
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

    test('load decoders-plexers circuitData', () => {
        expect(() => load(circuitData)).not.toThrow();
    });

    test('Multiplexer working', () => {
        const result = runAll(testData.Multiplexers);
        expect(result.summary.passed).toBe(8);
    });

    test('Demultiplexer working', () => {
        const result = runAll(testData.Demultiplexer);
        expect(result.summary.passed).toBe(4);
    });

    test('BitSelector working', () => {
        const result = runAll(testData['bit-selector']);
        expect(result.summary.passed).toBe(4);
    });

    test('MSB working', () => {
        const result = runAll(testData.msb);
        expect(result.summary.passed).toBe(5);
    });

    test('LSB working', () => {
        const result = runAll(testData.lsb);
        expect(result.summary.passed).toBe(10);
    });

    test('Priority Encoder working', () => {
        const result = runAll(testData['priority-encoder']);
        expect(result.summary.passed).toBe(4);
    });

    test('Decoder working', () => {
        const result = runAll(testData.Decoder);
        expect(result.summary.passed).toBe(2);
    });
});
