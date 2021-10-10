import { fullView, deleteSelected } from './ux';
import { createSubCircuitPrompt } from './subcircuit';
import save from './data/save';
import load from './data/load';
import createSaveAsImgPrompt from './data/saveImage'
import { clearProject, newProject, saveOffline, openOffline, recoverProject } from './data/project'
import { newCircuit } from './circuit'
import { createCombinationalAnalysisPrompt } from './combinationalAnalysis';
import { colorThemes } from "./themer/themer";
import { showTourGuide } from './tutorials';
import {createVerilogCircuit, saveVerilogCode, resetVerilogCode} from './Verilog2CV';
import { generateVerilog } from './verilog';
import { bitConverterDialog } from './utils';

const circuitverseFunction = {};
circuitverseFunction.save = save;
circuitverseFunction.load = load;
circuitverseFunction.createSaveAsImgPrompt = createSaveAsImgPrompt;
circuitverseFunction.clearProject = clearProject;
circuitverseFunction.newProject = newProject;
circuitverseFunction.saveOffline = saveOffline;
circuitverseFunction.newCircuit = newCircuit;
circuitverseFunction.createOpenLocalPrompt = openOffline;
circuitverseFunction.recoverProject = recoverProject;
circuitverseFunction.createSubCircuitPrompt = createSubCircuitPrompt;
circuitverseFunction.createCombinationalAnalysisPrompt = createCombinationalAnalysisPrompt;
circuitverseFunction.fullViewOption = fullView;
circuitverseFunction.colorThemes = colorThemes;
circuitverseFunction.showTourGuide = showTourGuideHelper;
circuitverseFunction.deleteSelected = deleteSelected;
circuitverseFunction.newVerilogModule = createVerilogCircuit;
circuitverseFunction.saveVerilogCode = saveVerilogCode;
circuitverseFunction.resetVerilogCode = resetVerilogCode;
circuitverseFunction.generateVerilog = generateVerilog;
circuitverseFunction.bitconverter = bitConverterDialog;
export default circuitverseFunction;

// Hack to restart tour guide
function showTourGuideHelper() {
    setTimeout(()=> {showTourGuide();}, 100);
}