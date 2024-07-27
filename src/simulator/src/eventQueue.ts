/**
 * Event Queue is simply a priority Queue, basic implementation O(n^2).
 * @category eventQueue
 */

interface QueueObject {
    queueProperties: {
        inQueue: boolean
        time: number
        index: number
    }
    propagationDelay: number
}

export class EventQueue {
    size: number
    queue: Array<QueueObject>
    frontIndex: number
    time: number
    constructor(size: number) {
        this.size = size
        this.queue = new Array(size)
        this.frontIndex = 0
        this.time = 0
    }

    add(obj: QueueObject, delay: number) {
        if (obj.queueProperties.inQueue) {
            obj.queueProperties.time =
                this.time + (delay || obj.propagationDelay)
            let i = obj.queueProperties.index
            while (
                i > 0 &&
                obj.queueProperties.time >
                    this.queue[i - 1].queueProperties.time
            ) {
                this.swap(i, i - 1)
                i--
            }
            i = obj.queueProperties.index
            while (
                i < this.frontIndex - 1 &&
                obj.queueProperties.time <
                    this.queue[i + 1].queueProperties.time
            ) {
                this.swap(i, i + 1)
                i++
            }
            return
        }

        if (this.frontIndex == this.size) throw 'EventQueue size exceeded'
        this.queue[this.frontIndex] = obj
        obj.queueProperties.time = this.time + (delay || obj.propagationDelay)
        obj.queueProperties.index = this.frontIndex
        this.frontIndex++
        obj.queueProperties.inQueue = true
        let i = obj.queueProperties.index
        while (
            i > 0 &&
            obj.queueProperties.time > this.queue[i - 1].queueProperties.time
        ) {
            this.swap(i, i - 1)
            i--
        }
    }

    /**
     * To add without any delay.
     * @param {CircuitElement} obj - the object to be added
     */
    addImmediate(obj: QueueObject) {
        this.queue[this.frontIndex] = obj
        obj.queueProperties.time = this.time
        obj.queueProperties.index = this.frontIndex
        obj.queueProperties.inQueue = true
        this.frontIndex++
    }

    /**
     * Function to swap two objects in queue.
     */
    swap(v1: number, v2: number) {
        const obj1 = this.queue[v1]
        obj1.queueProperties.index = v2

        const obj2 = this.queue[v2]
        obj2.queueProperties.index = v1

        this.queue[v1] = obj2
        this.queue[v2] = obj1
    }

    /**
     * function to pop element from queue.
     */
    pop() {
        if (this.isEmpty()) throw 'Queue Empty'

        this.frontIndex--
        const obj = this.queue[this.frontIndex]
        this.time = obj.queueProperties.time
        obj.queueProperties.inQueue = false
        return obj
    }

    /**
     * function to reset queue.
     */
    reset() {
        for (let i = 0; i < this.frontIndex; i++)
            this.queue[i].queueProperties.inQueue = false
        this.time = 0
        this.frontIndex = 0
    }

    /**
     * function to check if empty queue.
     */
    isEmpty() {
        return this.frontIndex == 0
    }
}
