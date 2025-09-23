export default function initFilterStore(Alpine, name) {
  return {
    raw: Alpine.$persist("").as(name),
    get text() {
      return this.raw.replace(/\s/g, "").toLowerCase();
    },
    get active() {
      return this.text.length > 0;
    },
  };
}
