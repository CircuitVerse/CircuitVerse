import EventQueue from '../src/eventQueue';

describe('EventQueue', () => {
    test('schedules at delay=0 when delay is explicitly 0', () => {
        const queue = new EventQueue(10);
        const obj = {
            propagationDelay: 10,
            queueProperties: { inQueue: false }
        };

        queue.add(obj, 0);

        expect(obj.queueProperties.time).toBe(0);
    });

    test('falls back to propagationDelay when delay is undefined', () => {
        const queue = new EventQueue(10);
        const obj = {
            propagationDelay: 10,
            queueProperties: { inQueue: false }
        };

        queue.add(obj);

        expect(obj.queueProperties.time).toBe(10);
    });

    test('re-schedules an already queued object with explicit delay=0', () => {
        const queue = new EventQueue(10);
        const obj = {
            propagationDelay: 10,
            queueProperties: { inQueue: false }
        };

        queue.add(obj);
        expect(obj.queueProperties.time).toBe(10);

        queue.add(obj, 0);
        expect(obj.queueProperties.time).toBe(0);
    });
});
