import Alpine from "alpinejs";

import Morph from "@alpinejs/morph";
import Persist from "@alpinejs/persist";
import Collapse from "@alpinejs/morph";
import Tooltip from "@ryangjchandler/alpine-tooltip";

import Logger, { log } from "./plugins/logger";

import initLayoutStore from "./stores/layout";
import initNavStore from "./stores/nav";
import initInspectorStore from "./stores/inspector";
import initPagesStore from "./stores/pages";
import initSettingsStore from "./stores/settings";
import initWorkbenchStore from "./stores/workbench";

import app from "./app";

// Note: A ParcelJS issue prevents loading all depths of component JS files in one glob,
// so need to split it up. Path aliases also do not work with the glob imports.
import { getComponents } from "./helpers/build";
import * as components from "../../app/components/lookbook/*/*component.js";
import * as subComponents from "../../app/components/lookbook/*/*/component.js";
import * as jsComponents from "./components/*.js";

// Plugins

Alpine.plugin(Morph);
Alpine.plugin(Persist);
Alpine.plugin(Collapse);
Alpine.plugin(Tooltip);
Alpine.plugin(Logger);

// Stores
const prefix = window.APP_NAME;
Alpine.store("layout", initLayoutStore(Alpine, { prefix }));
Alpine.store("nav", initNavStore(Alpine, { prefix }));
Alpine.store("inspector", initInspectorStore(Alpine, { prefix }));
Alpine.store("pages", initPagesStore(Alpine, { prefix }));
Alpine.store("settings", initSettingsStore(Alpine, { prefix }));

if (process.env.NODE_ENV !== "production") {
  Alpine.store("workbench", initWorkbenchStore(Alpine, { prefix }));
}

// Components

Alpine.data("app", app);

[components, subComponents, jsComponents].forEach((scripts) => {
  const components = getComponents(scripts);
  Object.keys(components).forEach((name) => {
    Alpine.data(`${name}Component`, components[name]);
  });
});

// Init

window.log = log;
window.Alpine = Alpine;
Alpine.start();
