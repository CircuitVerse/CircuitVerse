import { prefixString } from "../helpers/string";

export default function initInspectorStore(Alpine, { prefix }) {
  return {
    minVerticalSplitWidth: 800,

    main: {
      activeTab: Alpine.$persist("").as(
        prefixString("inspector-main-active-tab", prefix)
      ),
      width: Alpine.$persist("100%").as(
        prefixString("inspector-main-width", prefix)
      ),
      height: Alpine.$persist("100%").as(
        prefixString("inspector-main-height", prefix)
      ),
      lastWidth: null,
      lastHeight: null,
      resizing: false,
    },

    drawer: {
      hidden: Alpine.$persist(false).as(
        prefixString("inspector-drawer-hidden", prefix)
      ),
      activeTab: Alpine.$persist("").as(
        prefixString("inspector-drawer-active-tab", prefix)
      ),
    },
  };
}
