/**
 * EventQueue manages scheduled simulation events in time order.
 *
 * It prevents redundant rescheduling by ensuring that an event already
 * present in the queue is only rescheduled if the new event time is
 * earlier than the existing scheduled time.
 */
export default class EventQueue {
    /**
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
     * If the object is already in the queue, it will only be rescheduled
     * when the newly computed event time is earlier than the existing one.
     *
     * @param {Object} obj - Simulation element to schedule
     * @param {number} [delay] - Optional delay override (0 is valid)
     * @returns {void}
     */
    add(obj, delay) {
        const qp = obj.queueProperties;

        // Use nullish coalescing so delay = 0 works correctly
        const effectiveDelay = delay ?? obj.propagationDelay;
        const newTime = this.time + effectiveDelay;

        if (qp.inQueue) {
            const oldTime = qp.time;

            // Do not reschedule if the existing event is earlier or equal
            if (newTime >= oldTime) {
                return;
            }

            qp.time = newTime;
            let i = qp.index;

            // Bubble toward front (earlier execution)
            while (
                i > 0 &&
                qp.time > this.queue[i - 1].queueProperties.time
            ) {
                this.swap(i, i - 1);
                i--;
            }

            // Bubble toward back if required
            i = qp.index;
            while (
                i < this.frontIndex - 1 &&
                qp.time < this.queue[i + 1].queueProperties.time
            ) {
                this.swap(i, i + 1);
                i++;
            }
            return;
        }

        if (this.frontIndex === this.size) {
            throw new Error('EventQueue size exceeded');
        }

        this.queue[this.frontIndex] = obj;
        qp.inQueue = true;
        qp.index = this.frontIndex;
        qp.time = newTime;
        this.frontIndex++;
    }

    /**
     * Swaps two elements in the queue and updates their indices.
     *
     * @param {number} i - First index
     * @param {number} j - Second index
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
