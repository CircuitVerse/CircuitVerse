import { defaultKeys } from '../defaultKeys';
import { addShortcut } from './addShortcut';
import { updateHTML } from '../view/panel.ui';
import simulationArea from '../../simulationArea';
import {
    scheduleUpdate, update, updateSelectionsAndPane,
    wireToBeCheckedSet, updatePositionSet, updateSimulationSet,
    updateCanvasSet, gridUpdateSet, errorDetectedSet,
} from '../../engine';

import { getOS, storageGet, storageSet, objectSize } from './utils.js';
import {shortcut} from './shortcuts.plugin.js'
/**
 * Function used to add or change keys user or default
 * grabs the keycombo from localstorage &
 * calls the addShortcut function in a loop to bind them
 * @param {string} mode - user custom keys or default keys
 */
export const addKeys = (mode) => {
    shortcut.removeAll();
    if (mode === "user") {
        localStorage.removeItem("defaultKeys");
        let userKeys = storageGet(localStorage, "userKeys");
        for (let pref in userKeys) {
            let key = userKeys[pref];
            key = key.split(" ").join("");
            addShortcut(key, pref);
        }
        updateHTML("user");
    } else if (mode == "default") {
        if (localStorage.userKeys) localStorage.removeItem("userKeys");
        let defaultKeys = storageGet(localStorage, "defaultKeys");
        for (let pref in defaultKeys) {
            let key = defaultKeys[pref];
            key = key.split(" ").join("");
            addShortcut(key, pref);
        }
        updateHTML("default");
    }
};
/**
 * Function used to check if new keys are added, adds missing keys if added
 */
export const checkUpdate = () => {
    const userK = storageGet(localStorage, "userKeys");
    if (objectSize(userK) !== objectSize(defaultKeys)) {
        for (const [key, value] of Object.entries(defaultKeys)) {
            if (!Object.keys(userK).includes(key)) {
                userK[key] = value;
            }
        }
        storageSet(localStorage, "userKeys", userK);
    } else {
        return;
    }
};
/**
 * Function used to set userKeys, grabs the keycombo from the panel UI
 * sets it to the localStorage & calls addKeys
 * removes the defaultkeys from localStorage
 */
export const setUserKeys = () => {
    if (localStorage.defaultKeys) localStorage.removeItem('defaultKeys');
    let userKeys = {};
    let x = 0;
    while ($("#preference").children()[x]) {
        userKeys[$("#preference").children()[x].children[1].children[0].innerText] = $(
            "#preference"
        ).children()[x].children[1].children[1].innerText;
        x++;
    }
    storageSet(localStorage, "userKeys", userKeys);
    addKeys("user");
};
/**
 * Function used to set defaultKeys, grabs the key combo from the defaultkeys metadata
 * sets it to the localStorage & cals addKeys
 * removes the userkeys from localStorage if present
 * also checks for OS type
 */
export const setDefault = () => {
    if (localStorage.userKeys) localStorage.removeItem('userKeys');
    if (getOS() === "MacOS") {
        const macDefaultKeys = {};
        for (let [key, value] of Object.entries(defaultKeys)) {
            macDefaultKeys[key] =
                value.split(" + ")[0] === "Ctrl"
                    ? value.replace("Ctrl", "Meta")
                    : value;
        }
        storageSet(localStorage, "defaultKeys", macDefaultKeys);
    } else {
        storageSet(localStorage, "defaultKeys", defaultKeys); //TODO add a confirmation alert
    }
    addKeys("default");
};
/**
 * function to check if user entered keys are already assigned to other key
 * gives a warning message if keys already assigned
 * @param {string} combo the key combo
 * @param {string} target the target option of the panel
 */
export const warnOverride = (combo, target) => {
    let x = 0;
    while ($("#preference").children()[x]) {
        if (
            $("#preference").children()[x].children[1].children[1].innerText ===
                combo &&
            $("#preference").children()[x].children[1].children[0].innerText !==
                target.previousElementSibling.innerText
        ) {
            const assignee = $("#preference").children()[x].children[1]
                .children[0].innerText;
            $("#warning").text(
                `This key(s) is already assigned to: ${assignee}, press Enter to override.`
            );
            $("#edit").css("border", "1.5px solid #dc5656");
            return;
        } else {
            $("#edit").css("border", "none");
        }
        x++;
    }
};

export const elementDirection = (direct) => () => {
    if (simulationArea.lastSelected) {
        simulationArea.lastSelected.newDirection(direct.toUpperCase());
        $("select[name |= 'newDirection']").val(direct.toUpperCase());
        updateSystem();
    }
};

export const labelDirection = (direct) => () => {
    if (
        simulationArea.lastSelected &&
        !simulationArea.lastSelected.labelDirectionFixed
    ) {
        simulationArea.lastSelected.labelDirection = direct.toUpperCase();
        $("select[name |= 'newLabelDirection']").val(direct.toUpperCase());
        updateSystem();
    }
};

export const insertLabel = () => {
    if (simulationArea.lastSelected) {
        $("input[name |= 'setLabel']").focus();
        $("input[name |= 'setLabel']").val().length
            ? null
            : $("input[name |= 'setLabel']").val("Untitled");
        $("input[name |= 'setLabel']").select();
        updateSystem();
    }
};

export const moveElement = (direct) => () => {
    if (simulationArea.lastSelected) {
        switch (direct) {
            case "up":
                simulationArea.lastSelected.y -= 10;
                break;
            case "down":
                simulationArea.lastSelected.y += 10;
                break;
            case "left":
                simulationArea.lastSelected.x -= 10;
                break;
            case "right":
                simulationArea.lastSelected.x += 10;
                break;
        }
        updateSystem();
    }
};

export const openHotkey = () => $("#customShortcut").trigger('click');

export const newCircuitCall = () => $("#newCircuit").trigger('click');

export const openDocumentation = () => {
    if (simulationArea.lastSelected == undefined || simulationArea.lastSelected.helplink == undefined) {
        // didn't select any element or documentation not found
        window.open("https://docs.circuitverse.org/", "_blank");
    } else {
        window.open(simulationArea.lastSelected.helplink, "_blank");
    }
}

function updateSystem() {
    updateCanvasSet(true);
    wireToBeCheckedSet(1);
    scheduleUpdate(1);
}