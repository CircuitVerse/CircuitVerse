export default function tabPanelsComponent(store) {
  return {
    get store() {
      return store || this;
    },

    get id() {
      return this.$root.id;
    },

    get panels() {
      return Array.from(this.$refs.panels.children);
    },

    isActive(el) {
      return this.store.activeTab === this._getRef(el);
    },

    // protected

    _getRef(el) {
      return el.getAttribute("x-ref");
    },
  };
}
