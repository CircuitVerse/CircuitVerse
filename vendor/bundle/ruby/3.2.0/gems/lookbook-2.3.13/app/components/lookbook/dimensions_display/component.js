import { observeSize } from "@helpers/layout";

export default function dimensionsDisplayComponent(targetSelector) {
  return {
    width: 0,
    height: 0,
    resizing: false,
    target: null,

    init() {
      this.target = document.querySelector(targetSelector);
      if (this.target) {
        this.width = Math.round(this.target.clientWidth);
        this.height = Math.round(this.target.clientHeight);
        this.createObserver();
      }
    },

    createObserver() {
      if (this.target) {
        this.observer = observeSize(this.target, ({ width, height }) => {
          this.width = width;
          this.height = height;
        });
      }
    },

    tearDown() {
      if (this.observer) {
        this.observer.disconnect();
      }
    },
  };
}
