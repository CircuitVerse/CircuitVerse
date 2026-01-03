export default function paramsInputComponent({ name, value }) {
  return {
    name,
    value,

    init() {
      this.$watch("value", () => this.update());
    },

    update() {
      if (this.validate()) {
        const searchParams = new URLSearchParams(window.location.search);
        searchParams.set(this.name, this.value);
        const path = location.href.replace(location.search, "");
        this.navigateTo(`${path}?${searchParams.toString()}`);
      }
    },

    validate() {
      return this.$root.reportValidity ? this.$root.reportValidity() : true;
    },
  };
}
