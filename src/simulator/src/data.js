import { fullView, deleteSelected } from './ux'
import { createSubCircuitPrompt } from './subcircuit'
import save from './data/save'
import load from './data/load'
import createSaveAsImgPrompt from './data/saveImage'
import {
    clearProject,
    newProject,
    saveOffline,
    openOffline,
    recoverProject,
} from './data/project'
import { newCircuit, createNewCircuitScope } from './circuit'
import { createCombinationalAnalysisPrompt } from './combinationalAnalysis'
import { colorThemes } from './themer/themer'
import { showTourGuide } from './tutorials'
import {
    createVerilogCircuit,
    // saveVerilogCode,
    // resetVerilogCode,
    // applyVerilogTheme,
} from './Verilog2CV'
import { generateVerilog } from './verilog'
import { bitConverterDialog } from './utils'
import { keyBinder } from '#/components/DialogBox/CustomShortcut.vue'
import { ExportProject } from '#/components/DialogBox/ExportProject.vue'
import { ImportProject } from '#/components/DialogBox/ImportProject.vue'

const logixFunction = {}
logixFunction.save = save
logixFunction.load = load
logixFunction.createSaveAsImgPrompt = createSaveAsImgPrompt
logixFunction.clearProject = clearProject
logixFunction.newProject = newProject
logixFunction.saveOffline = saveOffline
// logixFunction.newCircuit = newCircuit
logixFunction.createOpenLocalPrompt = openOffline
logixFunction.recoverProject = recoverProject
logixFunction.createSubCircuitPrompt = createSubCircuitPrompt
logixFunction.createCombinationalAnalysisPrompt =
    createCombinationalAnalysisPrompt
logixFunction.fullViewOption = fullView
logixFunction.colorThemes = colorThemes
logixFunction.showTourGuide = showTourGuideHelper
logixFunction.deleteSelected = deleteSelected
logixFunction.newVerilogModule = createVerilogCircuit
// logixFunction.saveVerilogCode = saveVerilogCode
// logixFunction.resetVerilogCode = resetVerilogCode
logixFunction.generateVerilog = generateVerilog
// logixFunction.applyVerilogTheme = applyVerilogTheme
logixFunction.bitconverter = bitConverterDialog
logixFunction.createNewCircuitScope = createNewCircuitScope
logixFunction.customShortcut = keyBinder
logixFunction.ExportProject = ExportProject
logixFunction.ImportProject = ImportProject
export default logixFunction

// Hack to restart tour guide
function showTourGuideHelper() {
    setTimeout(() => {
        showTourGuide()
    }, 100)
}
