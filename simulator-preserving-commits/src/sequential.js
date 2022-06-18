import { scheduleUpdate, play, updateCanvasSet } from './engine';
import simulationArea from './simulationArea';

/**
 * a global function as a helper for simulationArea.changeClockEnable
 * @category sequential
 */
export function changeClockEnable(val) {
    simulationArea.clockEnabled = val;
}

/**
 * WIP function defined and used
 * @param {number} n
 * @category sequential
 */
export function runTest(n = 10) {
    var t = new Date().getTime();
    for (var i = 0; i < n; i++) { clockTick(); }
    updateCanvasSet(true);
    play();
    scheduleUpdate();
}
