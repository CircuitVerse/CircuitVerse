Storage.prototype.set = function (key, obj) {
    return this.setItem(key, JSON.stringify(obj));
};

Storage.prototype.get = function (key) {
    return JSON.parse(this.getItem(key));
};

Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};

export const getKey = (obj, val) => Object.keys(obj).find((key) => obj[key] === val);

export const getOS = () => {
    let OSName = "";
    if (navigator.appVersion.indexOf("Win") != -1) OSName = "Windows";
    if (navigator.appVersion.indexOf("Mac") != -1) OSName = "MacOS";
    if (navigator.appVersion.indexOf("X11") != -1) OSName = "UNIX";
    if (navigator.appVersion.indexOf("Linux") != -1) OSName = "Linux";
    return OSName;
};

export const checkRestricted = (key) => {
    const restrictedKeys = [
        "Ctrl + N",
        "Ctrl + W",
        "Ctrl + T",
        "Ctrl + C",
        "Ctrl + V",
        "Ctrl + Delete",
        "Ctrl + Backspace",
        "Ctrl + /",
        "Ctrl + \\",
        "Ctrl + ]",
        "Ctrl + '",
        "Ctrl + `",
        "Ctrl + [",
        "Ctrl + ~",
        "Ctrl + Num1",
        "Ctrl + Num2",
        "Ctrl + Num3",
        "Ctrl + Num4",
        "Ctrl + Num5",
        "Ctrl + Num6",
        "Ctrl + Num*",
        "Ctrl + Num/",
        "Ctrl + Num.",
        "Ctrl + Num0",
    ];
    if (getOS == "macOS") {
        restrictedKeys.forEach((value, i) => {
            if (value.split(" + ")[0] == "Ctrl");
            restrictedKeys[i] =
                value.split(" + ")[0] == "Ctrl"
                    ? value.replace("Ctrl", "Meta")
                    : value;
        });
    }
    return restrictedKeys.includes(key);
};
