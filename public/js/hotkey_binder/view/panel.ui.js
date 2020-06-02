const markUp = `<div id="preference">
<div class="options">
    <span>New Project</span>
    <span></span>
</div>
<div class="options">
    <span>Save Online</span>
    <span></span>
</div>
<div class="options">
    <span>Save Offline</span>
    <span></span>
</div>
<div class="options">
    <span>Download as Image</span>
    <span></span>
</div>
<div class="options">
    <span>Open Offline</span>
    <span></span>
</div>
<div class="options">
    <span>Recover Project</span>
    <span></span>
</div>
<div class="options">
    <span>New Circuit</span>
    <span></span>
</div>
<div class="options">
    <span>Create Sub-ciruit</span>
    <span></span>
</div>
<div class="options">
    <span>Combinational Analysis</span>
    <span></span>
</div>
<div class="options">
    <span>Start Plot</span>
    <span></span>
</div>
</div>
`;

const editPanel = `<div id="edit" tabindex="0">
<span style="font-size: 14px;">Press Desire Key Combination and press Enter or press ESC to cancel.</span>
<div id="pressedKeys"></div>
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
        defaultKeys[$("#preference").children()[x].children[0].innerText];
      x++;
    }
  }
};
