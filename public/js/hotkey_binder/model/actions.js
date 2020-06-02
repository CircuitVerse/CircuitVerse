const setUserKeys = () => {
  let userKeys = {};
  let x = 0;
  while ($("#preference").children()[x]) {
    userKeys[$("#preference").children()[x].children[0].innerText] = $(
      "#preference"
    )
      .children()
      [x].children()[1].innerText;
    x++;
  }
  localStorage.removeItem("defaultKeys");
  localStorage.set("userKeys", userKeys);
  addKeys("user");
};

const addKeys = (mode) => {
  shortcut.all_shortcuts = {};
  if (mode == "user") {
    let userKeys = localStorage.get("userKeys");
    for (let pref in userKeys) {
      let key = userKeys[pref];
      key = key.split(" ").join("");
      addShortcut(key, pref);
    }
    updateHTML("user");
  } else if (mode == "default") {
    let defaultKeys = localStorage.get("defaultKeys");
    for (let pref in defaultKeys) {
      let key = defaultKeys[pref];
      key = key.split(" ").join("");
      addShortcut(key, pref);
    }
    updateHTML("default");
  }
};

const setDefault = () => {
  localStorage.set("defaultKeys", defaultKeys);
  addKeys("default");
};

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
  }
  shortcut.add(keys, callback, {
    type: "keydown",
    propagate: true,
    target: document,
  });
};
