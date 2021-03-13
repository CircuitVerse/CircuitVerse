// import { shortcut } from './Shortcuts.plugin';
// import createSaveAsImgPrompt from '../../data/saveImage';
//Assign the callback func for the keymap here
import {
    newCircuitCall,
    elementDirection,
    insertLabel,
    labelDirection,
    openHotkey,
	moveElement,
	openDocumentation
} from './actions';
import save from '../../data/save';
import { saveOffline, openOffline } from '../../data/project';
import createSaveAsImgPrompt from '../../data/saveImage';
import { createSubCircuitPrompt } from '../../subcircuit';
import { createCombinationalAnalysisPrompt } from '../../combinationalAnalysis';
import {shortcut} from './shortcuts.plugin.js'

export const addShortcut = (keys, action) => {
	let callback;
	switch (action) {
		case "New Circuit":
			callback = newCircuitCall;
			break;
		case "Save Online":
			callback = save;
			break;
		case "Save Offline":
			callback = saveOffline;
			break;
		case "Download as Image":
			callback = createSaveAsImgPrompt;
			break;
		case "Open Offline":
			callback = openOffline;
			break;
		case "Insert Sub-circuit":
			callback = createSubCircuitPrompt;
			break;
		case "Combinational Analysis":
			callback = createCombinationalAnalysisPrompt;
			break; //bug
		// case "Start Plot":
		// 	callback = startPlot;
		// 	break;
		case "Direction Up":
			callback = elementDirection('up');
			break;
		case "Direction Down":
			callback = elementDirection('down');
			break;
		case "Direction Left":
			callback = elementDirection('left');
			break;
		case "Direction Right":
			callback = elementDirection('right');
			break;
		case "Insert Label":
			callback = insertLabel;
			break;
		case "Label Direction Up":
			callback = labelDirection('up');
			break;
		case "Label Direction Down":
			callback = labelDirection('down');
			break;
		case "Label Direction Left":
			callback = labelDirection('left');
			break;
		case "Label Direction Right":
			callback = labelDirection('right');
			break;
		case "Move Element Up":
			callback = moveElement('up');
			break;
		case "Move Element Down":
			callback = moveElement('down');
			break;
		case "Move Element Left":
			callback = moveElement('left');
			break;
		case "Move Element Right":
			callback = moveElement('right');
			break;
		case "Hotkey Preference":
			callback = openHotkey;
			break;
		case "Open Documentation":
			callback = openDocumentation;
			break;
		default:
			callback = () => console.log('No shortcut found..');
			break;
	}
	shortcut.add(keys, callback, {
		type: "keydown",
		propagate: false,
		target: document,
		disable_in_input: true,
	});
};