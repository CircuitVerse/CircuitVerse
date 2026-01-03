async function fetchHTML(url, selector, options = {}) {
  const response = await fetch(url || window.document.location, options);
  const html = await response.text();
  const doc = new DOMParser().parseFromString(html, "text/html");
  return {
    ok: response.ok,
    fragment: selector ? doc.querySelector(selector).outerHTML : null,
    title: doc.title,
    response,
    doc,
  };
}

export { fetchHTML };
