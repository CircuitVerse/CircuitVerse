import tippy from "~/assets/js/lib/tippy";
import { initTooltip } from "~/assets/js/components/tooltip";

export default function buttonComponent() {
  let tooltip = null;
  let dropdown = null;

  return {
    init() {
      if (this.$refs.tooltip) {
        tooltip = initTooltip(this, {
          target: this.$refs.icon,
        });
      }

      if (this.dropdownContent) {
        this.initDropdown();
      }
    },

    initDropdown() {
      dropdown = tippy(this.$el, {
        content: this.dropdownContent,
        trigger: "click",
        theme: "menu",
        triggerTarget: this.$el,
        interactive: true,
        zIndex: 99999,
        onShow: () => {
          if (!this.$store.settings.showTooltips) {
            return false;
          }
          this.$dispatch("dropdown:show", { dropdown: this });
        },
        onHide: () => this.$dispatch("dropdown:hide", { dropdown: this }),
      });
    },

    get dropdownContent() {
      if (this.$root && this.$root.id) {
        const dropdown = document.querySelector(
          `[data-dropdown-id="${this.$root.id}"]`
        );
        return dropdown ? dropdown.innerHTML : null;
      }
      return null;
    },

    hideDropdown() {
      if (dropdown) {
        dropdown.hide();
      }
    },

    startSpin() {
      this._spinning = true;
    },

    stopSpin(delay = 0) {
      setTimeout(() => (this._spinning = false), delay);
    },

    get _tooltip() {
      return tooltip;
    },

    _spinning: false,
  };
}
