import {
    editPanel,
    heading,
    markUp,
    closeEdit,
    submit,
    updateHTML,
    override
} from './view/panel.ui';
import { setDefault, checkUpdate, addKeys, warnOverride } from './model/actions';
import { KeyCode } from './model/normalize/normalizer.plugin.js'
import {checkRestricted} from './model/utils.js'
import banana from '../i18n';

//** keyBinder dialog */
export function keyBinder() {
    $("#customShortcutDialog").append(editPanel);
    $("#customShortcutDialog").append(heading);
    $("#customShortcutDialog").append(markUp);
    $("#customShortcut").on('click',() => {
        closeEdit();
        $("#customShortcutDialog").dialog({
            resizable: false,
            buttons: [
                {
                    text: banana.i18n('hotkey-binder-KeyBinder-buttons-reset'),
                    click: () => {
                        if (confirm(banana.i18n('hotkey-binder-KeyBinder-remove-custom-keys')))
                            setDefault();
                    },
                    id: "resetDefault",
                },
                {
                    text: banana.i18n('save'),
                    click: () => {
                        submit();
                        $("#customShortcutDialog").dialog("close");
                    },
                    id: "submitBtn",
                },
            ],
        });
        $("#customShortcutDialog").css("display", "flex");
    });

    //** targetPref is assigned to the target key option to be edited */
    let targetPref = null;
    $("#preference").on('click',(e) => {
        $("#pressedKeys").text("");
        $("#warning").text("");
        $("#edit").css("border", "none");
        $("#edit").css("display", "block");
        $($("#edit")).focus();
        [, targetPref] = e.target.closest("div").children;

    });

    //*** Modifiers restriction enabled here */ 
    //*** below fn works in the edit panel where user enters key combo,
    //*** responsible for checking duplicate entries, overriding entries, checking restricted keys, arranging keys in
    //*** proper order, validating key combos */

    $("#edit").keydown((e) => {
        e = e || window.event;
        e.stopPropagation();
        e.preventDefault();
        var k = KeyCode;
        let modifiers = ["CTRL", "ALT", "SHIFT", "META"];
        $("#edit").css("animation", "none");
        $("#warning").text("");
        if (e.keyCode === 27) closeEdit();
        if (e.keyCode === 13) {
            if ($("#pressedKeys").text() === "") {
                $("#warning").text(banana.i18n('hotkey-binder-KeyBinder-enter-some-key'));
                $("#edit").css("animation", "shake .3s linear");
                return;
            }
            if (!checkRestricted($("#pressedKeys").text())) {
                override($("#pressedKeys").text());
                targetPref.innerText = $("#pressedKeys").text();
                $("#pressedKeys").text("");
                $("#edit").css("display", "none");
            } else {
                $("#warning").text(banana.i18n('hotkey-binder-KeyBinder-enter-different-key'));
                $("#edit").css("animation", "shake .3s linear");
                $("#pressedKeys").text("");
            }
        }
        const currentKey =
            k.hot_key(k.translate_event(e)).split("+").join(" + ") !== "Enter"
                ? k.hot_key(k.translate_event(e)).split("+").join(" + ")
                : "";
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
        if (
            ($("#pressedKeys").text().split(" + ").length === 2 &&
                ["Ctrl", "Meta"].includes(
                    $("#pressedKeys").text().split(" + ")[1]
                )) ||
            ($("#pressedKeys").text().split(" + ")[0] === "Alt" &&
                $("#pressedKeys").text().split(" + ")[1] === "Shift")
        ) {
            $("#pressedKeys").text(
                $("#pressedKeys").text().split(" + ").reverse().join(" + ")
            );
        }
        warnOverride($("#pressedKeys").text(), targetPref);
        if (checkRestricted($("#pressedKeys").text())) {
            $("#warning").text(banana.i18n('hotkey-binder-KeyBinder-default-shortcut-entered'));
        }
    });

    //**  if users closes hotkey dialog by making changes & not saving them, fn will fallback to previous state */

    $('div#customShortcutDialog').on('dialogclose', function(event) {
        if (localStorage.userKeys) {
            updateHTML("user");
        } else updateHTML("default");
    });

    // Set up shortcuts
    if (localStorage.userKeys) {
        checkUpdate();
        addKeys("user");
    } else setDefault();
}