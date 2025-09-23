function getComponents(importObject, path = []) {
  let components = {};
  Object.keys(importObject).forEach((key) => {
    if (key === "default") {
      components[toCamel(path.join("_"))] = importObject[key];
    } else {
      components = {
        ...components,
        ...getComponents(importObject[key], [...path, key]),
      };
    }
  });
  return components;
}

function toCamel(s) {
  return s.replace(/([-_][a-z])/gi, ($1) => {
    return $1.toUpperCase().replace("-", "").replace("_", "");
  });
}

export { getComponents };
