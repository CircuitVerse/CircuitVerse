/* eslint-disable func-names */
/* eslint-disable no-global-assign */
/* eslint-disable no-extend-native */
export default Array = window.Array;
Array.prototype.clean = function (deleteValue) {
    for (let i = 0; i < this.length; i++) {
        if (this[i] === deleteValue) {
            this.splice(i, 1);
            i--;
        }
    }
    return this;
};

// Following function need to be improved
Array.prototype.extend = function (otherArray) {
    /* you should include a test to check whether other_array really is an array */
    otherArray.forEach(function (v) {
        this.push(v);
    }, this);
};

// Following function need to be improved
// fn to check if an elem is in an array
Array.prototype.contains = function (value) {
    return this.indexOf(value) > -1;
};
