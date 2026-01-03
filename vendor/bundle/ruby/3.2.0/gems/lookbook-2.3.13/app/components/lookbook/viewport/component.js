export default function viewportComponent(store) {
  store = store || { width: "100%", height: "100%" };
  store.resizing = false;

  return {
    store,

    get maxWidth() {
      return this.store.width === "100%" ? "100%" : `${store.width}px`;
    },

    get maxHeight() {
      return this.store.height === "100%" ? "100%" : `${store.height}px`;
    },

    get parentWidth() {
      return Math.round(this.$root.clientWidth);
    },

    get parentHeight() {
      return Math.round(this.$root.clientHeight);
    },

    get reflowing() {
      return this.$store.layout.reflowing;
    },

    reloadIframe() {
      this.$refs.iframe.contentWindow.location.reload();
    },

    start() {
      this.$dispatch("viewport:resize-start", this._resizeData);
      this.$store.layout.reflowing = true;
      this.store.resizing = true;
    },

    end() {
      this.$store.layout.reflowing = false;
      this.store.resizing = false;
      this.$dispatch("viewport:resize-complete", this._resizeData);
    },

    onResizeStart(e) {
      this.onResizeWidthStart(e);
      this.onResizeHeightStart(e);
    },

    toggleFullSize() {
      const { height, width } = store;
      if (height === "100%" && width === "100%") {
        this.toggleFullHeight();
        this.toggleFullWidth();
      } else {
        if (height !== "100%") this.toggleFullHeight();
        if (width !== "100%") this.toggleFullWidth();
      }
    },

    onResizeWidth(e) {
      const width =
        this.resizeStartWidth - (this.resizeStartPositionX - e.pageX) * 2;
      const boundedWidth = Math.min(
        Math.max(Math.round(width), 200),
        this.parentWidth
      );
      this.store.width =
        boundedWidth === this.parentWidth ? "100%" : boundedWidth;
      this.$dispatch("viewport:resize-progress", this._resizeData);
    },

    onResizeWidthStart(e) {
      this.start();
      this.onResizeWidth = this.onResizeWidth.bind(this);
      this.onResizeWidthEnd = this.onResizeWidthEnd.bind(this);
      this.resizeStartPositionX = e.pageX;
      this.resizeStartWidth = this.$refs.wrapper.clientWidth;
      window.addEventListener("pointermove", this.onResizeWidth);
      window.addEventListener("pointerup", this.onResizeWidthEnd);
    },

    onResizeWidthEnd() {
      window.removeEventListener("pointermove", this.onResizeWidth);
      window.removeEventListener("pointerup", this.onResizeWidthEnd);
      this.end();
    },

    toggleFullWidth() {
      this.$dispatch("viewport:resize-start", this._resizeData);
      const { width, lastWidth } = store;
      if (width === "100%" && lastWidth) {
        this.store.width = lastWidth;
      } else {
        this.store.lastWidth = width;
        this.store.width = "100%";
      }
      this.$dispatch("viewport:resize-complete", this._resizeData);
    },

    onResizeHeight(e) {
      const height =
        this.resizeStartHeight - (this.resizeStartPositionY - e.pageY);
      const boundedHeight = Math.min(
        Math.max(Math.round(height), 200),
        this.parentHeight
      );
      this.store.height =
        boundedHeight === this.parentHeight ? "100%" : boundedHeight;
      this.$dispatch("viewport:resize-progress", this._resizeData);
    },

    onResizeHeightStart(e) {
      this.start();
      this.onResizeHeight = this.onResizeHeight.bind(this);
      this.onResizeHeightEnd = this.onResizeHeightEnd.bind(this);
      this.resizeStartPositionY = e.pageY;
      this.resizeStartHeight = this.$refs.wrapper.clientHeight;
      window.addEventListener("pointermove", this.onResizeHeight);
      window.addEventListener("pointerup", this.onResizeHeightEnd);
    },

    onResizeHeightEnd() {
      window.removeEventListener("pointermove", this.onResizeHeight);
      window.removeEventListener("pointerup", this.onResizeHeightEnd);
      this.end();
    },

    toggleFullHeight() {
      this.$dispatch("viewport:resize-start", this._resizeData);
      const { height, lastHeight } = store;
      if (height === "100%" && lastHeight) {
        this.store.height = lastHeight;
      } else {
        this.store.lastHeight = height;
        this.store.height = "100%";
      }
      this.$dispatch("viewport:resize-complete", this._resizeData);
    },

    // protected

    get _resizeData() {
      return {
        width: this.store.width,
        height: this.store.height,
        viewport: this,
      };
    },
  };
}
