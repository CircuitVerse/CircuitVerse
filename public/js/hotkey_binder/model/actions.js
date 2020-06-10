const addKeys = (mode) => {
    shortcut.removeAll();
    if (mode == "user") {
        localStorage.removeItem("defaultKeys");
        let userKeys = localStorage.get("userKeys");
        for (let pref in userKeys) {
            let key = userKeys[pref];
            key = key.split(" ").join("");
            addShortcut(key, pref);
        }
        updateHTML("user");
    } else if (mode == "default") {
        if (localStorage.userKeys) localStorage.removeItem("userKeys");
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
    localStorage.set("userKeys", userKeys);
    addKeys("user");
};

const setDefault = () => {
    if (getOS() === "MacOS") {
        const macDefaultKeys = {};
        for (let [key, value] of Object.entries(defaultKeys)) {
            if (value.split(" + ")[0] == "Ctrl");
            macDefaultKeys[key] =
                value.split(" + ")[0] === "CTRL"
                    ? value.replace("CTRL", "META")
                    : value;
            localStorage.set("defaultKeys", macDefaultKeys);
        }
    } else {
        localStorage.set("defaultKeys", defaultKeys); //TODO add a confirmation alert
    }
    addKeys("default");
};

const warnOverride = (combo) => {
    let x = 0;
    while ($("#preference").children()[x]) {
        if ($("#preference").children()[x].children[1].innerText === combo) {
            const asignee = $("#preference").children()[x].children[0]
                .innerText;
            $("#warning").text(
                `This key(s) is already assigned to: ${asignee}, Override?`
            );
            $("#edit").css("border", "1.5px solid #dc5656");
            return;
        } else {
            $("#warning").text("");
            $("#edit").css("border", "none");
        }
        x++;
    }
};

const elementDirecton = (keyCode) => () => {
    if (simulationArea.lastSelected) {
        simulationArea.lastSelected.newDirection(keyCode.toUpperCase());
        $("select[name |= 'newDirection']").val(keyCode.toUpperCase());
    }
};
