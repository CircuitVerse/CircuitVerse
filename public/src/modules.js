/* eslint-disable import/no-cycle */
import simulationArea from './simulationArea';

export function getNextPosition(x = 0, scope = globalScope) {
    let possibleY = 20;
    const done = {};
    for (let i = 0; i < scope.Input.length - 1; i++) {
        if (scope.Input[i].layoutProperties.x === x) { done[scope.Input[i].layoutProperties.y] = 1; }
    }
    for (let i = 0; i < scope.Output.length; i++) {
        if (scope.Output[i].layoutProperties.x === x) { done[scope.Output[i].layoutProperties.y] = 1; }
    }
    while (done[possibleY] || done[possibleY + 10] || done[possibleY - 10]) { possibleY += 10; }
    const height = possibleY + 20;
    if (height > scope.layout.height) {
        const oldHeight = scope.layout.height;
        scope.layout.height = height;
        for (let i = 0; i < scope.Input.length; i++) {
            if (scope.Input[i].layoutProperties.y === oldHeight) { scope.Input[i].layoutProperties.y = scope.layout.height; }
        }
        for (let i = 0; i < scope.Output.length; i++) {
            if (scope.Output[i].layoutProperties.y === oldHeight) { scope.Output[i].layoutProperties.y = scope.layout.height; }
        }
    }
    return possibleY;
}

/**
 * Global
 */
var modules = {}

export default modules;

export function changeInputSize(size) {
    if (size == undefined || size < 2 || size > 10) return;
    if (this.inputSize == size) return;
    size = parseInt(size, 10);
    var obj = new modules[this.objectType](this.x, this.y, this.scope, this.direction, size, this.bitWidth);
    this.delete();
    simulationArea.lastSelected = obj;
    return obj;
}
