export default function navComponent(store) {
  return {
    empty: false,

    children: [],

    init() {
      this.children = this.$refs.items
        ? Array.from(this.$refs.items.children)
        : [];
    },

    isOpen(id) {
      return store.open.includes(id);
    },

    setOpen(id) {
      store.open.push(id);
    },

    setClosed(id) {
      const index = store.open.indexOf(id);
      if (index > -1) {
        store.open.splice(index, 1);
      }
    },

    closeAll() {
      store.open.length = 0;
    },

    toggleOpen(id) {
      this.isOpen(id) ? this.setClosed(id) : this.setOpen(id);
    },

    async filter(text) {
      this.debug(`Filter text: ${text}`);

      await this.$nextTick();
      const filteredStates = await Promise.all(
        this.children.map(async (child) => {
          const data = Alpine.$data(child);
          await data.filter(text);
          return data.filteredOut;
        })
      );

      const matchedChildCount = filteredStates.filter((s) => !s).length;
      this.empty = matchedChildCount === 0;

      this.debug(
        `Children matching filter: ${matchedChildCount}/${this.children.length}`
      );
    },
  };
}
