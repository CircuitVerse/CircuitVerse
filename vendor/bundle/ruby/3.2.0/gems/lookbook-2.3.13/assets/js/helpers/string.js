function decodeEntities(content) {
  var txt = document.createElement("textarea");
  txt.innerHTML = content;
  return txt.value;
}

function prefixString(string, prefix = null) {
  return prefix ? `${prefix}-${string}` : string;
}

function parseSearchParamValue(value) {
  const json = decodeURIComponent(value);
  return JSON.parse(json);
}

function buildSearchParamValue(data) {
  const str = JSON.stringify(data);
  return encodeURIComponent(str);
}

export {
  prefixString,
  decodeEntities,
  parseSearchParamValue,
  buildSearchParamValue,
};
