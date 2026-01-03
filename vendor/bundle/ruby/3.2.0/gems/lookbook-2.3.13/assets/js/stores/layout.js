import config from "../config";
import { addMediaQueryListener } from "../helpers/layout";
import { log } from "../plugins/logger";
import { prefixString } from "../helpers/string";

const { sidebar, main, inspector } = config;

export default function initLayoutStore(Alpine, { prefix }) {
  return {
    init() {
      addMediaQueryListener(
        `(min-width: ${config.desktopWidth}px)`,
        (matches) => {
          this._isDesktop = matches;
          log.debug(
            `Media query 'desktop': ${matches ? "✅ match" : "❌ no match"}`
          );
        }
      );
    },

    get desktop() {
      return this._isDesktop;
    },

    get mobile() {
      return !this.desktop;
    },

    reflowing: false,

    // Main app sidebar/content layout
    main: {
      split: Alpine.$persist({
        direction: "vertical",
        sizes: [`${sidebar.defaultWidth}px`, "1fr"],
      }).as(prefixString("main-split", prefix)),

      opts: {
        minSizes: [sidebar.minWidth, main.minWidth],
      },
    },

    // Sidebar visibility and sections
    sidebar: {
      _hiddenDesktop: Alpine.$persist(false).as(
        prefixString("sidebar-hidden-desktop", prefix)
      ),

      _hiddenMobile: Alpine.$persist(true).as(
        prefixString("sidebar-hidden-mobile", prefix)
      ),

      set hidden(value) {
        if (Alpine.store("layout").desktop) {
          this._hiddenDesktop = value;
        } else {
          this._hiddenMobile = value;
        }
      },

      get hidden() {
        const isDesktop = Alpine.store("layout").desktop;
        return (
          (isDesktop && this._hiddenDesktop) ||
          (!isDesktop && this._hiddenMobile)
        );
      },

      split: Alpine.$persist({
        direction: "horizontal",
        sizes: ["50%", "50%"],
      }).as(prefixString("sidebar-split", prefix)),

      opts: {
        minSizes: [sidebar.minSectionHeight, sidebar.minSectionHeight],
      },
    },

    singleSectionSidebar: {
      split: {
        direction: "horizontal",
        sizes: null,
      },
    },

    // Inspector drawer/preview layout
    inspector: {
      split: Alpine.$persist({
        direction: "horizontal",
        horizontalSizes: ["1fr", `${inspector.drawer.defaultHeight}px`],
        verticalSizes: ["1fr", `${inspector.drawer.defaultWidth}px`],
      }).as(prefixString("inspector-split", prefix)),

      opts: {
        minVerticalSizes: [
          inspector.drawer.minWidth,
          inspector.drawer.minWidth,
        ],
        minHorizontalSizes: [
          inspector.drawer.minHeight,
          inspector.drawer.minHeight,
        ],
      },
    },

    // protected

    _isDesktop: true,
  };
}
