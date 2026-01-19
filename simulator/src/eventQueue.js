/**
 * EventQueue manages scheduled simulation events in time order.
 *
 * It prevents redundant rescheduling by ensuring that an event
 * already present in the queue is only rescheduled if the new
 * event time is earlier than the existing scheduled time.
 */
export default class EventQueue {
    /**
     * Creates an EventQueue.
     *
     * @param {number} size - Maximum number of events allowed in the queue
     */
    constructor(size) {
        this.size = size;
        this.queue = new Array(size);
        this.frontIndex = 0;
        this.time = 0;
    }

    /**
     * Adds an object to the event queue.
     *
     * If the object is already present in the queue, it will only be
     * rescheduled if the new event time is earlier than the currently
     * scheduled time. Otherwise, the queue remains unchanged.
     *
     * @param {Object} obj - Simulation element to schedule
     * @param {number} [delay] - Optional delay override for scheduling
     * @returns {void}
     */
    add(obj, delay) {
        if (obj.queueProperties.inQueue) {
            const oldTime = obj.queueProperties.time;
            const newTime = this.time + (delay || obj.propagationDelay);

            // Do not reschedule if the existing event is earlier or equal
            if (newTime >= oldTime) {
                return;
            }

            obj.queueProperties.time = newTime;
            let i = obj.queueProperties.index;

            // Bubble up if the event should occur earlier
            while (
                i > 0 &&
                obj.queueProperties.time > this.queue[i - 1].queueProperties.time
            ) {
                this.swap(i, i - 1);
                i--;
            }

            // Bubble down if needed to restore ordering
            i = obj.queueProperties.index;
            while (
                i < this.frontIndex - 1 &&
                obj.queueProperties.time < this.queue[i + 1].queueProperties.time
            ) {
                this.swap(i, i + 1);
                i++;
            }
            return;
        }

        if (this.frontIndex === this.size) {
            throw 'EventQueue size exceeded';
        }

        this.queue[this.frontIndex] = obj;
        obj.queueProperties.inQueue = true;
        obj.queueProperties.index = this.frontIndex;
        obj.queueProperties.time = this.time + (delay || obj.propagationDelay);
        this.frontIndex++;
    }

    /**
     * Swaps two elements in the queue and updates their indices.
     *
     * @param {number} i - Index of the first element
     * @param {number} j - Index of the second element
     * @returns {void}
     */
    swap(i, j) {
        const temp = this.queue[i];
        this.queue[i] = this.queue[j];
        this.queue[j] = temp;

        this.queue[i].queueProperties.index = i;
        this.queue[j].queueProperties.index = j;
    }
}
