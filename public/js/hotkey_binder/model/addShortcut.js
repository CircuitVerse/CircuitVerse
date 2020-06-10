//Assign the callback func for the keymap here

const addShortcut = (keys, action) => {
	let callback;
	switch (action) {
		case "New Project":
			callback = newProject;
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
			callback = createOpenLocalPrompt;
			break;
		case "Recover Project":
			callback = recoverProject;
			break;
		case "New Circuit":
			callback = newCircuit;
			break;
		case "Create Sub-ciruit":
			callback = createSubCircuitPrompt;
			break;
		case "Combinational Analysis":
			callback = createCombinationalAnalysisPrompt;
			break; //bug
		case "Start Plot":
			callback = startPlot;
			break;
		case "Direction Up":
			callback = elementDirecton('up');
			break;
		case "Direction Down":
			callback = elementDirecton('down');
			break;
		case "Direction Left":
			callback = elementDirecton('left');
			break;
		case "Direction Right":
			callback = elementDirecton('right');
			break;
		case "Insert Label":
			callback = insertLabel;
			break;
		case "Label Direction Up":
			callback = labelDirecton('up');
			break;
		case "Label Direction Down":
			callback = labelDirecton('down');
			break;
		case "Label Direction Left":
			callback = labelDirecton('left');
			break;
		case "Label Direction Right":
			callback = labelDirecton('right');
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
		default:
			callback = null;
			break;
	}
	shortcut.add(keys, callback, {
		type: "keydown",
		propagate: false,
		target: document,
		disable_in_input: true,
	});
};
