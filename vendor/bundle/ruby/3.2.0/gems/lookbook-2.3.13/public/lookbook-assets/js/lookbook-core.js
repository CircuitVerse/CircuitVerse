(() => {
window.Lookbook = window.Lookbook || {};
window.Lookbook.initEmbeds = $5000cc5d1e9e824a$var$initEmbeds;
const $5000cc5d1e9e824a$var$embedUrlPrefix = "embed";
const $5000cc5d1e9e824a$var$whiteListedAttributes = [
    "preview",
    "scenario",
    "panels",
    "actions",
    "param-*"
];
function $5000cc5d1e9e824a$var$initEmbeds(root = document) {
    if (typeof window.iFrameResize !== "function") {
        console.error("Lookbook embeds require the 'iframe-resizer' library to be available. Skipping embed instantiation.");
        return;
    }
    if (typeof root === "string") root = document.querySelector(root);
    if (!root) return console.error("Could not initialize Lookbook embeds. Root node not found.");
    const embeds = Array.from(root.querySelectorAll("lookbook-embed"));
    embeds.forEach((embed)=>{
        const attrs = Array.from(embed.attributes);
        const wrapper = $5000cc5d1e9e824a$var$createWrapper();
        const iframe = $5000cc5d1e9e824a$var$createIframe(attrs);
        wrapper.appendChild(iframe);
        embed.replaceWith(wrapper);
    });
    window.iFrameResize({
        checkOrigin: false
    }, "[data-lookbook-embed-iframe]");
}
function $5000cc5d1e9e824a$var$createWrapper() {
    const wrapper = document.createElement("div");
    wrapper.setAttribute("data-lookbook-embed", "");
    wrapper.classList.add("lookbook-embed");
    return wrapper;
}
function $5000cc5d1e9e824a$var$createIframe(attrs) {
    const src = $5000cc5d1e9e824a$var$buildSrc(attrs);
    const id = $5000cc5d1e9e824a$var$attrValue(attrs, "id");
    const styles = $5000cc5d1e9e824a$var$attrValue(attrs, "style");
    const classes = $5000cc5d1e9e824a$var$attrValue(attrs, "class", "").split(" ").map((c)=>c.trim()).filter((c)=>c.length);
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
function $5000cc5d1e9e824a$var$buildSrc(attrs) {
    const appPath = $5000cc5d1e9e824a$var$attrValue(attrs, "app") || $5000cc5d1e9e824a$var$guessBasePath();
    const props = {};
    $5000cc5d1e9e824a$var$permittedAttrs(attrs).forEach(({ name: name, value: value })=>{
        name = name.replace("-", "_").toLowerCase();
        props[name] = value;
    });
    return encodeURI([
        appPath,
        $5000cc5d1e9e824a$var$embedUrlPrefix
    ].join("/") + `?props=${JSON.stringify(props)}`);
}
function $5000cc5d1e9e824a$var$attrValue(attrs, name, fallback = null) {
    const attr = attrs.find((attr)=>attr.name === name);
    return attr ? attr.value : fallback;
}
function $5000cc5d1e9e824a$var$permittedAttrs(attrs) {
    return attrs.filter((attr)=>{
        return $5000cc5d1e9e824a$var$whiteListedAttributes.find((key)=>{
            const name = attr.name;
            return key === name || key.includes("*") && name.startsWith(key.replace("*", ""));
        });
    });
}
function $5000cc5d1e9e824a$var$guessBasePath() {
    const script = document.currentScript || document.querySelector('script[src*="lookbook.js"]');
    const scriptSrc = script.src;
    if (scriptSrc && scriptSrc.includes("lookbook-assets")) return scriptSrc.split("?")[0].replace("lookbook-assets/js/lookbook.js", "lookbook");
    return `//${location.host}/lookbook`;
}
document.addEventListener("DOMContentLoaded", ()=>$5000cc5d1e9e824a$var$initEmbeds());



})();
