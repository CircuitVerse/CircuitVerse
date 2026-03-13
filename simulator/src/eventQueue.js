/* eslint-disable no-underscore-dangle */
/* eslint-disable no-constant-condition */
/* eslint-disable no-param-reassign */
/* eslint-disable no-throw-literal */
/**
 * Event Queue is simply a heap Queue, basic implementation O(logn).
 * @category eventQueue
 */
export default class EventQueue {
    constructor(size) {
        this.size = size;
        this.queue = new Array(size);
        this.backIndex = 0;
        this.time = 0;
        this.heuristic = 0;
    }

    /**
    * @param {CircuitElement} obj - the element to be added
    * @param {number} delay - the delay in adding an object to queue
    */
    add(obj, delay) {
        if (obj.queueProperties.inQueue) {
            const newTime = this.time + (delay || obj.propagationDelay);
            const oldTime = obj.queueProperties.time;
            if (newTime === oldTime) return;
            obj.queueProperties.time = newTime;
            if (newTime < oldTime) {
                obj.queueProperties.heuristic = -(++this.heuristic);
                this.heapifyUp(obj.queueProperties.index);
            } else {
                obj.queueProperties.heuristic = ++this.heuristic;
                this.heapifyDown(obj.queueProperties.index);
            }
            return;
        }

        if (this.backIndex === this.size) throw 'EventQueue size exceeded';
        obj.queueProperties.time = this.time + (delay || obj.propagationDelay);
        obj.queueProperties.index = this.backIndex;
        obj.queueProperties.heuristic = ++this.heuristic;
        this.queue[this.backIndex] = obj;
        obj.queueProperties.inQueue = true;
        this.heapifyUp(this.backIndex); // Heapify the element up to its correct position
        this.backIndex++;
    }

    /**
    * To add without any delay.
    * @param {CircuitElement} obj - the object to be added
    */
    addImmediate(obj) {
        this.add(obj, 0);
    }

    /**
    * function to pop element from the front of the queue
    * @returns {CircuitElement} - the object at the front of the queue
    */
    pop() {
        if (this.isEmpty()) throw 'Queue Empty';

        const obj = this.queue[0];
        this.time = obj.queueProperties.time;

        // Move last element to root
        this.swap(0, this.backIndex - 1);
        obj.queueProperties.inQueue = false;
        this.backIndex--;

        this.queue[this.backIndex] = undefined;

        if (this.backIndex > 0) {
            this.queue[0].queueProperties.heuristic = -(++this.heuristic);
            this.heapifyDown(0);
        }

        return obj;
    }

    /**
    * Function to swap two objects in the queue
    * @param {number} v1
    * @param {number} v2
    */
    swap(v1, v2) {
        const obj1 = this.queue[v1];
        obj1.queueProperties.index = v2;

        const obj2 = this.queue[v2];
        obj2.queueProperties.index = v1;

        this.queue[v1] = obj2;
        this.queue[v2] = obj1;
    }

    /**
    * Function to heapify the element up to its correct position.
    * @param {number} index
    */
    heapifyUp(startIndex) {
        let index = startIndex;
        while (index > 0) {
            const parentIndex = Math.floor((index - 1) / 2);
            if (!EventQueue.__compare(this.queue[index], this.queue[parentIndex])) break;
            this.swap(index, parentIndex);
            index = parentIndex;
        }
    }

    /**
    * Function to heapify the element down to its correct position.
    * @param {number} index
    */
    heapifyDown(indexStart) {
        let index = indexStart;
        while (true) {
            const leftChildIndex = 2 * index + 1;
            const rightChildIndex = 2 * index + 2;
            let smallestChildIndex = index;

            if (leftChildIndex < this.backIndex && EventQueue.__compare(this.queue[leftChildIndex], this.queue[smallestChildIndex])) {
                smallestChildIndex = leftChildIndex;
            }

            if (rightChildIndex < this.backIndex && EventQueue.__compare(this.queue[rightChildIndex], this.queue[smallestChildIndex])) {
                smallestChildIndex = rightChildIndex;
            }

            if (smallestChildIndex === index) break;

            this.swap(index, smallestChildIndex);
            index = smallestChildIndex;
        }
    }

    /**
     * function to reset the queue
     */
    reset() {
        while (this.backIndex > 0) {
            this.queue[this.backIndex - 1].queueProperties.inQueue = false;
            this.backIndex--;
        }
        this.time = 0;
        this.heuristic = 0;
    }

    /**
    * function to check if the queue is empty.
    */
    isEmpty() {
        return this.backIndex === 0;
    }

    static __compare(element1, element2) {
        if (element1.queueProperties.time !== element2.queueProperties.time) {
            return element1.queueProperties.time < element2.queueProperties.time;
        }

        return element1.queueProperties.heuristic > element2.queueProperties.heuristic;
    }
}
