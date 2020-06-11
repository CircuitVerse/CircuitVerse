Storage.prototype.set = function (key, obj) {
    return this.setItem(key, JSON.stringify(obj));
};

Storage.prototype.get = function (key) {
    return JSON.parse(this.getItem(key));
};

const getKey = (obj, val) => Object.keys(obj).find((key) => obj[key] === val);

const getOS = () => {
    let OSName = '';
    if (navigator.appVersion.indexOf("Win") != -1) OSName = "Windows";
    if (navigator.appVersion.indexOf("Mac") != -1) OSName = "MacOS";
    if (navigator.appVersion.indexOf("X11") != -1) OSName = "UNIX";
    if (navigator.appVersion.indexOf("Linux") != -1) OSName = "Linux";
    return OSName;
};

const checkRestricted = (key) => {
    const restrictedKeys = [
        "CTRL + N",
        "CTRL + W",
        "CTRL + T",
        "META + N",
        "META + W",
        "META + T",
    ];
    return restrictedKeys.includes(key);
};
