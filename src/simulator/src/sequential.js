import { scheduleUpdate, play, updateCanvasSet } from './engine'
import { simulationArea } from './simulationArea'

/**
 * a global function as a helper for simulationArea.changeClockEnable
 * @category sequential
 */
export function changeClockEnable(val) {
    simulationArea.clockEnabled = val
}
