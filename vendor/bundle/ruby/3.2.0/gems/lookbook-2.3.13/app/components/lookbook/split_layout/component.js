import Split from "split-grid";
import { observeSize } from "@helpers/layout";

export default function splitLayoutComponent({ split, opts = {} }) {
  let splitter = null;
  const shouldSplit = split.sizes !== null;

  return {
    layoutResizing: false,

    layoutWidth: null,

    layoutHeight: null,

    forceOrientation: null,

    get vertical() {
      if (this.forceOrientation) {
        return this.forceOrientation === "vertical";
      }
      return split.direction === "vertical";
    },

    get horizontal() {
      if (this.forceOrientation) {
        return this.forceOrientation === "horizontal";
      }
      return split.direction === "horizontal";
    },

    get splits() {
      if (this.horizontal && split.horizontalSizes) {
        return split.horizontalSizes;
      } else if (this.vertical && split.verticalSizes) {
        return split.verticalSizes;
      } else {
        return split.sizes || [];
      }
    },

    get minSizes() {
      if (this.horizontal && opts.minHorizontalSizes) {
        return opts.minHorizontalSizes;
      } else if (this.vertical && opts.minVerticalSizes) {
        return opts.minVerticalSizes;
      } else {
        return opts.minSizes || [];
      }
    },

    init() {
      observeSize(this.$el, ({ width, height }) => {
        this.layoutWidth = width;
        this.layoutHeight = height;
      });
    },

    switchOrientation() {
      split.direction = this.vertical ? "horizontal" : "vertical";
    },

    registerGutter() {
      this._gutters.push(this.$el);
    },

    initSplit() {
      if (shouldSplit && this._gutters.length) {
        this._destroySplit();
        const dir = this.horizontal ? "row" : "column";
        splitter = Split({
          [`${dir}Gutters`]: gutterSplits(this._gutters),
          [`${dir}MinSizes`]: sizeSplits(this.minSizes),
          snapOffset: 0,
          dragInterval: 1,
          writeStyle() {},
          onDrag: (dir, gutterTrack, style) => {
            const splits = style
              .split(" ")
              .map((value, i) => (i % 2 == 0 ? value : null))
              .filter((v) => v);
            this._setSplits(splits);
          },
          onDragStart: () => {
            this.layoutResizing = true;
            this.$dispatch("layout:resize-start", { layout: this });
          },
          onDragEnd: () => {
            this.layoutResizing = false;
            this.$dispatch("layout:resize-end", { layout: this });
          },
        });
      }
    },

    bindings: {
      root: {
        [":style"]() {
          return {
            "grid-template-columns":
              shouldSplit && this.vertical && sizeStr(this.splits),
            "grid-template-rows":
              shouldSplit && this.horizontal && sizeStr(this.splits),
          };
        },
      },
    },

    // protected

    _gutters: [],

    _destroySplit() {
      if (splitter) splitter.destroy();
    },

    _setSplits(splits) {
      if (this.horizontal && split.horizontalSizes) {
        split.horizontalSizes = splits;
      } else if (this.vertical && split.verticalSizes) {
        split.verticalSizes = splits;
      } else {
        split.sizes = splits;
      }
    },
  };
}

// utils

function sizeStr(sizes) {
  const values = [];
  sizes.forEach((size) => values.push(size, "1px"));
  return values.slice(0, -1).join(" ");
}

function gutterSplits(gutters) {
  return gutters.map((element, i) => {
    return {
      track: i * 2 + 1,
      element,
    };
  });
}

function sizeSplits(sizes) {
  const splits = {};
  sizes.forEach((value, i) => {
    if (value !== null) splits[i * 2] = value;
  });
  return splits;
}
