// func to generate html from json
const createElements = (metadata) => {
    let elements = ``;
    Object.entries(metadata).forEach((entry) => {
        elements += `<div>
    <span>${entry[0]}</span>
    <span></span>
    </div>
    `;
    });
    return `<div id="preference">${elements}</div>`;
};

const markUp = createElements(defaultKeys);

const editPanel = `<div id="edit" tabindex="0">
<span style="font-size: 14px;">Press Desire Key Combination and press Enter or press ESC to cancel.</span>
<div id="pressedKeys"></div>
<div id="warning"></div>
</div>`;

const heading = `<div id="heading">
  <span>Command</span>
  <span>Keymapping</span>
</div>`;

const updateHTML = (mode) => {
    let x = 0;
    if (mode == "user") {
        let userKeys = localStorage.get("userKeys");
        while ($("#preference").children()[x]) {
            $("#preference").children()[x].children[1].innerText =
                userKeys[$("#preference").children()[x].children[0].innerText];
            x++;
        }
    } else if (mode == "default") {
        while ($("#preference").children()[x]) {
            $("#preference").children()[x].children[1].innerText =
                defaultKeys[
                    $("#preference").children()[x].children[0].innerText
                ];
            x++;
        }
    }
};

const override = (combo) => {
    let x = 0;
    while ($("#preference").children()[x]) {
        if ($("#preference").children()[x].children[1].innerText === combo)
            $("#preference").children()[x].children[1].innerText = "";
        x++;
    }
};

const closeEdit = () => {
    $("#pressedKeys").text("");
    $("#edit").css("display", "none");
};

const submit = () => {
    $("#edit").css("display", "none");
    setUserKeys();
    updateHTML("user");
};
