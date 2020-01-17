/**
 * EEPROM Component.
 *
 * This is basically a RAM component that persists its contents.
 *
 * We consider EEPROMs more 'expensive' than RAMs, so we arbitrarily limit
 * the addressWith to a maximum of 10 bits (1024 addresses) with a default of 8-bit (256).
 *
 * In the EEPROM all addresses are initialized to zero.
 * This way we serialize unused values as "0" instead of "null".
 *
 * These two techniques help keep reduce the size of saved projects.
 */
function EEPROM(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 8, addressWidth = 8, data = null) {
    RAM.call(this, x, y, scope, dir, bitWidth, addressWidth);
    this.data = data || this.data;
}
EEPROM.prototype = Object.create(RAM.prototype);
EEPROM.prototype.tooltipText = "Electrically Erasable Programmable Read-Only Memory";
EEPROM.prototype.constructor = EEPROM;
EEPROM.prototype.shortName = "EEPROM";
EEPROM.prototype.maxAddressWidth = 10;
EEPROM.prototype.mutableProperties = {
    "addressWidth": {
        name: "Address Width",
        type: "number",
        max: "10",
        min: "1",
        func: "changeAddressWidth",
    },
    "dump": RAM.prototype.mutableProperties.dump,
    "reset": RAM.prototype.mutableProperties.reset,
}
EEPROM.prototype.customSave = function () {
    var saveInfo = RAM.prototype.customSave.call(this);

    // Normalize this.data to use zeroes instead of null when serialized.
    var data = this.data;
    for (var i = 0; i < data.length; i++) {
        data[i] = data[i] || 0;
    }

    saveInfo.constructorParamaters.push(data);
    return saveInfo;
}

