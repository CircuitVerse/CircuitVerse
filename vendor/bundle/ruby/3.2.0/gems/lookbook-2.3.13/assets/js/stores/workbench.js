import initFilterStore from "./filter";
import { prefixString } from "../helpers/string";

export default function initWorkbenchStore(Alpine, { prefix }) {
  return {
    filter: initFilterStore(Alpine, prefixString("workbench-filter", prefix)),
    nav: {
      open: Alpine.$persist([]).as(prefixString("workbench-nav-open", prefix)),
      location: {
        pathname: null,
      },
    },
    horizontalSplitLayout: {
      split: Alpine.$persist({
        direction: "horizontal",
        sizes: ["50%", "50%"],
      }).as(prefixString("workbench-horizontal-split", prefix)),
    },
    verticalSplitLayout: {
      split: Alpine.$persist({
        direction: "vertical",
        sizes: ["40%", "30%", "30%"],
      }).as(prefixString("workbench-vertical-split", prefix)),
    },
    tabbedPanels: {
      activeTab: "tab-1",
    },
  };
}
