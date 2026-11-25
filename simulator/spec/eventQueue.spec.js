/**
 * @jest-environment jsdom
 */

import EventQueue from '../src/eventQueue';

describe('Simulator EventQueue Testing', () => {
    test('schedules with explicit delay 0 when propagationDelay is non-zero', () => {
        const queue = new EventQueue(10);
        const element = {
            propagationDelay: 10,
            queueProperties: { inQueue: false },
        };

        queue.add(element, 0);
        expect(element.queueProperties.time).toBe(0);
    });

    test('falls back to propagationDelay when delay is undefined', () => {
        const queue = new EventQueue(10);
        const element = {
            propagationDelay: 10,
            queueProperties: { inQueue: false },
        };

        queue.add(element);
        expect(element.queueProperties.time).toBe(10);
    });

    test('updates time with explicit delay 0 when already inQueue', () => {
        const queue = new EventQueue(10);
        const element = {
            propagationDelay: 10,
            queueProperties: { inQueue: false },
        };

        queue.add(element, 5);
        expect(element.queueProperties.time).toBe(5);

        queue.add(element, 0);
        expect(element.queueProperties.time).toBe(0);
    });

    test('updates time with fallback propagationDelay when already inQueue and delay undefined', () => {
        const queue = new EventQueue(10);
        const element = {
            propagationDelay: 15,
            queueProperties: { inQueue: false },
        };

        queue.add(element, 5);
        expect(element.queueProperties.time).toBe(5);

        queue.add(element);
        expect(element.queueProperties.time).toBe(15);
    });
});
