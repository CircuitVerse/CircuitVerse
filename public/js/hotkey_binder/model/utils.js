Storage.prototype.set = function (key, obj) {
  return this.setItem(key, JSON.stringify(obj));
};

Storage.prototype.get = function (key) {
  return JSON.parse(this.getItem(key));
};
