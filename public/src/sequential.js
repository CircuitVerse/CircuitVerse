import TflipFlop from './sequential/TflipFlop';
import DflipFlop from './sequential/DflipFlop';
import Dlatch from './sequential/Dlatch';
import SRflipFlop from './sequential/SRflipFlop';
import JKflipFlop from './sequential/JKflipFlop';
import TTY from './sequential/TTY';
import Keyboard from './sequential/Keyboard';
import Clock from './sequential/Clock';
import RAM from './sequential/RAM';
import EEPROM from './sequential/EEPROM';
import Rom from './sequential/Rom';
import { scheduleUpdate, play } from './engine';
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
    updateCanvas = true;
    play();
    scheduleUpdate();
}


const sequential = {
    TflipFlop,
    DflipFlop,
    Dlatch,
    SRflipFlop,
    JKflipFlop,
    TTY,
    Keyboard,
    Clock,
    Rom,
    EEPROM,
    RAM,
};
export default sequential;
