import { observeSize } from "@helpers/layout";

export default function paramsEditorComponent() {
  return {
    narrow: false,
    init() {
      observeSize(this.$el, ({ width }) => {
        this.narrow = width < 500;
      });
    },
  };
}
