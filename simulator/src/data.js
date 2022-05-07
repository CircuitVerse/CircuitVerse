import { fullView, deleteSelected, replayCircuit } from './ux';
import { createSubCircuitPrompt } from './subcircuit';
import save from './data/save';
import load from './data/load';
import createSaveAsImgPrompt from './data/saveImage'
import { clearProject, newProject, saveOffline, openOffline, recoverProject } from './data/project'
import { newCircuit, createNewCircuitScope } from './circuit'
import { createCombinationalAnalysisPrompt } from './combinationalAnalysis';
import { colorThemes } from "./themer/themer";
import { showTourGuide } from './tutorials';
import {createVerilogCircuit, saveVerilogCode, resetVerilogCode} from './Verilog2CV';
import { generateVerilog } from './verilog';
import { bitConverterDialog } from './utils';
import { setProgressValue, buttonBackPress, buttonForwardPress, buttonRewindPress, buttonFastforwardPress, buttonPlayPress, buttonStopPress } from './data/replay';

const logixFunction = {};
logixFunction.save = save;
logixFunction.load = load;
logixFunction.createSaveAsImgPrompt = createSaveAsImgPrompt;
logixFunction.clearProject = clearProject;
logixFunction.newProject = newProject;
logixFunction.saveOffline = saveOffline;
logixFunction.newCircuit = newCircuit;
logixFunction.createOpenLocalPrompt = openOffline;
logixFunction.recoverProject = recoverProject;
logixFunction.createSubCircuitPrompt = createSubCircuitPrompt;
logixFunction.createCombinationalAnalysisPrompt = createCombinationalAnalysisPrompt;
logixFunction.fullViewOption = fullView;
logixFunction.replayCircuit = replayCircuit;
logixFunction.colorThemes = colorThemes;
logixFunction.showTourGuide = showTourGuideHelper;
logixFunction.deleteSelected = deleteSelected;
logixFunction.newVerilogModule = createVerilogCircuit;
logixFunction.saveVerilogCode = saveVerilogCode;
logixFunction.resetVerilogCode = resetVerilogCode;
logixFunction.generateVerilog = generateVerilog;
logixFunction.bitconverter = bitConverterDialog;
logixFunction.createNewCircuitScope = createNewCircuitScope;

logixFunction.progress = setProgressValue;
logixFunction.button_fbw = buttonRewindPress;
logixFunction.button_bw = buttonBackPress;
logixFunction.button_play = buttonPlayPress;
logixFunction.button_stop = buttonStopPress;
logixFunction.button_fw = buttonForwardPress;
logixFunction.button_ffw = buttonFastforwardPress;

export default logixFunction;

// Hack to restart tour guide
function showTourGuideHelper() {
    setTimeout(()=> {showTourGuide();}, 100);
}
