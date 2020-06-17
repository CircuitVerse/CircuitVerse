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
        userKeys[$("#preference").children()[x].children[1].children[0].innerText] = $(
            "#preference"
        ).children()[x].children[1].children[1].innerText;
        x++;
    }
    localStorage.set("userKeys", userKeys);
    addKeys("user");
};

const setDefault = () => {
    if (localStorage.userKeys) localStorage.removeItem('userKeys');
    if (getOS() === "MacOS") {
        const macDefaultKeys = {};
        for (let [key, value] of Object.entries(defaultKeys)) {
            if (value.split(" + ")[0] == "Ctrl");
            macDefaultKeys[key] =
                value.split(" + ")[0] == "Ctrl"
                    ? value.replace("Ctrl", "Meta")
                    : value;
            localStorage.set("defaultKeys", macDefaultKeys);
        }
    } else {
        localStorage.set("defaultKeys", defaultKeys); //TODO add a confirmation alert
    }
    addKeys("default");
};

const warnOverride = (combo, target) => {
    let x = 0;
    while ($("#preference").children()[x]) {
        if (
            $("#preference").children()[x].children[1].children[1].innerText ===
                combo &&
            $("#preference").children()[x].children[1].children[0].innerText !==
                target.previousElementSibling.innerText
        ) {
            const asignee = $("#preference").children()[x].children[1]
                .children[0].innerText;
            $("#warning").text(
                `This key(s) is already assigned to: ${asignee}, Override?`
            );
            $("#edit").css("border", "1.5px solid #dc5656");
            return;
        } else {
            $("#edit").css("border", "none");
        }
        x++;
    }
};

const elementDirecton = (direct) => () => {
    if (simulationArea.lastSelected) {
        simulationArea.lastSelected.newDirection(direct.toUpperCase());
        $("select[name |= 'newDirection']").val(direct.toUpperCase());
    }
};

const labelDirecton = (direct) => () => {
    if (
        simulationArea.lastSelected &&
        !simulationArea.lastSelected.labelDirectonFixed
    ) {
        simulationArea.lastSelected.labelDirection = direct.toUpperCase();
        $("select[name |= 'newLabelDirection']").val(direct.toUpperCase());
    }
};

const insertLabel = () => {
    if (simulationArea.lastSelected) {
        $("input[name |= 'setLabel']").focus();
        $("input[name |= 'setLabel']").val().length
            ? null
            : $("input[name |= 'setLabel']").val("Untitled");
        $("input[name |= 'setLabel']").select();
    }
};

const moveElement = (direct) => () => {
    if (simulationArea.lastSelected) {
        switch (direct) {
            case "up":
                simulationArea.lastSelected.y -= 15;
                break;
            case "down":
                simulationArea.lastSelected.y += 15;
                break;
            case "left":
                simulationArea.lastSelected.x -= 15;
                break;
            case "right":
                simulationArea.lastSelected.x += 15;
                break;
        }
    }
};

const openHotkey = () => $("#customShortcut").click();