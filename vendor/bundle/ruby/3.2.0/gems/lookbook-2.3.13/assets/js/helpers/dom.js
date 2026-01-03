function morph(from, to) {
  Alpine.morph(from, to, {
    key(el) {
      return el.getAttribute("key") ? el.getAttribute("key") : el.id;
    },
    lookahead: true,
    updating(el, toEl, childrenOnly, skip) {
      if (!el.getAttribute) return;
      if (el.getAttribute("data-morph-strategy") === "replace") {
        el.innerHTML = toEl.innerHTML;
        return skip();
      } else if (el.getAttribute("data-morph-strategy") === "skip") {
        return skip();
      }
    },
  });
}

function getElementSize(el, opts = {}) {
  const style = window.getComputedStyle(el, null);
  return {
    width: opts.includeMargins
      ? el.offsetWidth +
        parseInt(style.getPropertyValue("margin-left")) +
        parseInt(style.getPropertyValue("margin-right"))
      : el.offsetWidth,
    height: opts.includeMargins
      ? el.offsetHeight +
        parseInt(style.getPropertyValue("margin-top")) +
        parseInt(style.getPropertyValue("margin-bottom"))
      : el.offsetHeight,
  };
}

function isExternalLink(link) {
  if (link.href) {
    return link.host !== window.location.host;
  }
  return false;
}

export { morph, getElementSize, isExternalLink };
