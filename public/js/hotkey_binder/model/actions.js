const addKeys = (mode) => {
	shortcut.removeAll();
	// shortcut.all_shortcuts = {};
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

const setUserKeys = () => {
	let userKeys = {};
	let x = 0;
	while ($("#preference").children()[x]) {
		userKeys[$("#preference").children()[x].children[0].innerText] = $(
			"#preference"
		).children()[x].children[1].innerText;
		x++;
	}
	localStorage.removeItem("defaultKeys");
	localStorage.set("userKeys", userKeys);
	addKeys("user");
};

const setDefault = () => {
	localStorage.set("defaultKeys", defaultKeys); //TODO add a confirmation alert
	addKeys("default");
};

const warnOverride = (combo) => {
	let x = 0;
	// const currentKeys = localStorage.get("userKeys")
	// ? localStorage.get("userKeys")
	// : localStorage.get("defaultKeys");
	while ($("#preference").children()[x]) {
		if ($("#preference").children()[x].children[1].innerText === combo) {
			const asignee = $("#preference").children()[x].children[0]
				.innerText;
			$("#warning").text(
				`This key(s) is already assigned to: ${asignee}, Override?`
			);
		}
		x++;
	}
};

const toggle_hotkey = () => {
	if ($(".disable--cb > input[type='checkbox']").prop("checked") == false) {
		localStorage.set("custom_hotkey", { enable: false });
		shortcut.removeAll();
	} else {
		localStorage.set("custom_hotkey", { enable: true });
		setDefault();
		if (localStorage.userKeys) addKeys("user");
	}
};
