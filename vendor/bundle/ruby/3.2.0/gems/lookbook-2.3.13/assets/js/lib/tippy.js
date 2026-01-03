import tippy from "tippy.js";

tippy.setDefaultProps({
  allowHTML: true,
  theme: "tooltip",
  appendTo: document.getElementById("app"),
});

export default tippy;
