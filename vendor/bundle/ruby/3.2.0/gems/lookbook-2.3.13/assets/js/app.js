import createSocket from "./lib/socket";
import { morph } from "./helpers/dom";
import { fetchHTML } from "./helpers/request";
import { isExternalLink } from "./helpers/dom";

export default function app() {
  return {
    _requestsInProgress: 0,

    version: Alpine.$persist("").as("lookbook-version"),

    location: window.location,

    get sidebarHidden() {
      return this.$store.layout.sidebar.hidden;
    },

    get loading() {
      return this._requestsInProgress > 0;
    },

    init() {
      if (window.SOCKET_PATH) {
        this.debug(`Lookbook socket created`);
        const socket = createSocket(window.SOCKET_PATH);
        socket.addListener("Lookbook::ReloadChannel", () => this.updateDOM());
      }

      this.$watch("$store.layout.mobile", (mobile) => {
        if (!mobile) {
          this.$store.layout.sidebar.hidden = true;
        }
      });
    },

    navigateTo(path) {
      this.debug(`Navigating to ${path}`);
      history.pushState({}, null, path);
      this.$dispatch("popstate");
    },

    async handleNavigation() {
      this.debug("Navigating to ", window.location.pathname);
      this.$dispatch("navigation:start");
      this.location = window.location;
      await this.updateDOM("#app-main", {
        headers: { "X-Lookbook-Frame": "main" },
      });
      this.$dispatch("navigation:complete");
    },

    hijax(evt) {
      const link = evt.target.closest("a[href]");
      if (link) {
        const external = isExternalLink(link);
        const embedded = this.isEmbedded();

        if (embedded && (!link.hasAttribute("target") || external)) {
          evt.preventDefault();
          window.top.location = link.href;
          return;
        } else if (!embedded && !external && !link.hasAttribute("target")) {
          evt.preventDefault();
          this.navigateTo(link.href);
          return;
        }
      }
    },

    async updateDOM(rootSelector = `#${this.$root.id}`, options = {}) {
      this.debug("Starting DOM update");
      this.$dispatch("dom:update-start");
      this.requestStart();
      try {
        const { fragment, title } = await fetchHTML(
          window.location,
          rootSelector,
          options
        );
        morph(document.querySelector(rootSelector), fragment);
        document.title = title;
        this.requestEnd();
        this.$dispatch("dom:update-complete");
        this.debug("DOM update complete");
      } catch (err) {
        this.error(err);
        window.location.reload();
      }
    },

    toggleSidebar() {
      this.$store.layout.sidebar.hidden = !this.$store.layout.sidebar.hidden;
    },

    closeMobileSidebar() {
      if (this.$store.layout.mobile && !this.sidebarHidden) {
        this.toggleSidebar();
      }
    },

    requestStart() {
      this._requestsInProgress += 1;
    },

    requestEnd() {
      if (this._requestsInProgress > 0) {
        this._requestsInProgress -= 1;
      }
    },

    isEmbedded() {
      try {
        return window.self !== window.top;
      } catch (e) {
        return true;
      }
    },

    ...Alpine.$log,
  };
}
