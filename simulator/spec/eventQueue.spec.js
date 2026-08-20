import EventQueue from '../src/eventQueue';

/**
 * Minimal stand-in for a CircuitElement, exposing only what EventQueue reads/writes.
 */
function makeElement(propagationDelay) {
    return {
        propagationDelay,
        queueProperties: { inQueue: false, time: 0, index: 0 },
    };
}

describe('EventQueue', () => {
    test('schedules a new object at time 0 when delay is explicitly 0, even with a non-zero propagationDelay', () => {
        const queue = new EventQueue(10);
        const flipFlopOutput = makeElement(10); // default propagationDelay used by DflipFlop/JKflipFlop/TflipFlop/SRflipFlop/Buffer/Counter/Random

        queue.add(flipFlopOutput, 0);

        expect(flipFlopOutput.queueProperties.time).toBe(0);
        expect(flipFlopOutput.queueProperties.inQueue).toBe(true);
    });

    test('falls back to propagationDelay only when delay is omitted (undefined)', () => {
        const queue = new EventQueue(10);
        const gateOutput = makeElement(10);

        queue.add(gateOutput);

        expect(gateOutput.queueProperties.time).toBe(10);
    });

    test('honors an explicit non-zero delay that differs from propagationDelay', () => {
        const queue = new EventQueue(10);
        const el = makeElement(10);

        queue.add(el, 25);

        expect(el.queueProperties.time).toBe(25);
    });

    test('re-scheduling an already-queued object at delay 0 moves it to the current queue time, not queue.time + propagationDelay', () => {
        const queue = new EventQueue(10);
        const a = makeElement(10);
        const b = makeElement(10);

        queue.add(a, 5);
        queue.add(b); // b lands at time 10 (default propagationDelay), so it is already in queue

        // Re-add b with an explicit immediate delay while it is still queued
        queue.add(b, 0);

        expect(b.queueProperties.time).toBe(0);
    });

    test('pop() returns events in ascending time order regardless of insertion order', () => {
        const queue = new EventQueue(10);
        const late = makeElement(10);
        const immediate = makeElement(10);
        const mid = makeElement(10);

        queue.add(late, 20);
        queue.add(immediate, 0);
        queue.add(mid, 10);

        expect(queue.pop()).toBe(immediate);
        expect(queue.pop()).toBe(mid);
        expect(queue.pop()).toBe(late);
        expect(queue.isEmpty()).toBe(true);
    });

    test('advances queue.time to the popped event time', () => {
        const queue = new EventQueue(10);
        const el = makeElement(10);

        queue.add(el, 0);
        queue.pop();

        expect(queue.time).toBe(0);
    });

    test('reset() clears the queue and restores time to 0', () => {
        const queue = new EventQueue(10);
        const el = makeElement(10);

        queue.add(el, 5);
        queue.reset();

        expect(queue.isEmpty()).toBe(true);
        expect(queue.time).toBe(0);
        expect(el.queueProperties.inQueue).toBe(false);
    });

    test('throws when adding beyond the configured size', () => {
        const queue = new EventQueue(1);
        queue.add(makeElement(10), 0);

        expect(() => queue.add(makeElement(10), 0)).toThrow('EventQueue size exceeded');
    });
});
