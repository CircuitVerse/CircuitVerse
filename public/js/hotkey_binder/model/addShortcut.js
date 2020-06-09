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
