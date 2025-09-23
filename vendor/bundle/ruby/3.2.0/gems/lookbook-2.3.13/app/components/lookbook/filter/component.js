export default function filterComponent(store) {
  return {
    focussed: false,
    get active() {
      return store.active;
    },
    get text() {
      return store.text;
    },
    clear() {
      if (store.raw === "") {
        this.$refs.input.blur();
      } else {
        store.raw = "";
      }
    },
    focus() {
      this.$refs.input.focus();
    },
  };
}
