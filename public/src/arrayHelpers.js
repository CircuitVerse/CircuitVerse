/* eslint-disable func-names */
/* eslint-disable no-global-assign */
/* eslint-disable no-extend-native */
export default Array = window.Array;

var _arrayCount = 0;

Object.defineProperty(Array.prototype, "push_with_index", {
	value: function (value) {
        // cache index
        value.arrayIndexMap[this.get_array_id()] = this.length;
        this.push(value);
    },
	enumerable: false
});

Object.defineProperty(Array.prototype, "get_array_id", {
	value: function (value) {
        if (this.arrayId === undefined) {
            Object.defineProperty(this, 'arrayId', { 
                value: _arrayCount++, 
                configurable: true, 
                writable: true, 
                enumerable: false, 
            });
        }

        return this.arrayId;
    },
	enumerable: false
});

Object.defineProperty(Array.prototype, "clean", {
	value: function (deleteValue) {        
        var index = this.cacheIndexOf(deleteValue);
        if (index == -1) return;
        // swap with last element
        var lastElement = this[this.length - 1];
        lastElement.arrayIndexMap[this.get_array_id()] = index;
        this[index] = lastElement;
        this.pop();
        return this;
    },
	enumerable: false
});

Object.defineProperty(Array.prototype, "extend", {
	value: function (otherArray) {
        /* you should include a test to check whether other_array really is an array */
        otherArray.forEach(function (v) {
            this.push_with_index(v);
        }, this);
    },
	enumerable: false
});

Object.defineProperty(Array.prototype, "cacheIndexOf", {
	value: function (value) {
        if (value.arrayIndexMap[this.get_array_id()] !== undefined) {
            var index = value.arrayIndexMap[this.get_array_id()];
            if (this[index] == value) return index;
        }
        return this.indexOf(value);
    },
	enumerable: false
});

Object.defineProperty(Array.prototype, "contains", {
	value: function (value) {
        return this.cacheIndexOf(value) > -1;
    },
	enumerable: false
});
