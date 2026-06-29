/**
 * @jest-environment jsdom
 */

import EventQueue from '../src/eventQueue';

/**
 * Build a minimal stand-in for a CircuitElement, exposing only the
 * `propagationDelay` and `queueProperties` fields that EventQueue touches.
 */
function makeElement(propagationDelay = 0) {
    return {
        propagationDelay,
        queueProperties: { inQueue: false, time: 0, index: undefined },
    };
}

describe('EventQueue', () => {
    test('constructor initializes an empty queue', () => {
        const queue = new EventQueue(10);
        expect(queue.size).toBe(10);
        expect(queue.frontIndex).toBe(0);
        expect(queue.time).toBe(0);
        expect(queue.isEmpty()).toBe(true);
    });

    test('add() inserts an element and marks it as queued', () => {
        const queue = new EventQueue(10);
        const element = makeElement(5);
        queue.add(element);

        expect(queue.isEmpty()).toBe(false);
        expect(element.queueProperties.inQueue).toBe(true);
        // time = queue.time (0) + propagationDelay (5)
        expect(element.queueProperties.time).toBe(5);
    });

    test('add() honors an explicit delay over propagationDelay', () => {
        const queue = new EventQueue(10);
        const element = makeElement(5);
        queue.add(element, 3);
        expect(element.queueProperties.time).toBe(3);
    });

    test('pop() returns elements in ascending time order and advances the clock', () => {
        const queue = new EventQueue(10);
        const early = makeElement(2);
        const middle = makeElement(5);
        const late = makeElement(8);
        queue.add(middle);
        queue.add(early);
        queue.add(late);

        expect(queue.pop()).toBe(early);
        expect(queue.time).toBe(2);
        expect(queue.pop()).toBe(middle);
        expect(queue.time).toBe(5);
        expect(queue.pop()).toBe(late);
        expect(queue.time).toBe(8);
        expect(queue.isEmpty()).toBe(true);
    });

    test('add() on an already-queued element re-times and re-orders it', () => {
        const queue = new EventQueue(10);
        const first = makeElement(5);
        const second = makeElement(2);
        queue.add(first);
        queue.add(second);

        // Re-add `first` with a smaller delay; it should now pop before `second`.
        queue.add(first, 1);
        expect(first.queueProperties.inQueue).toBe(true);
        expect(first.queueProperties.time).toBe(1);

        expect(queue.pop()).toBe(first);
        expect(queue.pop()).toBe(second);
    });

    test('addImmediate() queues an element at the current time', () => {
        const queue = new EventQueue(10);
        queue.time = 4;
        const element = makeElement(7);
        queue.addImmediate(element);

        expect(element.queueProperties.inQueue).toBe(true);
        expect(element.queueProperties.time).toBe(4);
        expect(queue.frontIndex).toBe(1);
    });

    test('add() throws once the queue size is exceeded', () => {
        const queue = new EventQueue(1);
        queue.add(makeElement(1));
        expect(() => queue.add(makeElement(2))).toThrow('EventQueue size exceeded');
    });

    test('pop() throws when the queue is empty', () => {
        const queue = new EventQueue(5);
        expect(() => queue.pop()).toThrow('Queue Empty');
    });

    test('reset() empties the queue and clears element state', () => {
        const queue = new EventQueue(10);
        const element = makeElement(3);
        queue.add(element);
        queue.time = 9;

        queue.reset();

        expect(queue.frontIndex).toBe(0);
        expect(queue.time).toBe(0);
        expect(queue.isEmpty()).toBe(true);
        expect(element.queueProperties.inQueue).toBe(false);
    });
});
