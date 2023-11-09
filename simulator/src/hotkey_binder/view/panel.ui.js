import { defaultKeys } from '../defaultKeys';
import { setUserKeys } from '../model/actions';

/**
 * function to generate the specific HTML for the hotkey panel
 * @param {object} metadata keycombo object
 */
const createElements = (metadata) => {
    let elements = ``;
    Object.entries(metadata).forEach((entry) => {
        elements += `
        <div>
        <span id='edit-icon'></span>
        <div><span id='command'>${entry[0]}</span>
        <span id='keyword'></span>
        </div>
    </div>
    `;
    });
    return `<div id="preference" class="customScroll">${elements}</div>`;
};

export const markUp = createElements(defaultKeys);

export const editPanel = `<div id="edit" tabindex="0">
<span style="font-size: 14px;">Press Desire Key Combination & press Enter or press ESC to cancel.</span>
<div id="pressedKeys"></div>
<div id="warning"></div>
</div>`;

export const heading = `<div id="heading">
  <span>Command</span>
  <span>Keymapping</span>
</div>`;

/**
 * fn to update the htokey panel UI with the currently set configuration
 * @param {string} mode user prefered if present, or default keys configuration
 */
export const updateHTML = (mode) => {
    let x = 0;
    if (mode == "user") {
        const userKeys = localStorage.get("userKeys");
        while ($("#preference").children()[x]) {
            $("#preference").children()[x].children[1].children[1].innerText =
                userKeys[
                    $("#preference").children()[x]
                .children[1].children[0].innerText
            ];
            x++;
        }
    } else if (mode == "default") {
        while ($("#preference").children()[x]) {
            const defaultKeys = localStorage.get("defaultKeys");
            $("#preference").children()[x].children[1].children[1].innerText =
                defaultKeys[
                    $("#preference").children()[x]
                    .children[1].children[0].innerText
                ];
            x++;
        }
    }
};
/**
 * fn to override key of duplicate entries
 * old entry will be left blank & keys will be assigned to the new target
 * @param {*} combo 
 */
export const override = (combo) => {
    let x = 0;
    while ($("#preference").children()[x]) {
        if (
            $("#preference").children()[x]
            .children[1].children[1].innerText === combo
            )
            $("#preference").children()[x]
            .children[1].children[1].innerText = "";
        x++;
    }
};

export const closeEdit = () => {
    $("#pressedKeys").text("");
    $("#edit").css("display", "none");
};

export const submit = () => {
    $("#edit").css("display", "none");
    setUserKeys();
    updateHTML("user");
};
