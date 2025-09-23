import { decodeEntities } from "../helpers/string";

function initClipboard(context = {}) {
  let copyTimeout = null;

  return Object.assign(context, {
    copied: false,

    async copyToClipboard(target = null) {
      let targetEl;
      if (this.$refs.copyTarget) {
        targetEl = this.$refs.copyTarget;
      } else if (typeof target === "string") {
        targetEl = document.querySelector(target);
      }

      if (!targetEl) {
        this.warn("Could not find copy target");
        return false;
      }

      const content = decodeEntities(targetEl.innerHTML.trim());

      await window.navigator.clipboard.writeText(content);
      this.copied = true;

      if (copyTimeout) {
        clearTimeout(copyTimeout);
      }

      copyTimeout = setTimeout(() => {
        this.copied = false;
        this.onCopyComplete();
      }, 1000);

      return content;
    },

    onCopyComplete() {},
  });
}

export default function clipboardComponent() {
  return initClipboard({});
}

export { initClipboard };
