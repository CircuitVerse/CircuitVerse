import { scheduleUpdate, play, updateCanvasSet } from './engine';
import simulationArea from './simulationArea';

/**
 * a global function as a helper for simulationArea.changeClockEnable
 */
export function changeClockEnable(val) {
    simulationArea.clockEnabled = val;
}

/**
 * WIP function defined but not used
 * @param {number} n
 */
export function runTest(n = 10) {
    var t = new Date().getTime();
    for (var i = 0; i < n; i++) { clockTick(); }
    // console.log((new Date().getTime()-t)/n);
    updateCanvasSet(true);
    play();
    scheduleUpdate();
}
