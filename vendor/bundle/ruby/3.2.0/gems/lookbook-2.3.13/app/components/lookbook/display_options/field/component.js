import Cookies from "js-cookie";
import {
  parseSearchParamValue,
  buildSearchParamValue,
} from "~/assets/js/helpers/string";

export default function displayOptionsFieldComponent({ name, value }) {
  return {
    name,
    value,

    init() {
      this.$watch("value", () => this.update());
    },

    update() {
      Cookies.set(`lookbook-display-${name}`, this.value);

      const searchParams = new URLSearchParams(window.location.search);
      const display = searchParams.get("_display");

      const displayParams = display ? parseSearchParamValue(display) : {};
      displayParams[this.name] = this.value;
      searchParams.set("_display", buildSearchParamValue(displayParams));

      const path = location.href.replace(location.search, "");
      this.navigateTo(`${path}?${searchParams.toString()}`);
    },
  };
}
