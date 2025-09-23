import initFilterStore from "./filter";
import { prefixString } from "../helpers/string";

export default function initNavStore(Alpine, { prefix }) {
  return {
    previews: {
      filter: initFilterStore(
        Alpine,
        prefixString("previews-filter-text", prefix)
      ),
      open: Alpine.$persist([]).as(prefixString("previews-nav-open", prefix)),
    },

    pages: {
      filter: initFilterStore(
        Alpine,
        prefixString("pages-filter-text", prefix)
      ),
      open: Alpine.$persist([]).as(prefixString("pages-nav-open", prefix)),
    },
  };
}
