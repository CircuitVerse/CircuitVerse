/**
 * Helper function to show prompt to save image
 * Options - resolution, image type, view
 * @param {Scope=} scope - useless though
 * @category data
 */
import { SimulatorStore } from '#/store/SimulatorStore/SimulatorStore'

/**
 * Function called to generate a prompt to save an image
 * @category data
 * @param {Scope=} - circuit whose image we want
 * @exports createSaveAsImgPrompt
 */
export default function createSaveAsImgPrompt(scope = globalScope) {
    const simulatorStore = SimulatorStore()
    simulatorStore.dialogBox.saveimage_dialog = true
}
