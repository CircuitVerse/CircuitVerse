/* eslint-disable quotes */
/* eslint-disable indent */
/* eslint-disable linebreak-style */

$("#customShortcutDialog").append(editPanel);
$("#customShortcutDialog").append(heading);
$("#customShortcutDialog").append(markUp);

$("#customShortcut").click(() => {
    closeEdit(); // if edit is showing, close it
    $("#customShortcutDialog").dialog({
        buttons: [
            {
                text: "Reset to default",
                click: () => setDefault(),
                id: "resetDefault",
            },
            {
                text: "Save",
                click: () => {
                    submit();
                    $("#customShortcutDialog").dialog("close");
                },
                id: "submitBtn",
            },
        ],
    });
});

let targetPref = null;
$("#preference").click((e) => {
    $("#pressedKeys").text("");
    $("#warning").text("");

    $("#edit").css("display", "block");
    $($("#edit")).focus();
    [, targetPref] = e.target.closest("div").children;
});

// Modifiers restriction enabled here
$("#edit").keydown((e) => {
    e.stopPropagation();
    let modifiers = ["CTRL", "ALT", "SHIFT"];
    if (e.keyCode === 27) closeEdit();
    if (e.keyCode === 13) {
        override($("#pressedKeys").text());
        targetPref.innerText = $("#pressedKeys").text();
        $("#pressedKeys").text("");
        $("#edit").css("display", "none");
    }
    $("#warning").text("");
    const currentKey = keyCodes[e.keyCode].toUpperCase();
    if (
        $("#pressedKeys").text().split(" + ").length === 2 &&
        !modifiers.includes(currentKey) &&
        modifiers.includes($("#pressedKeys").text().split(" + ")[1])
    ) {
        $("#pressedKeys").append(` + ${currentKey}`);
    } else if (modifiers.includes($("#pressedKeys").text())) {
        modifiers = modifiers.filter((mod) => mod === $("#pressedKeys").text());
        if (!modifiers.includes(currentKey)) {
            $("#pressedKeys").append(` + ${currentKey}`);
        }
    } else {
        $("#pressedKeys").text("");
        $("#pressedKeys").text(currentKey);
    }
    if (!$("#pressedKeys").text()) {
        $("#pressedKeys").text(currentKey);
    }
    warnOverride($("#pressedKeys").text());
});

//  IFFE
(() => {
    setDefault();
    if (localStorage.userKeys) addKeys("user");
})();
