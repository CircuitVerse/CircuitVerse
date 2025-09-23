import { prefixString } from "../helpers/string";

export default function initPagesStore(Alpine, { prefix }) {
  return {
    embeds: Alpine.$persist({}).as(prefixString("pages-embeds", prefix)),
  };
}
