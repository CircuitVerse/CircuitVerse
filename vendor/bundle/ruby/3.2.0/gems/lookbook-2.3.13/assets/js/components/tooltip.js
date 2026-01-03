import tippy from "../lib/tippy";

function tooltipCreator({ target }) {
  const content =
    this.$el.dataset.tooltipText ||
    (this.$refs.tooltip ? this.$refs.tooltip.innerHTML : null);
  if (content) {
    return tippy(target || this.$refs.tooltipTarget || this.$el, {
      delay: [200, 0],
      content,
      theme: "tooltip",
      triggerTarget: this.$el,
      onShow: () => this.$store.settings.showTooltips,
    });
  }
}

function initTooltip(context, opts) {
  return tooltipCreator.bind(context)(opts || {});
}

export default function tooltipComponent() {
  return {
    init() {
      initTooltip(this);
    },
  };
}

export { initTooltip };
