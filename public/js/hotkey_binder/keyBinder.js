$("#customShortcutDialog").append(editPanel);
$("#customShortcutDialog").append(heading);
$("#customShortcutDialog").append(markUp);

$("#customShortcut").click(() => {
  $("#customShortcutDialog").dialog({
    buttons: [
      {
        text: "Reset to default",
        click: () => setDefault(),
        id: "resetDefault",
      },
      {
        text: "Save",
        click: () => submit(),
        id: "submitBtn",
      },
    ],
  });
});

let targetPref = null;
$("#preference").click((e) => {
  $("#pressedKeys").innerText = "";
  $("#edit").css("display", "block");
  $(function () {
    $("#edit").focus();
  });
  targetPref = e.target.closest("div").children[1];
});

$("#edit").keydown((e) => {
  e = e || window.event;
  if (e.keyCode == 27) {
    $("#pressedKeys").text("");
    $("#edit").css("display", "none");
  }
  if (!$("#pressedKeys").text()) {
    $("#pressedKeys").text(keyCodes[e.keyCode]);
  } else {
    $("#pressedKeys").append(` + ${keyCodes[e.keyCode]}`);
  }

  if (e.keyCode == 13) {
    $("#edit").css("display", "none");
    targetPref.innerText = $("#pressedKeys")
      .innerText.substring(0, $("#pressedKeys").innerText.length - 2)
      .toUpperCase();
    $("#pressedKeys").innerText = "";
  }
});

const submit = () => {
  $("#edit").css("display", "none");
  setUserKeys();
  updateHTML();
};

//IFFE
(() => {
  setDefault();
  if (localStorage.userKeys) addKeys("user");
})();
