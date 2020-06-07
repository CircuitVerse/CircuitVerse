import { createSubCircuitPrompt } from './subcircuit';
import save from './data/save';
import load from './data/load';
import createSaveAsImgPrompt from './data/saveImage';
import {
    clearProject, newProject, saveOffline, openOffline, recoverProject,
} from './data/project';
import { newCircuit } from './circuit';
import { createCombinationalAnalysisPrompt } from './combinationalAnalysis';
import { createBitConverter } from './dec-bin-hex';

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
logixFunction.bitconverter = createBitConverter;
export default logixFunction;
