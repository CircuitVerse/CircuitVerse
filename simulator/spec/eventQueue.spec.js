/**
 * Unit tests for the EventQueue module.
 *
 * These tests verify correct rescheduling behavior, ensuring
 * that elements already present in the queue are only rescheduled
 * when the new event time is earlier than the existing one.
 */

import EventQueue from '../src/eventQueue';

describe('EventQueue', () => {
    /**
     * Creates a mock simulation element with queue metadata.
     *
     * @param {number} propagationDelay - Delay associated with the element
     * @returns {Object} Mock simulation element
     */
    function createMockElement(propagationDelay = 1) {
        return {
            propagationDelay,
            queueProperties: {
                inQueue: false,
                time: 0,
                index: -1,
            },
        };
    }

    it('does not reschedule an element if the new event time is not earlier', () => {
        const queue = new EventQueue(10);
        const elem = createMockElement(5);

        // Initial scheduling
        queue.add(elem);
        const originalTime = elem.queueProperties.time;

        // Attempt to reschedule with same delay
        queue.add(elem);

        expect(elem.queueProperties.time).toBe(originalTime);
        expect(elem.queueProperties.inQueue).toBe(true);
    });

    it('reschedules an element if the new event time is earlier', () => {
        const queue = new EventQueue(10);
        const elem = createMockElement(10);

        queue.add(elem);
        const laterTime = elem.queueProperties.time;

        // Make the new event earlier
        elem.propagationDelay = 1;
        queue.add(elem);

        expect(elem.queueProperties.time).toBeLessThan(laterTime);
        expect(elem.queueProperties.inQueue).toBe(true);
    });
});
