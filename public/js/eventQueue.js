// Event Queue is simply a priority Queue, basic implementation O(logn) per query

class EventQueue {
    constructor(size){
        this.size = size;
        this.queue = new Array(size);
        this.frontIndex = 0;
        this.time = 0;
    }

    parent(index){
        if(index == 0){
            return 0;
        }
        return Math.floor((index - 1) / 2);
    }

    left(index){
        return (2 * index + 1);
    }

    right(index){
        return (2 * index + 2);
    }

    time_ind(index){
        return (this.queue[index].queueProperties.time);
    }

    minHeapify(index){
        let left_child = this.left(index);
        let right_child = this.right(index);
        let smallest = index;
        if(left_child < this.frontIndex && this.time_ind(left_child) < this.time_ind(index)){
            smallest = left_child;
        }
        if(right_child < this.frontIndex && this.time_ind(right_child) < this.time_ind(smallest)){
            smallest = right_child;
        }
        if(smallest != index){
            this.swap(smallest, index);
            this.minHeapify(smallest);
        }
    }

    deleteHelp(index){
        this.queue[index].queueProperties.time = 0;
        let newtime = -1;
        while(index > 0 && this.queue[this.parent(index)].queueProperties.time > newtime){
            this.swap(index, this.parent(index));
            index = this.parent(index);
        }
    }

    deleteKey(index){
        this.deleteHelp(index);
        this.pop();
    }

    add(obj, delay){
        if(obj.queueProperties.inQueue){
            this.deleteKey(obj.queueProperties.index);
        }
        if(this.frontIndex == this.size) throw "EventQueue size exceeded";
        this.queue[this.frontIndex] = obj;
        obj.queueProperties.time = this.time + (delay || obj.propagationDelay);
        obj.queueProperties.index = this.frontIndex;
        obj.queueProperties.inQueue = true;
        let i = obj.queueProperties.index;
        let newtime = obj.queueProperties.time;
        while(i > 0 && this.queue[this.parent(i)].queueProperties.time > newtime){
            this.swap(i, this.parent(i));
            i = this.parent(i);
        }
        this.frontIndex++;
    }

    addImmediate(obj){
        if(this.frontIndex == this.size) throw "EventQueue size exceeded";
        this.queue[this.frontIndex] = obj;
        obj.queueProperties.time = this.time;
        obj.queueProperties.index = this.frontIndex;
        obj.queueProperties.inQueue = true;
        let i = obj.queueProperties.index;
        let newtime = obj.queueProperties.time;
        while(i > 0 && this.queue[this.parent(i)].queueProperties.time > newtime){
            this.swap(i, this.parent(i));
            i = this.parent(i);
        }
        this.frontIndex++;
    }

    swap(v1, v2){
        let obj1 = this.queue[v1];
        obj1.queueProperties.index = v2;
        let obj2 = this.queue[v2];
        obj2.queueProperties.index = v1;
        this.queue[v1] = obj2;
        this.queue[v2] = obj1;
    }

    pop(){
        //console.log(this.time_ind(0));
        if(this.isEmpty()) throw "Queue Empty";
        if(this.frontIndex == 1){
            this.frontIndex = 0;
            return this.queue[0];
        }
        let min_obj = this.queue[0];
        this.queue[0] = this.queue[this.frontIndex - 1];
        this.frontIndex--;
        this.minHeapify(0);
        this.time = min_obj.queueProperties.time;
        min_obj.queueProperties.inQueue = false;
        return min_obj;
    }

    reset(){
        for(let i = 0; i < this.frontIndex; i++){
            this.queue[i].queueProperties.inQueue = false;
            this.queue[i].queueProperties.time = undefined;
            this.queue[i].queueProperties.index = undefined;
        }
        this.time = 0;
        this.frontIndex = 0;
    }

    isEmpty(){
        return this.frontIndex == 0;
    }
}
