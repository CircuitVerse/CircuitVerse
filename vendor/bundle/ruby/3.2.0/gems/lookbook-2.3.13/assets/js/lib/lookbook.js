window.Lookbook = window.Lookbook || {};
window.Lookbook.initEmbeds = initEmbeds;

const embedUrlPrefix = "embed";
const whiteListedAttributes = [
  "preview",
  "scenario",
  "panels",
  "actions",
  "param-*",
];

function initEmbeds(root = document) {
  if (typeof window.iFrameResize !== "function") {
    console.error(
      "Lookbook embeds require the 'iframe-resizer' library to be available. Skipping embed instantiation."
    );
    return;
  }

  if (typeof root === "string") {
    root = document.querySelector(root);
  }

  if (!root) {
    return console.error(
      "Could not initialize Lookbook embeds. Root node not found."
    );
  }

  const embeds = Array.from(root.querySelectorAll("lookbook-embed"));

  embeds.forEach((embed) => {
    const attrs = Array.from(embed.attributes);
    const wrapper = createWrapper();
    const iframe = createIframe(attrs);

    wrapper.appendChild(iframe);
    embed.replaceWith(wrapper);
  });

  window.iFrameResize({ checkOrigin: false }, "[data-lookbook-embed-iframe]");
}

function createWrapper() {
  const wrapper = document.createElement("div");

  wrapper.setAttribute("data-lookbook-embed", "");
  wrapper.classList.add("lookbook-embed");

  return wrapper;
}

function createIframe(attrs) {
  const src = buildSrc(attrs);
  const id = attrValue(attrs, "id");
  const styles = attrValue(attrs, "style");
  const classes = attrValue(attrs, "class", "")
    .split(" ")
    .map((c) => c.trim())
    .filter((c) => c.length);

  const iframe = document.createElement("iframe");
  iframe.src = src;
  if (id) iframe.id = id;

  iframe.setAttribute("frameborder", 0);
  iframe.setAttribute("data-lookbook-embed-iframe", "");

  if (classes.length) iframe.classList.add(...classes);
  if (styles) iframe.style.cssText = styles;

  iframe.style.width = "100%";
  iframe.style.transition = "height 0.3s";

  return iframe;
}

function buildSrc(attrs) {
  const appPath = attrValue(attrs, "app") || guessBasePath();
  const props = {};

  permittedAttrs(attrs).forEach(({ name, value }) => {
    name = name.replace("-", "_").toLowerCase();
    props[name] = value;
  });

  return encodeURI(
    [appPath, embedUrlPrefix].join("/") + `?props=${JSON.stringify(props)}`
  );
}

function attrValue(attrs, name, fallback = null) {
  const attr = attrs.find((attr) => attr.name === name);
  return attr ? attr.value : fallback;
}

function permittedAttrs(attrs) {
  return attrs.filter((attr) => {
    return whiteListedAttributes.find((key) => {
      const name = attr.name;
      return (
        key === name ||
        (key.includes("*") && name.startsWith(key.replace("*", "")))
      );
    });
  });
}

function guessBasePath() {
  const script =
    document.currentScript ||
    document.querySelector('script[src*="lookbook.js"]');
  const scriptSrc = script.src;

  if (scriptSrc && scriptSrc.includes("lookbook-assets")) {
    return scriptSrc
      .split("?")[0]
      .replace("lookbook-assets/js/lookbook.js", "lookbook");
  }

  return `//${location.host}/lookbook`;
}

document.addEventListener("DOMContentLoaded", () => initEmbeds());
